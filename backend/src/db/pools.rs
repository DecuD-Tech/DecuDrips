use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use sqlx::{FromRow, PgPool};
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug, FromRow)]
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

#[derive(Debug, FromRow)]
pub struct CorporateMatchConfig {
    pub match_ratio: f64,       // e.g. 1.0 for 1:1 match
    pub sponsor_name: String,   // e.g. "Vercel / GitHub Fund"
    pub max_match_amount: Decimal,
}

pub async fn create_pool(
    pool: &PgPool,
    owner_id: Uuid,
    repo_full_name: &str,
    funding_amount: Decimal,
    base_rate: Decimal,
) -> Result<PoolRow, AppError> {
    let result = sqlx::query_as::<_, PoolRow>(
        r#"
        INSERT INTO pools (owner_id, repo_full_name, funding_amount, base_rate)
        VALUES ($1, $2, $3, $4)
        RETURNING id, owner_id, repo_full_name, funding_amount, base_rate, total_dripped, status, created_at
        "#,
    )
    .bind(owner_id)
    .bind(repo_full_name)
    .bind(funding_amount)
    .bind(base_rate)
    .fetch_one(pool)
    .await?;

    Ok(result)
}

pub async fn list_active_pools(pool: &PgPool) -> Result<Vec<PoolRow>, AppError> {
    let result = sqlx::query_as::<_, PoolRow>(
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
    let result = sqlx::query_as::<_, PoolRow>(
        r#"
        SELECT id, owner_id, repo_full_name, funding_amount, base_rate, total_dripped, status, created_at
        FROM pools
        WHERE id = $1
        "#
    )
    .bind(id)
    .fetch_optional(pool)
    .await?;

    Ok(result)
}

pub async fn update_pool_status(
    pool: &PgPool,
    id: Uuid,
    status: &str,
) -> Result<PoolRow, AppError> {
    let result = sqlx::query_as::<_, PoolRow>(
        r#"
        UPDATE pools
        SET status = $2
        WHERE id = $1
        RETURNING id, owner_id, repo_full_name, funding_amount, base_rate, total_dripped, status, created_at
        "#
    )
    .bind(id)
    .bind(status)
    .fetch_one(pool)
    .await?;

    Ok(result)
}

/// Calculate corporate match funding multiplier for a given pool (#10.1)
pub fn get_corporate_match_multiplier(match_ratio: f64) -> f64 {
    (1.0 + match_ratio).clamp(1.0, 3.0)
}
