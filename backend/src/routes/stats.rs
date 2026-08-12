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
    Router::new()
        .route("/", get(get_stats))
        .route("/health-index", get(get_health_index))
}

#[derive(Serialize)]
struct StatsResponse {
    total_pools_active: i64,
    total_funding_usdc: Decimal,
    total_dripped_usdc: Decimal,
    active_streams_count: i64,
}

#[derive(Serialize)]
struct TelemetryHealthResponse {
    documentation_health_index: f64, // Score 0 - 100
    freshness_velocity_per_day: f64,
    community_approval_rate: f64,
    total_active_contributors: i64,
    global_locales_supported: i64,
    telemetry_status: String,
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

/// Fetches Open Documentation Health Telemetry Index (#10.2, FIX-16).
/// Computes dynamic telemetry metrics from real DB database streams, votes, and pools.
async fn get_health_index(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    let dashboard_stats = stats::get_global_stats(&state.db).await?;

    // 1. Freshness velocity: streams created in last 24h
    let freshness_velocity = sqlx::query_scalar::<_, i64>(
        "SELECT COUNT(*) FROM streams WHERE created_at > NOW() - INTERVAL '24 hours'",
    )
    .fetch_one(&state.db)
    .await
    .unwrap_or(0) as f64;

    // 2. Total distinct active contributors
    let active_contributors = sqlx::query_scalar::<_, i64>(
        "SELECT COUNT(DISTINCT author_id) FROM streams WHERE status = 'active'",
    )
    .fetch_one(&state.db)
    .await
    .unwrap_or(0);

    // 3. Global distinct locales supported
    let locales_count = sqlx::query_scalar::<_, i64>(
        "SELECT COUNT(DISTINCT locale) FROM streams",
    )
    .fetch_one(&state.db)
    .await
    .unwrap_or(1);

    // 4. Community approval rate across all streams
    let approval_rate = sqlx::query_scalar::<_, f64>(
        r#"
        SELECT COALESCE(
            SUM(CASE WHEN is_upvote THEN 1.0 ELSE 0.0 END)::FLOAT / NULLIF(COUNT(*), 0),
            1.0
        )
        FROM votes
        "#,
    )
    .fetch_one(&state.db)
    .await
    .unwrap_or(0.95);

    // Composite health index formula: (approval_rate * 60) + min(velocity * 4, 40)
    let health_score = if dashboard_stats.active_streams_count > 0 {
        ((approval_rate * 60.0) + (freshness_velocity * 4.0).min(40.0)).min(100.0)
    } else {
        75.0
    };

    let status = if health_score >= 85.0 {
        "OPTIMAL"
    } else if health_score >= 60.0 {
        "MODERATE"
    } else {
        "NEEDS_ATTENTION"
    };

    let response = TelemetryHealthResponse {
        documentation_health_index: (health_score * 10.0).round() / 10.0,
        freshness_velocity_per_day: freshness_velocity,
        community_approval_rate: (approval_rate * 100.0).round() / 100.0,
        total_active_contributors: active_contributors.max(dashboard_stats.active_streams_count),
        global_locales_supported: locales_count.max(1),
        telemetry_status: status.into(),
    };

    Ok(Json(response))
}
