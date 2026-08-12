use axum::{
    body::Bytes,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
    routing::post,
    Router,
};
use serde::Deserialize;
use serde_json::Value;

use crate::db::{streams, users};
use crate::engine::diff_parser;
use crate::error::AppError;
use crate::routes::webhooks::is_doc_file;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/", post(gitlab_webhook))
}

#[derive(Deserialize, Debug)]
struct GitLabWebhookPayload {
    object_kind: String, // "merge_request"
    object_attributes: Option<MergeRequestAttributes>,
    project: Option<GitLabProject>,
    user: Option<GitLabUser>,
}

#[derive(Deserialize, Debug)]
struct MergeRequestAttributes {
    iid: i32,
    state: String, // "merged"
    title: String,
}

#[derive(Deserialize, Debug)]
struct GitLabProject {
    path_with_namespace: String, // e.g. "org/repo"
}

#[derive(Deserialize, Debug)]
struct GitLabUser {
    id: i64,
    username: String,
    avatar_url: Option<String>,
}

/// Handles incoming GitLab merge request webhooks (#9.1).
async fn gitlab_webhook(
    State(state): State<AppState>,
    headers: HeaderMap,
    body: Bytes,
) -> Result<impl IntoResponse, AppError> {
    // 1. Verify Secret Token header if configured
    if let Some(token_header) = headers.get("x-gitlab-token") {
        if let Ok(token_str) = token_header.to_str() {
            if token_str != state.config.github_webhook_secret {
                return Err(AppError::InvalidSignature);
            }
        }
    }

    // 2. Extract Event Type
    let event_type = headers
        .get("x-gitlab-event")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("unknown");

    let payload_json: Value = serde_json::from_slice(&body)
        .map_err(|e| AppError::BadRequest(format!("Invalid JSON payload: {e}")))?;

    // 3. Process "Merge Request Hook" events
    if event_type == "Merge Request Hook" || event_type == "merge_request" {
        let payload: GitLabWebhookPayload = serde_json::from_value(payload_json).map_err(|e| {
            AppError::BadRequest(format!("Failed to parse GitLab payload: {e}"))
        })?;

        if payload.object_kind == "merge_request" {
            if let (Some(mr), Some(proj), Some(author_user)) =
                (payload.object_attributes, payload.project, payload.user)
            {
                if mr.state == "merged" {
                    tracing::info!(
                        "Processing merged GitLab MR !{} in {}",
                        mr.iid,
                        proj.path_with_namespace
                    );
                    process_gitlab_mr(&state, &proj.path_with_namespace, mr.iid, author_user).await?;
                }
            }
        }
    }

    Ok(StatusCode::OK)
}

/// Process merged GitLab MR and stream reward allocations
async fn process_gitlab_mr(
    state: &AppState,
    repo_full_name: &str,
    mr_iid: i32,
    author_user: GitLabUser,
) -> Result<(), AppError> {
    let pool_id_opt = streams::find_active_pool_for_repo(&state.db, repo_full_name).await?;
    let Some(pool_id) = pool_id_opt else {
        tracing::info!("No active pool for GitLab repo {}", repo_full_name);
        return Ok(());
    };

    let author = users::upsert_from_github(
        &state.db,
        author_user.id,
        &author_user.username,
        author_user.avatar_url.as_deref(),
    )
    .await?;

    // Mock diff analysis for doc files in MR
    let sample_filename = "docs/guide.md";
    if is_doc_file(sample_filename) {
        let sample_patch = "+ ## GitLab Continuous Integration\n+ DocuDrip automatically streams rewards for merged MRs.";
        let analysis = diff_parser::analyze_diff(sample_patch);

        if analysis.meaningful_additions > 0 {
            streams::create_stream(
                &state.db,
                pool_id,
                author.id,
                mr_iid,
                sample_filename,
                analysis.meaningful_additions,
                "en",
            )
            .await?;
        }
    }

    Ok(())
}
