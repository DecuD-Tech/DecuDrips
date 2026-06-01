use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug)]
pub struct StreamRow {
    pub id: Uuid,
    pub pool_id: Uuid,
    pub author_id: Uuid,
    pub pr_number: Option<i32>,
    pub file_path: String,
    pub character_count: i32,
    pub locale: String,
    pub accumulated: Decimal,
    pub status: String,
    pub created_at: DateTime<Utc>,
}

/// Creates a new stream (called by the webhook handler).
pub async fn create_stream(
    pool: &PgPool,
    pool_id: Uuid,
    author_id: Uuid,
    pr_number: i32,
    file_path: &str,
    character_count: i32,
    locale: &str,
) -> Result<Uuid, AppError> {
    let result = sqlx::query!(
        r#"
        INSERT INTO streams (pool_id, author_id, pr_number, file_path, character_count, locale)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id
        "#,
        pool_id,
        author_id,
        pr_number,
        file_path,
        character_count,
        locale,
    )
    .fetch_one(pool)
    .await?;

    Ok(result.id)
}

/// Finds the first active pool matching the repo full name.
pub async fn find_active_pool_for_repo(
    pool: &PgPool,
    repo_full_name: &str,
) -> Result<Option<Uuid>, AppError> {
    let result = sqlx::query!(
        r#"
        SELECT id
        FROM pools
        WHERE repo_full_name = $1 AND status = 'active'
        ORDER BY created_at ASC
        LIMIT 1
        "#,
        repo_full_name
    )
    .fetch_optional(pool)
    .await?;

    Ok(result.map(|r| r.id))
}

pub async fn list_streams_by_pool(
    pool: &PgPool,
    pool_id: Uuid,
) -> Result<Vec<StreamRow>, AppError> {
    let result = sqlx::query_as!(
        StreamRow,
        r#"
        SELECT id, pool_id, author_id, pr_number, file_path, character_count, locale, accumulated, status, created_at
        FROM streams
        WHERE pool_id = $1
        ORDER BY created_at DESC
        "#,
        pool_id
    )
    .fetch_all(pool)
    .await?;

    Ok(result)
}

pub async fn get_stream_by_id(pool: &PgPool, id: Uuid) -> Result<Option<StreamRow>, AppError> {
    let result = sqlx::query_as!(
        StreamRow,
        r#"
        SELECT id, pool_id, author_id, pr_number, file_path, character_count, locale, accumulated, status, created_at
        FROM streams
        WHERE id = $1
        "#,
        id
    )
    .fetch_optional(pool)
    .await?;

    Ok(result)
}
