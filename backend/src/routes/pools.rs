use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, patch, post},
    Json, Router,
};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::auth::middleware::{AuthUser, OptionalAuth, SponsorUser};
use crate::db::{pools, streams};
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_pools))
        .route("/", post(create_pool))
        .route("/:id", get(get_pool))
        .route("/:id", patch(update_pool))
}

#[derive(Deserialize)]
struct CreatePoolRequest {
    repo_full_name: String,
    funding_amount: Decimal,
    base_rate: Decimal,
}

#[derive(Deserialize)]
struct UpdatePoolRequest {
    status: String,
}

#[derive(Serialize)]
struct PoolResponse {
    id: Uuid,
    owner_id: Uuid,
    repo_full_name: String,
    funding_amount: Decimal,
    base_rate: Decimal,
    total_dripped: Decimal,
    status: String,
}

/// Create a new pool — SPONSORS ONLY
async fn create_pool(
    State(state): State<AppState>,
    SponsorUser(user): SponsorUser, // Compile-time enforced: sponsor role only
    Json(payload): Json<CreatePoolRequest>,
) -> Result<impl IntoResponse, AppError> {
    let pool_row = pools::create_pool(
        &state.db,
        user.id,
        &payload.repo_full_name,
        payload.funding_amount,
        payload.base_rate,
    )
    .await?;

    let response = PoolResponse {
        id: pool_row.id,
        owner_id: pool_row.owner_id,
        repo_full_name: pool_row.repo_full_name,
        funding_amount: pool_row.funding_amount,
        base_rate: pool_row.base_rate,
        total_dripped: pool_row.total_dripped,
        status: pool_row.status,
    };

    Ok((StatusCode::CREATED, Json(response)))
}

/// List all active pools — OPEN TO PUBLIC
async fn list_pools(
    State(state): State<AppState>,
    _auth: OptionalAuth, // Pass-through auth
) -> Result<impl IntoResponse, AppError> {
    let pool_rows = pools::list_active_pools(&state.db).await?;

    let response: Vec<PoolResponse> = pool_rows
        .into_iter()
        .map(|p| PoolResponse {
            id: p.id,
            owner_id: p.owner_id,
            repo_full_name: p.repo_full_name,
            funding_amount: p.funding_amount,
            base_rate: p.base_rate,
            total_dripped: p.total_dripped,
            status: p.status,
        })
        .collect();

    Ok(Json(response))
}

/// Get a specific pool — OPEN TO PUBLIC
async fn get_pool(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    _auth: OptionalAuth,
) -> Result<impl IntoResponse, AppError> {
    let pool_row = pools::get_pool_by_id(&state.db, id)
        .await?
        .ok_or(AppError::NotFound)?;

    let response = PoolResponse {
        id: pool_row.id,
        owner_id: pool_row.owner_id,
        repo_full_name: pool_row.repo_full_name,
        funding_amount: pool_row.funding_amount,
        base_rate: pool_row.base_rate,
        total_dripped: pool_row.total_dripped,
        status: pool_row.status,
    };

    Ok(Json(response))
}

/// Update a pool's status — OWNER ONLY
async fn update_pool(
    State(state): State<AppState>,
    user: AuthUser, // Requires valid JWT
    Path(id): Path<Uuid>,
    Json(payload): Json<UpdatePoolRequest>,
) -> Result<impl IntoResponse, AppError> {
    // 1. Fetch pool
    let pool_row = pools::get_pool_by_id(&state.db, id)
        .await?
        .ok_or(AppError::NotFound)?;

    // 2. Authorization check: only the owner can update the pool
    if pool_row.owner_id != user.id {
        return Err(AppError::Forbidden);
    }

    // 3. Update status
    let updated = pools::update_pool_status(&state.db, id, &payload.status).await?;

    let response = PoolResponse {
        id: updated.id,
        owner_id: updated.owner_id,
        repo_full_name: updated.repo_full_name,
        funding_amount: updated.funding_amount,
        base_rate: updated.base_rate,
        total_dripped: updated.total_dripped,
        status: updated.status,
    };

    Ok(Json(response))
}
