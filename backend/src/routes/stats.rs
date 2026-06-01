use axum::{
    extract::State,
    response::IntoResponse,
    routing::get,
    Json, Router,
};
use rust_decimal::Decimal;
use serde::Serialize;

use crate::db::stats;
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/", get(get_stats))
}

#[derive(Serialize)]
struct StatsResponse {
    total_pools_active: i64,
    total_funding_usdc: Decimal,
    total_dripped_usdc: Decimal,
    active_streams_count: i64,
}

/// Fetches global system statistics for the dashboard.
async fn get_stats(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    let dashboard_stats = stats::get_global_stats(&state.db).await?;

    let response = StatsResponse {
        total_pools_active: dashboard_stats.total_pools_active,
        total_funding_usdc: dashboard_stats.total_funding_usdc,
        total_dripped_usdc: dashboard_stats.total_dripped_usdc,
        active_streams_count: dashboard_stats.active_streams_count,
    };

    Ok(Json(response))
}
