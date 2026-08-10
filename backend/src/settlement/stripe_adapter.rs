use async_trait::async_trait;
use rust_decimal::Decimal;
use rust_decimal_macros::dec;
use super::{SettlementAdapter, SettlementError, SettlementRequest, SettlementResult, SettlementStatus};

pub struct StripeSettlementAdapter;

impl StripeSettlementAdapter {
    pub fn new() -> Self {
        Self
    }
}

#[async_trait]
impl SettlementAdapter for StripeSettlementAdapter {
    fn provider_name(&self) -> &str {
        "stripe"
    }

    async fn execute(
        &self,
        request: SettlementRequest,
    ) -> Result<SettlementResult, SettlementError> {
        // Stripe Connect payout execution using claim idempotency key (#4.3)
        if request.recipient_ref.is_empty() {
            return Err(SettlementError::InvalidRecipient(
                "Stripe Account ID is required".into(),
            ));
        }

        // Mock/Sandbox settlement completion receipt
        let tx_ref = format!("tr_stripe_{}", request.idempotency_key);

        Ok(SettlementResult {
            provider_tx_ref: tx_ref,
            settled_amount: request.amount,
            fee_amount: dec!(0.25), // $0.25 flat Stripe payout fee
        })
    }

    async fn check_status(
        &self,
        provider_tx_ref: &str,
    ) -> Result<SettlementStatus, SettlementError> {
        if provider_tx_ref.contains("stripe") {
            Ok(SettlementStatus::Completed)
        } else {
            Ok(SettlementStatus::Failed("Invalid tx ref".into()))
        }
    }
}
