use std::sync::Arc;
use governor::middleware::NoOpMiddleware;
use tower_governor::{
    governor::GovernorConfigBuilder,
    key_extractor::PeerIpKeyExtractor,
    GovernorLayer,
};

/// Configures rate-limiting layers for anonymous and authenticated API endpoints (#2.3).

pub fn build_anonymous_rate_limiter() -> GovernorLayer<PeerIpKeyExtractor, NoOpMiddleware> {
    // 10 requests per minute per IP for sensitive anonymous endpoints (nonce generation, vote submission)
    let config = Arc::new(
        GovernorConfigBuilder::default()
            .per_second(6) // 1 token replenished every 6 seconds (10 requests/minute)
            .burst_size(10)
            .finish()
            .unwrap(),
    );

    GovernorLayer { config }
}

pub fn build_authenticated_rate_limiter() -> GovernorLayer<PeerIpKeyExtractor, NoOpMiddleware> {
    // 60 requests per minute per IP for authenticated operations (claims, account management)
    let config = Arc::new(
        GovernorConfigBuilder::default()
            .per_second(1) // 1 token replenished every second (60 requests/minute)
            .burst_size(60)
            .finish()
            .unwrap(),
    );

    GovernorLayer { config }
}
