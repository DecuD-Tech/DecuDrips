use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, PgPool};
use uuid::Uuid;
use crate::error::AppError;

#[derive(Debug, Serialize, Deserialize, FromRow, Clone)]
pub struct WidgetNonce {
    pub id: Uuid,
    pub stream_id: Uuid,
    pub nonce: String,
    pub expires_at: DateTime<Utc>,
    pub consumed: bool,
    pub created_at: DateTime<Utc>,
}

pub async fn create_nonce(
    pool: &PgPool,
    stream_id: Uuid,
    nonce: &str,
    ttl_seconds: i64,
) -> Result<WidgetNonce, AppError> {
    let expires_at = Utc::now() + chrono::Duration::seconds(ttl_seconds);

    let item = sqlx::query_as::<_, WidgetNonce>(
        r#"
        INSERT INTO widget_nonces (stream_id, nonce, expires_at)
        VALUES ($1, $2, $3)
        RETURNING *
        "#,
    )
    .bind(stream_id)
    .bind(nonce)
    .bind(expires_at)
    .fetch_one(pool)
    .await?;

    Ok(item)
}

pub async fn validate_and_consume_nonce(
    pool: &PgPool,
    stream_id: Uuid,
    nonce: &str,
) -> Result<bool, AppError> {
    let result = sqlx::query(
        r#"
        UPDATE widget_nonces
        SET consumed = true
        WHERE stream_id = $1 AND nonce = $2 AND consumed = false AND expires_at > NOW()
        "#,
    )
    .bind(stream_id)
    .bind(nonce)
    .execute(pool)
    .await?;

    Ok(result.rows_affected() > 0)
}
