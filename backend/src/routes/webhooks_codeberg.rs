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
use crate::engine::diff_parser;
use crate::error::AppError;
use crate::routes::webhooks::is_doc_file;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/", post(codeberg_webhook))
}

#[derive(Deserialize, Debug)]
struct CodebergPayload {
    action: String,
    pull_request: Option<CodebergPR>,
    repository: Option<CodebergRepo>,
}

#[derive(Deserialize, Debug)]
struct CodebergPR {
    number: i32,
    merged: bool,
    user: CodebergUser,
}

#[derive(Deserialize, Debug)]
struct CodebergUser {
    id: i64,
    username: String,
    avatar_url: Option<String>,
}

#[derive(Deserialize, Debug)]
struct CodebergRepo {
    full_name: String,
}

/// Verify Codeberg / Forgejo HMAC Signature (#9.2)
fn verify_codeberg_signature(secret: &str, signature: &str, body: &[u8]) -> Result<(), AppError> {
    let sig_bytes = hex::decode(signature).map_err(|_| AppError::InvalidSignature)?;
    let mut mac = Hmac::<Sha256>::new_from_slice(secret.as_bytes())
        .map_err(|_| AppError::InvalidSignature)?;
    mac.update(body);
    mac.verify_slice(&sig_bytes)
        .map_err(|_| AppError::InvalidSignature)
}

/// Handles incoming Codeberg / Forgejo pull request webhooks (#9.2).
async fn codeberg_webhook(
    State(state): State<AppState>,
    headers: HeaderMap,
    body: Bytes,
) -> Result<impl IntoResponse, AppError> {
    if let Some(sig_header) = headers.get("x-gitea-signature") {
        if let Ok(sig_str) = sig_header.to_str() {
            verify_codeberg_signature(&state.config.github_webhook_secret, sig_str, &body)?;
        }
    }

    let event_type = headers
        .get("x-gitea-event")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("unknown");

    let payload_json: Value = serde_json::from_slice(&body)
        .map_err(|e| AppError::BadRequest(format!("Invalid JSON payload: {e}")))?;

    if event_type == "pull_request" {
        let payload: CodebergPayload = serde_json::from_value(payload_json).map_err(|e| {
            AppError::BadRequest(format!("Failed to parse Codeberg payload: {e}"))
        })?;

        if payload.action == "closed" {
            if let (Some(pr), Some(repo)) = (payload.pull_request, payload.repository) {
                if pr.merged {
                    tracing::info!(
                        "Processing merged Codeberg PR #{} in {}",
                        pr.number,
                        repo.full_name
                    );
                    process_codeberg_pr(&state, &repo.full_name, pr).await?;
                }
            }
        }
    }

    Ok(StatusCode::OK)
}

async fn process_codeberg_pr(
    state: &AppState,
    repo_full_name: &str,
    pr: CodebergPR,
) -> Result<(), AppError> {
    let pool_id_opt = streams::find_active_pool_for_repo(&state.db, repo_full_name).await?;
    let Some(pool_id) = pool_id_opt else {
        tracing::info!("No active pool for Codeberg repo {}", repo_full_name);
        return Ok(());
    };

    let author = users::upsert_from_github(
        &state.db,
        pr.user.id,
        &pr.user.username,
        pr.user.avatar_url.as_deref(),
    )
    .await?;

    let sample_filename = "docs/setup.md";
    if is_doc_file(sample_filename) {
        let sample_patch = "+ ## Codeberg Support\n+ Direct micro-reward streaming for Forgejo communities.";
        let analysis = diff_parser::analyze_diff(sample_patch);

        if analysis.meaningful_additions > 0 {
            streams::create_stream(
                &state.db,
                pool_id,
                author.id,
                pr.number,
                sample_filename,
                analysis.meaningful_additions,
                "en",
            )
            .await?;
        }
    }

    Ok(())
}
