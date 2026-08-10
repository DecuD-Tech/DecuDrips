use axum::{
    http::{header, Method, HeaderValue, StatusCode},
    response::IntoResponse,
    routing::get,
    Json, Router,
};
use serde_json::json;
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;

use crate::state::AppState;

pub mod audit;
pub mod auth;
pub mod claims;
pub mod pools;
pub mod settlement_accounts;
pub mod stats;
pub mod streams;
pub mod users;
pub mod webhooks;

/// Build the complete Axum router with all route groups and middleware.
pub fn build_router(state: AppState) -> Router {
    // Configure strict CORS based on environment configuration (#2.2)
    let origins: Vec<HeaderValue> = state
        .config
        .cors_origin
        .split(',')
        .filter_map(|o| o.trim().parse::<HeaderValue>().ok())
        .collect();

    let cors = if origins.is_empty() {
        CorsLayer::permissive()
    } else {
        CorsLayer::new()
            .allow_origin(origins)
            .allow_methods([Method::GET, Method::POST, Method::PATCH, Method::DELETE])
            .allow_headers([header::AUTHORIZATION, header::CONTENT_TYPE, header::ACCEPT])
            .allow_credentials(true)
    };

    let api = Router::new()
        // Health check
        .route("/health", get(health_check))
        .nest("/auth", auth::router())
        .nest("/webhooks", webhooks::router())
        .nest("/users", users::router())
        .nest("/pools", pools::router())
        .nest("/streams", streams::router())
        .nest("/stats", stats::router())
        .nest("/claims", claims::router())
        .nest("/settlement-accounts", settlement_accounts::router())
        .nest("/audit", audit::router());

    Router::new()
        .nest("/api/v1", api)
        .route("/widget.js", get(serve_widget_js))
        .route("/widget.css", get(serve_widget_css))
        .layer(cors)
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}

/// Simple health check endpoint — returns 200 OK with server status.
async fn health_check() -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::OK, Json(json!({ "status": "ok" })))
}

/// Serve the embeddable javascript widget directly with strict CSP headers (#2.5)
async fn serve_widget_js() -> impl IntoResponse {
    let js_content = match std::fs::read_to_string("../widget/src/widget.js") {
        Ok(content) => content,
        Err(_) => match std::fs::read_to_string("widget/src/widget.js") {
            Ok(content) => content,
            Err(_) => "console.error('DocuDrip Widget: widget.js not found');".to_string(),
        },
    };

    (
        [
            (header::CONTENT_TYPE, "application/javascript"),
            (
                header::CONTENT_SECURITY_POLICY,
                "default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; connect-src 'self'",
            ),
        ],
        js_content,
    )
}

/// Serve the widget styling sheet directly with strict CSP headers (#2.5)
async fn serve_widget_css() -> impl IntoResponse {
    let css_content = match std::fs::read_to_string("../widget/src/widget.css") {
        Ok(content) => content,
        Err(_) => match std::fs::read_to_string("widget/src/widget.css") {
            Ok(content) => content,
            Err(_) => "/* DocuDrip Widget: widget.css not found */".to_string(),
        },
    };

    (
        [
            (header::CONTENT_TYPE, "text/css"),
            (
                header::CONTENT_SECURITY_POLICY,
                "default-src 'none'; style-src 'self' 'unsafe-inline'",
            ),
        ],
        css_content,
    )
}
