use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

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
