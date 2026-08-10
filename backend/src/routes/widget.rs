use axum::{
    extract::{Query, State},
    response::IntoResponse,
    routing::get,
    Json, Router,
};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::db::nonces;
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/nonce", get(issue_nonce))
}

#[derive(Deserialize)]
struct NonceQuery {
    stream_id: Uuid,
}

#[derive(Serialize)]
struct NonceResponse {
    nonce: String,
    expires_in_seconds: i64,
}

/// Issues a single-use ephemeral nonce for widget vote authentication (#5.1)
async fn issue_nonce(
    State(state): State<AppState>,
    Query(query): Query<NonceQuery>,
) -> Result<impl IntoResponse, AppError> {
    let nonce_str = format!("nonce_{}", Uuid::new_v4());
    let ttl_seconds = 300; // 5-minute TTL

    nonces::create_nonce(&state.db, query.stream_id, &nonce_str, ttl_seconds).await?;

    Ok(Json(NonceResponse {
        nonce: nonce_str,
        expires_in_seconds: ttl_seconds,
    }))
}
