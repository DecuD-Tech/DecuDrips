use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{delete, get, post},
    Json, Router,
};
use serde::Deserialize;
use uuid::Uuid;

use crate::auth::middleware::AuthUser;
use crate::db::settlement_accounts::{self, SettlementAccount};
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_accounts))
        .route("/", post(create_account))
        .route("/:id", delete(delete_account))
}

#[derive(Deserialize)]
struct CreateAccountRequest {
    provider: String, // 'stripe' | 'opencollective' | 'usdc_base' | 'lightning'
    provider_ref: String,
    is_default: Option<bool>,
}

/// Register a new payout settlement destination (#4.6)
async fn create_account(
    State(state): State<AppState>,
    user: AuthUser,
    Json(payload): Json<CreateAccountRequest>,
) -> Result<impl IntoResponse, AppError> {
    let account = settlement_accounts::create_settlement_account(
        &state.db,
        user.id,
        &payload.provider,
        &payload.provider_ref,
        payload.is_default.unwrap_or(false),
    )
    .await?;

    Ok((StatusCode::CREATED, Json(account)))
}

/// List all settlement accounts for authenticated user (#4.6)
async fn list_accounts(
    State(state): State<AppState>,
    user: AuthUser,
) -> Result<impl IntoResponse, AppError> {
    let accounts = settlement_accounts::list_settlement_accounts_by_user(&state.db, user.id).await?;
    Ok(Json(accounts))
}

/// Remove a settlement account (#4.6)
async fn delete_account(
    State(state): State<AppState>,
    user: AuthUser,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, AppError> {
    let deleted = settlement_accounts::delete_settlement_account(&state.db, id, user.id).await?;
    if !deleted {
        return Err(AppError::NotFound);
    }
    Ok(StatusCode::NO_CONTENT)
}
