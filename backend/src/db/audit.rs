use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, PgPool};
use uuid::Uuid;
use crate::error::AppError;

#[derive(Debug, Serialize, Deserialize, FromRow, Clone)]
pub struct AuditEvent {
    pub id: Uuid,
    pub event_type: String,
    pub actor_id: Option<Uuid>,
    pub resource_type: String,
    pub resource_id: Uuid,
    pub metadata: serde_json::Value,
    pub ip_address: Option<String>,
    pub created_at: DateTime<Utc>,
}

pub async fn log_audit_event(
    pool: &PgPool,
    event_type: &str,
    actor_id: Option<Uuid>,
    resource_type: &str,
    resource_id: Uuid,
    metadata: serde_json::Value,
    ip_address: Option<&str>,
) -> Result<AuditEvent, AppError> {
    let event = sqlx::query_as::<_, AuditEvent>(
        r#"
        INSERT INTO audit_events (event_type, actor_id, resource_type, resource_id, metadata, ip_address)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
        "#,
    )
    .bind(event_type)
    .bind(actor_id)
    .bind(resource_type)
    .bind(resource_id)
    .bind(metadata)
    .bind(ip_address)
    .fetch_one(pool)
    .await?;

    Ok(event)
}

pub async fn list_audit_events_by_resource(
    pool: &PgPool,
    resource_type: &str,
    resource_id: Uuid,
) -> Result<Vec<AuditEvent>, AppError> {
    let events = sqlx::query_as::<_, AuditEvent>(
        "SELECT * FROM audit_events WHERE resource_type = $1 AND resource_id = $2 ORDER BY created_at DESC",
    )
    .bind(resource_type)
    .bind(resource_id)
    .fetch_all(pool)
    .await?;

    Ok(events)
}
