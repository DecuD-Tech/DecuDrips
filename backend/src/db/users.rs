use chrono::{DateTime, Utc};
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug)]
pub struct UserRow {
    pub id: Uuid,
    pub github_id: i64,
    pub username: String,
    pub avatar_url: Option<String>,
    pub role: String,
    pub created_at: DateTime<Utc>,
}

/// Upserts a user from GitHub OAuth data.
pub async fn upsert_from_github(
    pool: &PgPool,
    github_id: i64,
    username: &str,
    avatar_url: Option<&str>,
) -> Result<UserRow, AppError> {
    let user = sqlx::query_as!(
        UserRow,
        r#"
        INSERT INTO users (github_id, username, avatar_url)
        VALUES ($1, $2, $3)
        ON CONFLICT (github_id) DO UPDATE
        SET username = EXCLUDED.username,
            avatar_url = EXCLUDED.avatar_url
        RETURNING id, github_id, username, avatar_url, role, created_at
        "#,
        github_id,
        username,
        avatar_url,
    )
    .fetch_one(pool)
    .await?;

    Ok(user)
}

/// Gets a user by their internal UUID.
pub async fn get_by_id(pool: &PgPool, id: Uuid) -> Result<Option<UserRow>, AppError> {
    let user = sqlx::query_as!(
        UserRow,
        r#"
        SELECT id, github_id, username, avatar_url, role, created_at
        FROM users
        WHERE id = $1
        "#,
        id
    )
    .fetch_optional(pool)
    .await?;

    Ok(user)
}
