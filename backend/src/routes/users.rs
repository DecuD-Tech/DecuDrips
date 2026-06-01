use axum::{
    extract::State,
    response::IntoResponse,
    routing::get,
    Json, Router,
};
use serde::Serialize;
use uuid::Uuid;

use crate::auth::middleware::AuthUser;
use crate::db::users;
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/me", get(get_me))
}

#[derive(Serialize)]
struct UserResponse {
    id: Uuid,
    github_id: i64,
    username: String,
    avatar_url: Option<String>,
    role: String,
}

/// Returns the currently authenticated user's profile.
async fn get_me(
    State(state): State<AppState>,
    user: AuthUser, // Requires valid JWT
) -> Result<impl IntoResponse, AppError> {
    let user_row = users::get_by_id(&state.db, user.id)
        .await?
        .ok_or(AppError::NotFound)?;

    let response = UserResponse {
        id: user_row.id,
        github_id: user_row.github_id,
        username: user_row.username,
        avatar_url: user_row.avatar_url,
        role: user_row.role,
    };

    Ok(Json(response))
}
