use axum::{
    http::StatusCode,
    response::IntoResponse,
    routing::get,
    Json, Router,
};
use serde_json::json;
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;

use crate::state::AppState;

pub mod auth;
pub mod webhooks;
pub mod users;
pub mod pools;
pub mod streams;
pub mod stats;

/// Build the complete Axum router with all route groups and middleware.
pub fn build_router(state: AppState) -> Router {
    let api = Router::new()
        // Health check
        .route("/health", get(health_check))
        .nest("/auth", auth::router())
        .nest("/webhooks", webhooks::router())
        .nest("/users", users::router())
        .nest("/pools", pools::router())
        .nest("/streams", streams::router())
        .nest("/stats", stats::router());

    // Route groups will be added as they're implemented:
    // Phase 2: auth routes (OAuth + callback)
    // Phase 3: pool, stream, vote, stats, webhook routes

    Router::new()
        .nest("/api/v1", api)
        .route("/widget.js", get(serve_widget_js))
        .route("/widget.css", get(serve_widget_css))
        .layer(CorsLayer::permissive()) // Tightened in production
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}

/// Simple health check endpoint — returns 200 OK with server status.
async fn health_check() -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::OK, Json(json!({ "status": "ok" })))
}

/// Serve the embeddable javascript widget directly from the filesystems
async fn serve_widget_js() -> impl IntoResponse {
    let js_content = match std::fs::read_to_string("../widget/src/widget.js") {
        Ok(content) => content,
        Err(_) => match std::fs::read_to_string("widget/src/widget.js") {
            Ok(content) => content,
            Err(_) => "console.error('DocuDrip Widget: widget.js not found');".to_string(),
        }
    };

    (
        [(axum::http::header::CONTENT_TYPE, "application/javascript")],
        js_content,
    )
}

/// Serve the widget styling sheet directly from the filesystems
async fn serve_widget_css() -> impl IntoResponse {
    let css_content = match std::fs::read_to_string("../widget/src/widget.css") {
        Ok(content) => content,
        Err(_) => match std::fs::read_to_string("widget/src/widget.css") {
            Ok(content) => content,
            Err(_) => "/* DocuDrip Widget: widget.css not found */".to_string(),
        }
    };

    (
        [(axum::http::header::CONTENT_TYPE, "text/css")],
        css_content,
    )
}
