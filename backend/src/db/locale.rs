use rust_decimal::Decimal;
use sqlx::PgPool;
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug)]
pub struct LocaleMultiplierRow {
    pub id: Uuid,
    pub pool_id: Uuid,
    pub locale: String,
    pub multiplier: Decimal,
}

pub async fn set_locale_multiplier(
    pool: &PgPool,
    pool_id: Uuid,
    locale: &str,
    multiplier: Decimal,
) -> Result<(), AppError> {
    sqlx::query!(
        r#"
        INSERT INTO locale_multipliers (pool_id, locale, multiplier)
        VALUES ($1, $2, $3)
        ON CONFLICT (pool_id, locale) DO UPDATE
        SET multiplier = EXCLUDED.multiplier
        "#,
        pool_id,
        locale,
        multiplier
    )
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn get_locale_multipliers(
    pool: &PgPool,
    pool_id: Uuid,
) -> Result<Vec<LocaleMultiplierRow>, AppError> {
    let result = sqlx::query_as!(
        LocaleMultiplierRow,
        r#"
        SELECT id, pool_id, locale, multiplier
        FROM locale_multipliers
        WHERE pool_id = $1
        "#,
        pool_id
    )
    .fetch_all(pool)
    .await?;

    Ok(result)
}
