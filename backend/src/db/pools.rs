use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug)]
pub struct PoolRow {
    pub id: Uuid,
    pub owner_id: Uuid,
    pub repo_full_name: String,
    pub funding_amount: Decimal,
    pub base_rate: Decimal,
    pub total_dripped: Decimal,
    pub status: String,
    pub created_at: DateTime<Utc>,
}

pub async fn create_pool(
    pool: &PgPool,
    owner_id: Uuid,
    repo_full_name: &str,
    funding_amount: Decimal,
    base_rate: Decimal,
) -> Result<PoolRow, AppError> {
    let result = sqlx::query_as!(
        PoolRow,
        r#"
        INSERT INTO pools (owner_id, repo_full_name, funding_amount, base_rate)
        VALUES ($1, $2, $3, $4)
        RETURNING id, owner_id, repo_full_name, funding_amount, base_rate, total_dripped, status, created_at
        "#,
        owner_id,
        repo_full_name,
        funding_amount,
        base_rate
    )
    .fetch_one(pool)
    .await?;

    Ok(result)
}

pub async fn list_active_pools(pool: &PgPool) -> Result<Vec<PoolRow>, AppError> {
    let result = sqlx::query_as!(
        PoolRow,
        r#"
        SELECT id, owner_id, repo_full_name, funding_amount, base_rate, total_dripped, status, created_at
        FROM pools
        WHERE status = 'active'
        ORDER BY created_at DESC
        "#
    )
    .fetch_all(pool)
    .await?;

    Ok(result)
}

pub async fn get_pool_by_id(pool: &PgPool, id: Uuid) -> Result<Option<PoolRow>, AppError> {
    let result = sqlx::query_as!(
        PoolRow,
        r#"
        SELECT id, owner_id, repo_full_name, funding_amount, base_rate, total_dripped, status, created_at
        FROM pools
        WHERE id = $1
        "#,
        id
    )
    .fetch_optional(pool)
    .await?;

    Ok(result)
}

pub async fn update_pool_status(
    pool: &PgPool,
    id: Uuid,
    status: &str,
) -> Result<PoolRow, AppError> {
    let result = sqlx::query_as!(
        PoolRow,
        r#"
        UPDATE pools
        SET status = $2
        WHERE id = $1
        RETURNING id, owner_id, repo_full_name, funding_amount, base_rate, total_dripped, status, created_at
        "#,
        id,
        status
    )
    .fetch_one(pool)
    .await?;

    Ok(result)
}
