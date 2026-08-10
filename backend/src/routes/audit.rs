use axum::{
    extract::{Query, State},
    response::IntoResponse,
    routing::get,
    Json, Router,
};
use serde::Deserialize;
use uuid::Uuid;

use crate::auth::middleware::AuthUser;
use crate::db::audit;
use crate::error::AppError;
use crate::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new().route("/", get(get_audit_events))
}

#[derive(Deserialize)]
struct AuditQuery {
    resource_type: String,
    resource_id: Uuid,
}

/// Fetch chronological audit events for a resource (#4.7)
async fn get_audit_events(
    State(state): State<AppState>,
    _user: AuthUser,
    Query(query): Query<AuditQuery>,
) -> Result<impl IntoResponse, AppError> {
    let events = audit::list_audit_events_by_resource(
        &state.db,
        &query.resource_type,
        query.resource_id,
    )
    .await?;

    Ok(Json(events))
}
