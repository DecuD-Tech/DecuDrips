use axum::{
    extract::{Query, State},
    response::{IntoResponse, Redirect},
    routing::get,
    Router,
};
use serde::{Deserialize, Serialize};

use crate::auth::jwt::encode_token;
use crate::db::users::upsert_from_github;
use crate::error::AppError;
use crate::services::github::GitHubClient;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/github", get(github_login))
        .route("/github/callback", get(github_callback))
}

#[derive(Serialize)]
struct AuthResponse {
    token: String,
}

#[derive(Deserialize)]
struct CallbackQuery {
    code: String,
}

/// Redirects the user to GitHub's OAuth authorization page.
async fn github_login(State(state): State<AppState>) -> impl IntoResponse {
    let client_id = &state.config.github_client_id;
    let redirect_uri = &state.config.github_redirect_uri;
    
    let auth_url = format!(
        "https://github.com/login/oauth/authorize?client_id={}&redirect_uri={}",
        client_id, redirect_uri
    );

    Redirect::temporary(&auth_url)
}

/// Handles the OAuth callback from GitHub.
async fn github_callback(
    State(state): State<AppState>,
    Query(query): Query<CallbackQuery>,
) -> Result<impl IntoResponse, AppError> {
    let github = GitHubClient::new();

    // 1. Exchange code for access token
    let access_token = github
        .exchange_code(
            &state.config.github_client_id,
            &state.config.github_client_secret,
            &query.code,
            &state.config.github_redirect_uri,
        )
        .await?;

    // 2. Fetch user profile from GitHub
    let gh_user = github.fetch_user(&access_token).await?;

    // 3. Upsert user in our database
    let user = upsert_from_github(
        &state.db,
        gh_user.id,
        &gh_user.login,
        gh_user.avatar_url.as_deref(),
    )
    .await?;

    // 4. Generate JWT
    let token = encode_token(
        user.id,
        user.github_id,
        &user.username,
        &user.role,
        &state.config.jwt_secret,
        state.config.jwt_expiry_hours,
    )?;

    // Redirect to frontend with token
    let frontend_url = format!("{}/auth/callback?token={}", state.config.cors_origin, token);
    Ok(Redirect::temporary(&frontend_url))
}
