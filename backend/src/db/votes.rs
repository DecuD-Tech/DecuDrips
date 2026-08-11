use chrono::{DateTime, Utc};
use sqlx::{FromRow, PgPool};
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug, FromRow)]
pub struct VoteRow {
    pub id: Uuid,
    pub stream_id: Uuid,
    pub voter_ip: Option<String>,
    pub is_upvote: bool,
    pub fingerprint_hash: Option<String>,
    pub user_agent: Option<String>,
    pub created_at: DateTime<Utc>,
}

/// Record a vote with anti-sybil IP + browser fingerprinting (#1.6, #5.3)
pub async fn record_vote(
    pool: &PgPool,
    stream_id: Uuid,
    voter_ip: &str,
    is_upvote: bool,
    fingerprint_hash: Option<&str>,
    user_agent: Option<&str>,
) -> Result<bool, AppError> {
    let result = sqlx::query(
        r#"
        INSERT INTO votes (stream_id, voter_ip, is_upvote, fingerprint_hash, user_agent)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT DO NOTHING
        RETURNING id
        "#,
    )
    .bind(stream_id)
    .bind(voter_ip)
    .bind(is_upvote)
    .bind(fingerprint_hash)
    .bind(user_agent)
    .fetch_optional(pool)
    .await?;

    Ok(result.is_some())
}

/// Returns the approval ratio (upvotes / total_votes) as a float [0.0 - 1.0]
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
        return Ok(1.0);
    }

    let upvotes = result.upvotes.unwrap_or(0);
    Ok(upvotes as f64 / result.total_votes as f64)
}
