use axum::{
    body::Bytes,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
    routing::post,
    Router,
};
use chrono::Utc;
use hmac::{Hmac, Mac};
use serde::Deserialize;
use serde_json::Value;
use sha2::Sha256;

use crate::db::{streams, users};
use crate::engine::diff_parser;
use crate::error::AppError;
use crate::services::github::GitHubClient;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/github", post(github_webhook))
}

#[derive(Deserialize, Debug)]
struct WebhookPayload {
    action: String,
    pull_request: Option<PullRequest>,
    repository: Option<Repository>,
}

#[derive(Deserialize, Debug)]
struct PullRequest {
    number: i32,
    merged: bool,
    user: PullRequestUser,
}

#[derive(Deserialize, Debug)]
struct PullRequestUser {
    id: i64,
    login: String,
    avatar_url: String,
}

#[derive(Deserialize, Debug)]
struct Repository {
    full_name: String,
}

/// Helper function to verify the GitHub HMAC signature.
fn verify_signature(secret: &str, signature: &str, body: &[u8]) -> Result<(), AppError> {
    let sig_hex = signature
        .strip_prefix("sha256=")
        .ok_or(AppError::InvalidSignature)?;

    let sig_bytes = hex::decode(sig_hex).map_err(|_| AppError::InvalidSignature)?;

    let mut mac = Hmac::<Sha256>::new_from_slice(secret.as_bytes())
        .map_err(|_| AppError::InvalidSignature)?;
    mac.update(body);

    mac.verify_slice(&sig_bytes)
        .map_err(|_| AppError::InvalidSignature)
}

/// Time-bounded replay window validation (#3.1). Rejects webhooks older than 300 seconds.
fn validate_webhook_timestamp(headers: &HeaderMap) -> Result<(), AppError> {
    if let Some(ts_header) = headers.get("x-github-hook-timestamp") {
        if let Ok(ts_str) = ts_header.to_str() {
            if let Ok(ts) = ts_str.parse::<i64>() {
                let now = Utc::now().timestamp();
                let age = now - ts;
                if age > 300 || age < -60 {
                    return Err(AppError::BadRequest(
                        "Webhook timestamp outside 5-minute replay window".into(),
                    ));
                }
            }
        }
    }
    Ok(())
}

/// Smart filter to determine if a file is a documentation file.
pub fn is_doc_file(path: &str) -> bool {
    let doc_extensions = [".md", ".mdx", ".rst", ".adoc", ".txt"];
    let doc_paths = ["docs/", "documentation/", "wiki/", "guides/"];

    let has_doc_ext = doc_extensions.iter().any(|ext| path.ends_with(ext));
    let in_doc_path = doc_paths.iter().any(|p| path.starts_with(p));

    let excluded = [
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        "LICENSE.md",
        "CODE_OF_CONDUCT.md",
    ];
    let is_excluded = excluded.iter().any(|f| path == *f);

    (has_doc_ext || in_doc_path) && !is_excluded
}

/// Handles incoming GitHub webhooks.
async fn github_webhook(
    State(state): State<AppState>,
    headers: HeaderMap,
    body: Bytes,
) -> Result<impl IntoResponse, AppError> {
    // 1. Replay window check (#3.1)
    validate_webhook_timestamp(&headers)?;

    // 2. Verify signature
    let signature = headers
        .get("x-hub-signature-256")
        .and_then(|v| v.to_str().ok())
        .ok_or(AppError::InvalidSignature)?;

    verify_signature(&state.config.github_webhook_secret, signature, &body)?;

    // 3. Extract Event Type and Delivery ID
    let event_type = headers
        .get("x-github-event")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("unknown");

    let delivery_id = headers
        .get("x-github-delivery")
        .and_then(|v| v.to_str().ok())
        .ok_or_else(|| AppError::BadRequest("Missing x-github-delivery header".into()))?;

    // 4. Idempotency Check
    let payload_json: Value = serde_json::from_slice(&body).map_err(|e| {
        AppError::BadRequest(format!("Invalid JSON payload: {e}"))
    })?;

    let insert_event = sqlx::query!(
        r#"
        INSERT INTO webhook_events (delivery_id, event_type, payload)
        VALUES ($1, $2, $3)
        ON CONFLICT (delivery_id) DO NOTHING
        RETURNING id
        "#,
        delivery_id,
        event_type,
        payload_json
    )
    .fetch_optional(&state.db)
    .await?;

    if insert_event.is_none() {
        tracing::info!("Webhook {} already processed (idempotent)", delivery_id);
        return Ok(StatusCode::OK);
    }

    // 5. Process "pull_request" events
    if event_type == "pull_request" {
        let payload: WebhookPayload = serde_json::from_value(payload_json).unwrap();

        if payload.action == "closed" {
            if let (Some(pr), Some(repo)) = (payload.pull_request, payload.repository) {
                if pr.merged {
                    tracing::info!("Processing merged PR #{} in {}", pr.number, repo.full_name);
                    process_merged_pr(&state, &repo.full_name, pr).await?;
                }
            }
        }
    }

    // Mark as processed
    sqlx::query!(
        "UPDATE webhook_events SET processed = TRUE WHERE delivery_id = $1",
        delivery_id
    )
    .execute(&state.db)
    .await?;

    Ok(StatusCode::OK)
}

/// Analyzes a merged PR and creates streams for valid doc files.
async fn process_merged_pr(
    state: &AppState,
    repo_full_name: &str,
    pr: PullRequest,
) -> Result<(), AppError> {
    // A. Check if the repo has an active reward pool
    let pool_id_opt = streams::find_active_pool_for_repo(&state.db, repo_full_name).await?;
    let Some(pool_id) = pool_id_opt else {
        tracing::info!("No active pool for repo {}", repo_full_name);
        return Ok(());
    };

    // B. Verify PR author credentials and merge state via GitHub API (#3.4)
    let github = GitHubClient::new();
    if let Ok(details) = github.fetch_pr_details(repo_full_name, pr.number).await {
        if !details.merged {
            return Err(AppError::BadRequest("PR was closed without merging".into()));
        }
        if details.user.login != pr.user.login {
            return Err(AppError::BadRequest("Author mismatch in PR details".into()));
        }
    }

    // C. Fetch PR file diffs via GitHub API
    let pr_files = github.fetch_pr_files(repo_full_name, pr.number).await?;

    // D. Upsert Author
    let author = users::upsert_from_github(
        &state.db,
        pr.user.id,
        &pr.user.login,
        Some(&pr.user.avatar_url),
    )
    .await?;

    // E. Filter and create streams with AST diff analysis (#3.2, #3.3)
    for file in pr_files {
        if is_doc_file(&file.filename) {
            // Apply AST diff parser if patch content is present
            let character_count = if let Some(patch) = &file.patch {
                let analysis = diff_parser::analyze_diff(patch);
                if analysis.is_formatting_only {
                    tracing::info!(
                        "Skipping {} in PR #{}: formatting/TOC change only",
                        file.filename,
                        pr.number
                    );
                    continue;
                }
                analysis.meaningful_additions
            } else {
                file.additions
            };

            if character_count <= 0 {
                continue;
            }

            let (locale_boost, locale) = crate::engine::locale_boost::detect_locale_multiplier(&file.filename);

            tracing::info!(
                "Creating stream for PR #{} file: {} ({} meaningful chars, locale: {}, boost: {:.1}x)",
                pr.number,
                file.filename,
                character_count,
                locale,
                locale_boost
            );

            let patch_text = file.patch.as_deref().unwrap_or("");
            let quality_analysis = crate::engine::quality_scorer::analyze_documentation_quality(patch_text);
            let final_multiplier = quality_analysis.quality_score * locale_boost;

            streams::create_stream(
                &state.db,
                pool_id,
                author.id,
                pr.number,
                &file.filename,
                character_count,
                &locale,
                Some(patch_text),
                Some(final_multiplier),
                Some(locale_boost),
            )
            .await?;
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn doc_file_filter() {
        assert!(is_doc_file("docs/guide.md"));
        assert!(is_doc_file("docs/api.mdx"));
        assert!(is_doc_file("documentation/setup.rst"));
        assert!(is_doc_file("README.md"));
        assert!(is_doc_file("docs/es/getting-started.md"));
        assert!(is_doc_file("wiki/FAQ.md"));

        assert!(!is_doc_file("CHANGELOG.md"));
        assert!(!is_doc_file("CONTRIBUTING.md"));
        assert!(!is_doc_file("src/main.rs"));
        assert!(!is_doc_file("lib/utils.js"));
    }
}
