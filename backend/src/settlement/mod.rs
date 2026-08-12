use async_trait::async_trait;
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

pub mod stripe_adapter;
pub mod crypto_adapter;
pub mod opencollective_adapter;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SettlementRequest {
    pub claim_id: Uuid,
    pub recipient_ref: String,
    pub amount: Decimal,
    pub currency: String, // "USD" | "USDC"
    pub idempotency_key: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SettlementResult {
    pub provider_tx_ref: String,
    pub settled_amount: Decimal,
    pub fee_amount: Decimal,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SettlementStatus {
    Pending,
    Completed,
    Failed(String),
}

#[derive(Debug, thiserror::Error)]
pub enum SettlementError {
    #[error("Insufficient funds in account or pool")]
    InsufficientFunds,

    #[error("Invalid recipient destination reference: {0}")]
    InvalidRecipient(String),

    #[error("Provider network or API failure: {0}")]
    ProviderError(String),
}

#[async_trait]
pub trait SettlementAdapter: Send + Sync {
    /// Human-readable provider name
    fn provider_name(&self) -> &str;

    /// Execute an automated settlement payout (#4.1)
    async fn execute(
        &self,
        request: SettlementRequest,
    ) -> Result<SettlementResult, SettlementError>;

    /// Check status of a prior settlement execution
    async fn check_status(
        &self,
        provider_tx_ref: &str,
    ) -> Result<SettlementStatus, SettlementError>;
}
