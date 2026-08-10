use sqlx::PgPool;
use uuid::Uuid;
use crate::db::audit::{log_audit_event, AuditEvent};
use crate::error::AppError;

/// Asynchronously log an audit event to the append-only ledger (#2.4)
pub async fn record_event(
    pool: &PgPool,
    event_type: &str,
    actor_id: Option<Uuid>,
    resource_type: &str,
    resource_id: Uuid,
    metadata: serde_json::Value,
    ip_address: Option<&str>,
) -> Result<AuditEvent, AppError> {
    log_audit_event(
        pool,
        event_type,
        actor_id,
        resource_type,
        resource_id,
        metadata,
        ip_address,
    )
    .await
}
