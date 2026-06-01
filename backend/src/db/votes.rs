use chrono::{DateTime, Utc};
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug)]
pub struct VoteRow {
    pub id: Uuid,
    pub stream_id: Uuid,
    pub voter_ip: Option<String>,
    pub is_upvote: bool,
    pub created_at: DateTime<Utc>,
}

pub async fn record_vote(
    pool: &PgPool,
    stream_id: Uuid,
    voter_ip: Option<&str>,
    is_upvote: bool,
) -> Result<(), AppError> {
    sqlx::query!(
        r#"
        INSERT INTO votes (stream_id, voter_ip, is_upvote)
        VALUES ($1, $2, $3)
        "#,
        stream_id,
        voter_ip,
        is_upvote
    )
    .execute(pool)
    .await?;

    Ok(())
}

/// Checks if a voter IP has already voted on this stream to prevent duplicate votes
pub async fn check_duplicate(
    pool: &PgPool,
    stream_id: Uuid,
    voter_ip: &str,
) -> Result<bool, AppError> {
    let result = sqlx::query!(
        r#"
        SELECT EXISTS(
            SELECT 1 FROM votes 
            WHERE stream_id = $1 AND voter_ip = $2
        ) as "exists!"
        "#,
        stream_id,
        voter_ip
    )
    .fetch_one(pool)
    .await?;

    Ok(result.exists)
}

/// Returns the approval ratio (upvotes / total_votes) as a float [0.0 - 1.0]
/// Returns 1.0 if there are no votes (innocent until proven guilty)
pub async fn get_approval_ratio(
    pool: &PgPool,
    stream_id: Uuid,
) -> Result<f64, AppError> {
    let result = sqlx::query!(
        r#"
        SELECT 
            COUNT(*) as "total_votes!",
            SUM(CASE WHEN is_upvote THEN 1 ELSE 0 END) as "upvotes"
        FROM votes
        WHERE stream_id = $1
        "#,
        stream_id
    )
    .fetch_one(pool)
    .await?;

    if result.total_votes == 0 {
        return Ok(1.0); // Default perfect score
    }

    let upvotes = result.upvotes.unwrap_or(0);
    Ok(upvotes as f64 / result.total_votes as f64)
}
