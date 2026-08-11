use axum::{
    extract::{Path, State},
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use chrono::Utc;
use rust_decimal::prelude::*;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::auth::middleware::OptionalAuth;
use crate::db::{locale, pools, streams, votes};
use crate::engine::{calculator, quality_scorer};
use crate::error::AppError;
use crate::middleware::ip_extractor;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_streams))
        .route("/:id", get(get_stream))
        .route("/:id/vote", post(vote_stream))
}

/// Compute-on-read stream list endpoint.
async fn list_streams(
    State(state): State<AppState>,
    _auth: OptionalAuth,
) -> Result<impl IntoResponse, AppError> {
    let rows = streams::list_active_streams(&state.db).await?;
    let mut response = Vec::new();

    for row in rows {
        let multipliers = locale::get_locale_multipliers(&state.db, row.pool_id).await?;
        let _custom_locale_mult = multipliers
            .into_iter()
            .find(|m| m.locale == row.locale)
            .map(|m| m.multiplier.to_string().parse::<f64>().unwrap_or(1.0))
            .unwrap_or(1.0);

        let approval_ratio = votes::get_approval_ratio(&state.db, row.id).await?;

        // Compute dynamic quality score & accumulated rewards (#8.1, #8.2, #8.3)
        let quality_analysis = quality_scorer::analyze_documentation_quality(&row.file_path);
        let base_rate_f64 = row.base_rate.to_string().parse::<f64>().unwrap_or(0.0);
        let computed_f64 = calculator::calculate_accumulated(
            row.character_count,
            base_rate_f64,
            &row.locale,
            approval_ratio,
            quality_analysis.quality_score,
            row.created_at,
            Utc::now(),
        );

        let computed_decimal = Decimal::from_f64(computed_f64).unwrap_or(Decimal::ZERO);
        let total_accumulated = row.accumulated + computed_decimal;

        let feedback_mult = calculator::feedback_multiplier(approval_ratio);
        let loc_mult = calculator::locale_multiplier(&row.locale);
        let flow_rate_per_second = (row.character_count as f64)
            * base_rate_f64
            * loc_mult
            * feedback_mult
            * quality_analysis.quality_score
            / 86_400.0;

        response.push(serde_json::json!({
            "id": row.id,
            "pool_id": row.pool_id,
            "author_id": row.author_id,
            "author_username": row.author_username,
            "pool_repo_name": row.pool_repo_name,
            "pr_number": row.pr_number,
            "file_path": row.file_path,
            "character_count": row.character_count,
            "locale": row.locale,
            "accumulated": total_accumulated,
            "flow_rate_per_second": flow_rate_per_second,
            "approval_ratio": approval_ratio,
            "quality_multiplier": quality_analysis.quality_score,
            "status": row.status,
        }));
    }

    Ok(Json(response))
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
    fingerprint_hash: Option<String>,
    voter_ip: Option<String>,
}

/// Compute-on-read stream detail fetcher.
async fn get_stream(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    _auth: OptionalAuth,
) -> Result<impl IntoResponse, AppError> {
    let stream_row = streams::get_stream_by_id(&state.db, id)
        .await?
        .ok_or(AppError::NotFound)?;

    let pool_row = pools::get_pool_by_id(&state.db, stream_row.pool_id)
        .await?
        .ok_or(AppError::NotFound)?;

    let approval_ratio = votes::get_approval_ratio(&state.db, id).await?;
    let quality_analysis = quality_scorer::analyze_documentation_quality(&stream_row.file_path);

    let base_rate_f64 = pool_row.base_rate.to_string().parse::<f64>().unwrap_or(0.0);

    let computed_f64 = calculator::calculate_accumulated(
        stream_row.character_count,
        base_rate_f64,
        &stream_row.locale,
        approval_ratio,
        quality_analysis.quality_score,
        stream_row.created_at,
        Utc::now(),
    );

    let computed_decimal = Decimal::from_f64(computed_f64).unwrap_or(Decimal::ZERO);
    let total_accumulated = stream_row.accumulated + computed_decimal;

    Ok(Json(serde_json::json!({
        "id": stream_row.id,
        "pool_id": stream_row.pool_id,
        "author_id": stream_row.author_id,
        "pr_number": stream_row.pr_number,
        "file_path": stream_row.file_path,
        "character_count": stream_row.character_count,
        "locale": stream_row.locale,
        "accumulated": total_accumulated,
        "approval_ratio": approval_ratio,
        "quality_multiplier": quality_analysis.quality_score,
        "status": stream_row.status,
        "created_at": stream_row.created_at,
    })))
}

/// Vote submission handler with real IP extraction & anti-sybil fingerprinting (#5.3)
async fn vote_stream(
    State(state): State<AppState>,
    Path(stream_id): Path<Uuid>,
    headers: HeaderMap,
    Json(payload): Json<VoteRequest>,
) -> Result<impl IntoResponse, AppError> {
    let voter_ip = payload
        .voter_ip
        .unwrap_or_else(|| ip_extractor::extract_client_ip(&headers, None));

    let user_agent = headers
        .get("user-agent")
        .and_then(|v| v.to_str().ok())
        .map(|s| s.to_string());

    let registered = votes::record_vote(
        &state.db,
        stream_id,
        &voter_ip,
        payload.is_upvote,
        payload.fingerprint_hash.as_deref(),
        user_agent.as_deref(),
    )
    .await?;

    if !registered {
        return Err(AppError::Conflict("Duplicate vote detected".into()));
    }

    Ok(StatusCode::OK)
}
