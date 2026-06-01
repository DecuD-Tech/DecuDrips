use axum::{
    body::Bytes,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
    routing::post,
    Router,
};
use hmac::{Hmac, Mac};
use serde::Deserialize;
use serde_json::Value;
use sha2::Sha256;

use crate::db::{streams, users};
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
    // 1. Verify signature
    let signature = headers
        .get("x-hub-signature-256")
        .and_then(|v| v.to_str().ok())
        .ok_or(AppError::InvalidSignature)?;

    verify_signature(&state.config.github_webhook_secret, signature, &body)?;

    // 2. Extract Event Type and Delivery ID
    let event_type = headers
        .get("x-github-event")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("unknown");

    let delivery_id = headers
        .get("x-github-delivery")
        .and_then(|v| v.to_str().ok())
        .ok_or_else(|| AppError::BadRequest("Missing x-github-delivery header".into()))?;

    // 3. Idempotency Check
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

    // 4. Process "pull_request" events
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

    // B. Fetch PR file diffs via GitHub API
    let github = GitHubClient::new();
    let pr_files = github.fetch_pr_files(repo_full_name, pr.number).await?;

    // C. Upsert Author
    // Note: This relies on the GitHub ID to ensure consistency.
    let author = users::upsert_from_github(
        &state.db,
        pr.user.id,
        &pr.user.login,
        Some(&pr.user.avatar_url),
    )
    .await?;

    // D. Filter and create streams
    for file in pr_files {
        if is_doc_file(&file.filename) && file.additions > 0 {
            // Simple locale heuristic (could be improved later)
            // e.g. docs/es/guide.md -> "es"
            let locale = if file.filename.contains("/es/") {
                "es"
            } else if file.filename.contains("/zh/") {
                "zh"
            } else if file.filename.contains("/de/") {
                "de"
            } else {
                "en"
            };

            tracing::info!(
                "Creating stream for PR #{} file: {} ({} chars)",
                pr.number, file.filename, file.additions
            );

            streams::create_stream(
                &state.db,
                pool_id,
                author.id,
                pr.number,
                &file.filename,
                file.additions,
                locale,
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
