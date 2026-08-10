use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, PgPool};
use uuid::Uuid;
use crate::error::AppError;

#[derive(Debug, Serialize, Deserialize, FromRow, Clone)]
pub struct Claim {
    pub id: Uuid,
    pub stream_id: Uuid,
    pub user_id: Uuid,
    pub amount: Decimal,
    pub status: String,
    pub settlement_id: Option<Uuid>,
    pub provider_tx_ref: Option<String>,
    pub failure_reason: Option<String>,
    pub claimed_at: DateTime<Utc>,
    pub settled_at: Option<DateTime<Utc>>,
}

pub async fn create_claim(
    pool: &PgPool,
    stream_id: Uuid,
    user_id: Uuid,
    amount: Decimal,
    settlement_id: Option<Uuid>,
) -> Result<Claim, AppError> {
    let claim = sqlx::query_as::<_, Claim>(
        r#"
        INSERT INTO claims (stream_id, user_id, amount, status, settlement_id)
        VALUES ($1, $2, $3, 'pending', $4)
        RETURNING *
        "#,
    )
    .bind(stream_id)
    .bind(user_id)
    .bind(amount)
    .bind(settlement_id)
    .fetch_one(pool)
    .await?;

    Ok(claim)
}

pub async fn get_claim_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Claim>, AppError> {
    let claim = sqlx::query_as::<_, Claim>("SELECT * FROM claims WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await?;

    Ok(claim)
}

pub async fn list_claims_by_user(pool: &PgPool, user_id: Uuid) -> Result<Vec<Claim>, AppError> {
    let claims = sqlx::query_as::<_, Claim>(
        "SELECT * FROM claims WHERE user_id = $1 ORDER BY claimed_at DESC",
    )
    .bind(user_id)
    .fetch_all(pool)
    .await?;

    Ok(claims)
}

pub async fn update_claim_status(
    pool: &PgPool,
    id: Uuid,
    status: &str,
    provider_tx_ref: Option<&str>,
    failure_reason: Option<&str>,
) -> Result<Claim, AppError> {
    let settled_at = if status == "settled" { Some(Utc::now()) } else { None };

    let claim = sqlx::query_as::<_, Claim>(
        r#"
        UPDATE claims
        SET status = $2, provider_tx_ref = $3, failure_reason = $4, settled_at = COALESCE($5, settled_at)
        WHERE id = $1
        RETURNING *
        "#,
    )
    .bind(id)
    .bind(status)
    .bind(provider_tx_ref)
    .bind(failure_reason)
    .bind(settled_at)
    .fetch_one(pool)
    .await?;

    Ok(claim)
}
