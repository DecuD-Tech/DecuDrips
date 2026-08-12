use std::sync::Arc;
use std::time::Duration;
use sqlx::PgPool;
use tokio::time::sleep;

use crate::db::{audit, claims, settlement_accounts};
use crate::settlement::{
    crypto_adapter::CryptoSettlementAdapter,
    opencollective_adapter::OpenCollectiveSettlementAdapter,
    stripe_adapter::StripeSettlementAdapter,
    SettlementAdapter, SettlementRequest,
};

/// Background Tokio worker loop that polls and processes pending reward claims (FIX-14).
pub async fn start_settlement_worker(db: PgPool) {
    tracing::info!("Starting background claim settlement worker daemon...");

    let stripe_adapter = Arc::new(StripeSettlementAdapter::new());
    let crypto_adapter = Arc::new(CryptoSettlementAdapter::new());
    let oc_adapter = Arc::new(OpenCollectiveSettlementAdapter::new());

    loop {
        if let Err(err) = process_pending_claims(&db, &stripe_adapter, &crypto_adapter, &oc_adapter).await {
            tracing::error!("Error in settlement worker cycle: {:?}", err);
        }

        sleep(Duration::from_secs(10)).await;
    }
}

async fn process_pending_claims(
    db: &PgPool,
    stripe: &Arc<StripeSettlementAdapter>,
    crypto: &Arc<CryptoSettlementAdapter>,
    opencollective: &Arc<OpenCollectiveSettlementAdapter>,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let pending = claims::list_pending_claims(db, 10).await?;
    if pending.is_empty() {
        return Ok(());
    }

    for claim in pending {
        tracing::info!("Processing pending claim {} for amount ${}", claim.id, claim.amount);

        // Lookup linked settlement account if available
        let mut account_type = "usdc_base".to_string();
        let mut recipient_ref = "0x0000000000000000000000000000000000000000".to_string();

        if let Some(account_id) = claim.settlement_id {
            if let Ok(Some(account)) = settlement_accounts::get_settlement_account_by_id(db, account_id).await {
                account_type = account.provider;
                recipient_ref = account.provider_ref;
            }
        }

        let request = SettlementRequest {
            claim_id: claim.id,
            recipient_ref,
            amount: claim.amount,
            currency: if account_type == "stripe" { "USD".into() } else { "USDC".into() },
            idempotency_key: claim.id.to_string(),
        };

        let adapter: &dyn SettlementAdapter = match account_type.as_str() {
            "stripe" => stripe.as_ref(),
            "opencollective" => opencollective.as_ref(),
            _ => crypto.as_ref(),
        };

        match adapter.execute(request).await {
            Ok(result) => {
                claims::update_claim_status(
                    db,
                    claim.id,
                    "settled",
                    Some(&result.provider_tx_ref),
                    None,
                )
                .await?;

                let payload = serde_json::json!({
                    "claim_id": claim.id,
                    "amount": claim.amount,
                    "provider": adapter.provider_name(),
                    "tx_ref": result.provider_tx_ref,
                    "fee": result.fee_amount,
                });

                let _ = audit::log_audit_event(
                    db,
                    "CLAIM_SETTLED",
                    Some(claim.user_id),
                    "claim",
                    claim.id,
                    payload,
                    None,
                )
                .await;

                tracing::info!("Claim {} successfully settled with tx {}", claim.id, result.provider_tx_ref);
            }
            Err(err) => {
                let err_msg = err.to_string();
                claims::update_claim_status(
                    db,
                    claim.id,
                    "failed",
                    None,
                    Some(&err_msg),
                )
                .await?;

                let payload = serde_json::json!({
                    "claim_id": claim.id,
                    "error": err_msg,
                });

                let _ = audit::log_audit_event(
                    db,
                    "CLAIM_SETTLEMENT_FAILED",
                    Some(claim.user_id),
                    "claim",
                    claim.id,
                    payload,
                    None,
                )
                .await;

                tracing::warn!("Claim {} settlement failed: {}", claim.id, err_msg);
            }
        }
    }

    Ok(())
}
