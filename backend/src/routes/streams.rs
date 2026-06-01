use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use chrono::Utc;
use rust_decimal::prelude::FromPrimitive;
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::auth::middleware::OptionalAuth;
use crate::db::{locale, pools, streams, votes};
use crate::engine::calculator;
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/:id", get(get_stream))
        .route("/:id/vote", post(vote))
}

#[derive(Serialize)]
struct StreamResponse {
    id: Uuid,
    pool_id: Uuid,
    author_id: Uuid,
    pr_number: Option<i32>,
    file_path: String,
    character_count: i32,
    locale: String,
    accumulated: Decimal,
    approval_ratio: f64,
    status: String,
}

#[derive(Deserialize)]
struct VoteRequest {
    is_upvote: bool,
    // Typically we'd extract IP from headers, but passing it in payload or using a mock for V1 is fine.
    // For production we'd use Axum's ConnectInfo extractor.
    voter_ip: Option<String>,
}

/// Compute-on-read stream detail fetcher.
/// This executes the core engine math (pure functions) on demand instead of in a background loop.
async fn get_stream(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    _auth: OptionalAuth,
) -> Result<impl IntoResponse, AppError> {
    // 1. Fetch stream from DB
    let stream_row = streams::get_stream_by_id(&state.db, id)
        .await?
        .ok_or(AppError::NotFound)?;

    // 2. Fetch parent pool to get the base rate
    let pool_row = pools::get_pool_by_id(&state.db, stream_row.pool_id)
        .await?
        .ok_or(AppError::NotFound)?;

    // 3. Fetch locale multipliers (if any exist for this pool)
    let multipliers = locale::get_locale_multipliers(&state.db, stream_row.pool_id).await?;
    let locale_multiplier = multipliers
        .into_iter()
        .find(|m| m.locale == stream_row.locale)
        .map(|m| m.multiplier.to_string().parse::<f64>().unwrap_or(1.0))
        .unwrap_or(1.0);

    // 4. Fetch community approval ratio
    let approval_ratio = votes::get_approval_ratio(&state.db, id).await?;

    // 5. COMPUTE ACCUMULATED (The heart of DocuDrip's engine)
    let base_rate_f64 = pool_row.base_rate.to_string().parse::<f64>().unwrap_or(0.0);
    
    let computed_f64 = calculator::calculate_accumulated(
        stream_row.character_count,
        base_rate_f64,
        locale_multiplier,
        approval_ratio,
        stream_row.created_at,
        Utc::now(),
    );

    // Convert computed value back to Decimal for precise financial presentation
    let computed_decimal = Decimal::from_f64(computed_f64).unwrap_or(Decimal::ZERO);

    // The total accumulated is what was already snapshotted/claimed (in DB) + the newly computed pending portion.
    // For V1 (where streams just accumulate forever until payout phase), accumulated in DB is 0.
    let total_accumulated = stream_row.accumulated + computed_decimal;

    let response = StreamResponse {
        id: stream_row.id,
        pool_id: stream_row.pool_id,
        author_id: stream_row.author_id,
        pr_number: stream_row.pr_number,
        file_path: stream_row.file_path,
        character_count: stream_row.character_count,
        locale: stream_row.locale,
        accumulated: total_accumulated,
        approval_ratio,
        status: stream_row.status,
    };

    Ok(Json(response))
}

/// Anonymous voting endpoint for the embeddable widget.
async fn vote(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    Json(payload): Json<VoteRequest>,
) -> Result<impl IntoResponse, AppError> {
    // 1. Ensure stream exists
    let _ = streams::get_stream_by_id(&state.db, id)
        .await?
        .ok_or(AppError::NotFound)?;

    // 2. Prevent duplicate votes (if IP provided)
    if let Some(ip) = &payload.voter_ip {
        if votes::check_duplicate(&state.db, id, ip).await? {
            return Err(AppError::Conflict("Already voted".into()));
        }
    }

    // 3. Record vote
    votes::record_vote(&state.db, id, payload.voter_ip.as_deref(), payload.is_upvote).await?;

    Ok(StatusCode::CREATED)
}
