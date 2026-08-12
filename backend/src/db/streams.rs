use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use sqlx::{FromRow, PgPool};
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug, FromRow)]
pub struct StreamRow {
    pub id: Uuid,
    pub pool_id: Uuid,
    pub author_id: Uuid,
    pub pr_number: Option<i32>,
    pub file_path: String,
    pub character_count: i32,
    pub locale: String,
    pub accumulated: Decimal,
    pub content_snapshot: Option<String>,
    pub status: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, FromRow)]
pub struct ActiveStreamRow {
    pub id: Uuid,
    pub pool_id: Uuid,
    pub author_id: Uuid,
    pub author_username: String,
    pub pool_repo_name: String,
    pub pr_number: Option<i32>,
    pub file_path: String,
    pub character_count: i32,
    pub locale: String,
    pub accumulated: Decimal,
    pub content_snapshot: Option<String>,
    pub base_rate: Decimal,
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
    content_snapshot: Option<&str>,
    quality_multiplier: Option<f64>,
) -> Result<Uuid, AppError> {
    let row: (Uuid,) = sqlx::query_as(
        r#"
        INSERT INTO streams (pool_id, author_id, pr_number, file_path, character_count, locale, content_snapshot, quality_multiplier)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id
        "#,
    )
    .bind(pool_id)
    .bind(author_id)
    .bind(pr_number)
    .bind(file_path)
    .bind(character_count)
    .bind(locale)
    .bind(content_snapshot)
    .bind(quality_multiplier)
    .fetch_one(pool)
    .await?;

    Ok(row.0)
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

pub async fn list_active_streams(pool: &PgPool) -> Result<Vec<ActiveStreamRow>, AppError> {
    let result = sqlx::query_as::<_, ActiveStreamRow>(
        r#"
        SELECT 
            s.id, s.pool_id, s.author_id, 
            u.username as author_username,
            p.repo_full_name as pool_repo_name,
            s.pr_number, s.file_path, s.character_count, s.locale, s.accumulated, 
            s.content_snapshot, p.base_rate, s.status, s.created_at
        FROM streams s
        JOIN users u ON s.author_id = u.id
        JOIN pools p ON s.pool_id = p.id
        WHERE s.status = 'active'
        ORDER BY s.created_at DESC
        "#
    )
    .fetch_all(pool)
    .await?;

    Ok(result)
}

pub async fn list_streams_by_pool(
    pool: &PgPool,
    pool_id: Uuid,
) -> Result<Vec<StreamRow>, AppError> {
    let result = sqlx::query_as::<_, StreamRow>(
        r#"
        SELECT id, pool_id, author_id, pr_number, file_path, character_count, locale, accumulated, content_snapshot, status, created_at
        FROM streams
        WHERE pool_id = $1
        ORDER BY created_at DESC
        "#
    )
    .bind(pool_id)
    .fetch_all(pool)
    .await?;

    Ok(result)
}

pub async fn get_stream_by_id(pool: &PgPool, id: Uuid) -> Result<Option<StreamRow>, AppError> {
    let result = sqlx::query_as::<_, StreamRow>(
        r#"
        SELECT id, pool_id, author_id, pr_number, file_path, character_count, locale, accumulated, content_snapshot, status, created_at
        FROM streams
        WHERE id = $1
        "#
    )
    .bind(id)
    .fetch_optional(pool)
    .await?;

    Ok(result)
}
