use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug)]
pub struct TransactionRow {
    pub id: Uuid,
    pub stream_id: Uuid,
    pub amount: Decimal,
    pub created_at: DateTime<Utc>,
}

pub async fn record_snapshot(
    pool: &PgPool,
    stream_id: Uuid,
    amount: Decimal,
) -> Result<(), AppError> {
    sqlx::query!(
        r#"
        INSERT INTO transactions (stream_id, amount)
        VALUES ($1, $2)
        "#,
        stream_id,
        amount
    )
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn list_transactions_by_stream(
    pool: &PgPool,
    stream_id: Uuid,
) -> Result<Vec<TransactionRow>, AppError> {
    let result = sqlx::query_as!(
        TransactionRow,
        r#"
        SELECT id, stream_id, amount, created_at
        FROM transactions
        WHERE stream_id = $1
        ORDER BY created_at DESC
        "#,
        stream_id
    )
    .fetch_all(pool)
    .await?;

    Ok(result)
}
