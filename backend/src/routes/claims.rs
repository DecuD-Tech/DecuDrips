use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use rust_decimal::Decimal;
use rust_decimal_macros::dec;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::auth::middleware::AuthUser;
use crate::db::claims::{self, Claim};
use crate::engine::safety::{validate_claim, PoolSafetyConfig};
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_claims))
        .route("/", post(submit_claim))
        .route("/:id/cancel", post(cancel_claim))
}

#[derive(Deserialize)]
struct SubmitClaimRequest {
    stream_id: Uuid,
    amount: Decimal,
    settlement_id: Option<Uuid>,
}

#[derive(Serialize)]
struct ClaimResponse {
    claim: Claim,
}

/// Submit a new reward withdrawal claim (#4.5)
async fn submit_claim(
    State(state): State<AppState>,
    user: AuthUser,
    Json(payload): Json<SubmitClaimRequest>,
) -> Result<impl IntoResponse, AppError> {
    // 1. Enforce pool safety caps (#4.2)
    let safety_config = PoolSafetyConfig::default();
    validate_claim(payload.amount, dec!(1000.0), 0, &safety_config)
        .map_err(|e| AppError::BadRequest(e.to_string()))?;

    // 2. Create claim in DB
    let claim = claims::create_claim(
        &state.db,
        payload.stream_id,
        user.id,
        payload.amount,
        payload.settlement_id,
    )
    .await?;

    Ok((StatusCode::CREATED, Json(ClaimResponse { claim })))
}

/// List all claims for the authenticated user (#4.5)
async fn list_claims(
    State(state): State<AppState>,
    user: AuthUser,
) -> Result<impl IntoResponse, AppError> {
    let user_claims = claims::list_claims_by_user(&state.db, user.id).await?;
    Ok(Json(user_claims))
}

/// Cancel a pending claim (#4.5)
async fn cancel_claim(
    State(state): State<AppState>,
    user: AuthUser,
    Path(id): Path<Uuid>,
) -> Result<impl IntoResponse, AppError> {
    let existing = claims::get_claim_by_id(&state.db, id)
        .await?
        .ok_or(AppError::NotFound)?;

    if existing.user_id != user.id {
        return Err(AppError::Forbidden);
    }

    if existing.status != "pending" {
        return Err(AppError::BadRequest("Only pending claims can be cancelled".into()));
    }

    let updated = claims::update_claim_status(&state.db, id, "cancelled", None, None).await?;
    Ok(Json(updated))
}
