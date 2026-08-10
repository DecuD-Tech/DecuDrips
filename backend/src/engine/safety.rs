use rust_decimal::Decimal;
use rust_decimal_macros::dec;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ClaimValidationError {
    #[error("Claim amount below minimum threshold ($1.00 USDC)")]
    BelowMinimumThreshold,

    #[error("Claim amount exceeds single transaction maximum cap")]
    ExceedsMaxAmount,

    #[error("Claim exceeds maximum pool drawdown percentage limit (25%)")]
    ExceedsPoolPercentage,

    #[error("Insufficient remaining balance reserve in pool")]
    InsufficientPoolReserve,

    #[error("Contributor daily maximum claim frequency limit reached (3 claims/day)")]
    DailyLimitReached,
}

pub struct PoolSafetyConfig {
    pub min_claim_amount: Decimal,
    pub max_claim_amount: Decimal,
    pub max_claims_per_day: u32,
    pub min_pool_reserve: Decimal,
    pub max_claim_percentage: Decimal,
}

impl Default for PoolSafetyConfig {
    fn default() -> Self {
        Self {
            min_claim_amount: dec!(1.00),     // $1.00 minimum threshold (#4.2)
            max_claim_amount: dec!(10000.00), // $10,000 max per claim
            max_claims_per_day: 3,            // Max 3 claims per contributor per 24h
            min_pool_reserve: dec!(10.00),    // Maintain $10 floor reserve
            max_claim_percentage: dec!(0.25), // 25% of pool per transaction limit
        }
    }
}

/// Validates a claim request against safety rules (#4.2)
pub fn validate_claim(
    claim_amount: Decimal,
    pool_remaining: Decimal,
    claims_today: u32,
    config: &PoolSafetyConfig,
) -> Result<(), ClaimValidationError> {
    if claim_amount < config.min_claim_amount {
        return Err(ClaimValidationError::BelowMinimumThreshold);
    }
    if claim_amount > config.max_claim_amount {
        return Err(ClaimValidationError::ExceedsMaxAmount);
    }
    if claim_amount > pool_remaining * config.max_claim_percentage {
        return Err(ClaimValidationError::ExceedsPoolPercentage);
    }
    if pool_remaining - claim_amount < config.min_pool_reserve {
        return Err(ClaimValidationError::InsufficientPoolReserve);
    }
    if claims_today >= config.max_claims_per_day {
        return Err(ClaimValidationError::DailyLimitReached);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_claim() {
        let config = PoolSafetyConfig::default();
        let res = validate_claim(dec!(50.0), dec!(1000.0), 1, &config);
        assert!(res.is_ok());
    }

    #[test]
    fn test_below_minimum_rejected() {
        let config = PoolSafetyConfig::default();
        let res = validate_claim(dec!(0.50), dec!(1000.0), 0, &config);
        assert!(matches!(res, Err(ClaimValidationError::BelowMinimumThreshold)));
    }

    #[test]
    fn test_percentage_cap_exceeded() {
        let config = PoolSafetyConfig::default();
        let res = validate_claim(dec!(300.0), dec!(1000.0), 0, &config);
        assert!(matches!(res, Err(ClaimValidationError::ExceedsPoolPercentage)));
    }
}
