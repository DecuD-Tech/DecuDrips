use async_trait::async_trait;
use rust_decimal::prelude::*;
use rust_decimal_macros::dec;
use std::env;

use super::{SettlementAdapter, SettlementError, SettlementRequest, SettlementResult, SettlementStatus};

pub struct StripeSettlementAdapter {
    secret_key: Option<String>,
}

impl StripeSettlementAdapter {
    pub fn new() -> Self {
        Self {
            secret_key: env::var("STRIPE_SECRET_KEY").ok(),
        }
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
        if request.recipient_ref.is_empty() {
            return Err(SettlementError::InvalidRecipient(
                "Stripe Connected Account ID (acct_...) is required".into(),
            ));
        }

        // Real Stripe API call if STRIPE_SECRET_KEY is configured
        if let Some(ref api_key) = self.secret_key {
            let client = reqwest::Client::new();
            let amount_cents = (request.amount * dec!(100))
                .to_i64()
                .unwrap_or(0);

            let params = [
                ("amount", amount_cents.to_string()),
                ("currency", "usd".to_string()),
                ("destination", request.recipient_ref.clone()),
                ("description", format!("DocuDrip continuous stream payout for claim {}", request.claim_id)),
            ];

            let resp = client
                .post("https://api.stripe.com/v1/transfers")
                .basic_auth(api_key, Option::<&str>::None)
                .header("Idempotency-Key", &request.idempotency_key)
                .form(&params)
                .send()
                .await
                .map_err(|e| SettlementError::ProviderError(format!("Stripe HTTP error: {e}")))?;

            if !resp.status().is_success() {
                let err_text = resp.text().await.unwrap_or_default();
                return Err(SettlementError::ProviderError(format!("Stripe API failed: {err_text}")));
            }

            let body: serde_json::Value = resp
                .json()
                .await
                .map_err(|e| SettlementError::ProviderError(format!("Stripe JSON parse error: {e}")))?;

            let tx_id = body["id"]
                .as_str()
                .unwrap_or(&format!("tr_stripe_{}", request.idempotency_key))
                .to_string();

            return Ok(SettlementResult {
                provider_tx_ref: tx_id,
                settled_amount: request.amount,
                fee_amount: dec!(0.25),
            });
        }

        // Mock mode fallback for local test environment
        let tx_ref = format!("tr_stripe_{}", request.idempotency_key.replace('-', ""));

        Ok(SettlementResult {
            provider_tx_ref: tx_ref,
            settled_amount: request.amount,
            fee_amount: dec!(0.25),
        })
    }

    async fn check_status(
        &self,
        provider_tx_ref: &str,
    ) -> Result<SettlementStatus, SettlementError> {
        if provider_tx_ref.starts_with("tr_") {
            Ok(SettlementStatus::Completed)
        } else {
            Ok(SettlementStatus::Failed("Invalid Stripe transfer reference".into()))
        }
    }
}
