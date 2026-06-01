use axum::{
    http::StatusCode,
    routing::get,
    Json, Router,
};
use serde_json::json;
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;

use crate::state::AppState;

/// Build the complete Axum router with all route groups and middleware.
pub fn build_router(state: AppState) -> Router {
    let api = Router::new()
        // Health check
        .route("/health", get(health_check));

    // Route groups will be added as they're implemented:
    // Phase 2: auth routes (OAuth + callback)
    // Phase 3: pool, stream, vote, stats, webhook routes

    Router::new()
        .nest("/api/v1", api)
        .layer(CorsLayer::permissive()) // Tightened in production
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}

/// Simple health check endpoint — returns 200 OK with server status.
async fn health_check() -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::OK, Json(json!({ "status": "ok" })))
}
