use rust_decimal::Decimal;
use sqlx::PgPool;

use crate::error::AppError;

#[derive(Debug)]
pub struct DashboardStats {
    pub total_pools_active: i64,
    pub total_funding_usdc: Decimal,
    pub total_dripped_usdc: Decimal,
    pub active_streams_count: i64,
}

pub async fn get_global_stats(pool: &PgPool) -> Result<DashboardStats, AppError> {
    let result = sqlx::query!(
        r#"
        SELECT 
            (SELECT COUNT(*) FROM pools WHERE status = 'active') as "active_pools!",
            (SELECT COALESCE(SUM(funding_amount), 0) FROM pools) as "total_funding!",
            (SELECT COALESCE(SUM(total_dripped), 0) FROM pools) as "total_dripped!",
            (SELECT COUNT(*) FROM streams WHERE status = 'active') as "active_streams!"
        "#
    )
    .fetch_one(pool)
    .await?;

    Ok(DashboardStats {
        total_pools_active: result.active_pools,
        total_funding_usdc: result.total_funding,
        total_dripped_usdc: result.total_dripped,
        active_streams_count: result.active_streams,
    })
}
