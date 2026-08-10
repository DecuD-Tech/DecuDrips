use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, PgPool};
use uuid::Uuid;
use crate::error::AppError;

#[derive(Debug, Serialize, Deserialize, FromRow, Clone)]
pub struct SettlementAccount {
    pub id: Uuid,
    pub user_id: Uuid,
    pub provider: String,
    pub provider_ref: String,
    pub is_verified: bool,
    pub is_default: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub async fn create_settlement_account(
    pool: &PgPool,
    user_id: Uuid,
    provider: &str,
    provider_ref: &str,
    is_default: bool,
) -> Result<SettlementAccount, AppError> {
    let account = sqlx::query_as::<_, SettlementAccount>(
        r#"
        INSERT INTO settlement_accounts (user_id, provider, provider_ref, is_default)
        VALUES ($1, $2, $3, $4)
        RETURNING *
        "#,
    )
    .bind(user_id)
    .bind(provider)
    .bind(provider_ref)
    .bind(is_default)
    .fetch_one(pool)
    .await?;

    Ok(account)
}

pub async fn list_settlement_accounts_by_user(
    pool: &PgPool,
    user_id: Uuid,
) -> Result<Vec<SettlementAccount>, AppError> {
    let accounts = sqlx::query_as::<_, SettlementAccount>(
        "SELECT * FROM settlement_accounts WHERE user_id = $1 ORDER BY created_at DESC",
    )
    .bind(user_id)
    .fetch_all(pool)
    .await?;

    Ok(accounts)
}

pub async fn delete_settlement_account(
    pool: &PgPool,
    id: Uuid,
    user_id: Uuid,
) -> Result<bool, AppError> {
    let result = sqlx::query("DELETE FROM settlement_accounts WHERE id = $1 AND user_id = $2")
        .bind(id)
        .bind(user_id)
        .execute(pool)
        .await?;

    Ok(result.rows_affected() > 0)
}
