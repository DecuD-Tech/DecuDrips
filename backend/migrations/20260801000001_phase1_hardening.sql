-- DocuDrip Phase 1 Hardening Migration
-- Resolves Issues #1.1, #1.2, #1.3, #1.4, #1.5, #1.6

-- #1.2 Settlement Accounts (Linking users to payout destinations)
CREATE TABLE settlement_accounts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider        TEXT NOT NULL, -- 'stripe' | 'opencollective' | 'usdc_base' | 'lightning'
    provider_ref    TEXT NOT NULL, -- External account ID or wallet address
    is_verified     BOOLEAN NOT NULL DEFAULT false,
    is_default      BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, provider, provider_ref)
);
CREATE INDEX idx_settlement_accounts_user ON settlement_accounts(user_id);

-- #1.1 Claims (Tracking reward withdrawal state machine)
CREATE TABLE claims (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stream_id       UUID NOT NULL REFERENCES streams(id),
    user_id         UUID NOT NULL REFERENCES users(id),
    amount          DECIMAL(18, 8) NOT NULL,
    status          TEXT NOT NULL DEFAULT 'pending',
    settlement_id   UUID REFERENCES settlement_accounts(id),
    provider_tx_ref TEXT,
    failure_reason  TEXT,
    claimed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    settled_at      TIMESTAMPTZ,
    CHECK (amount > 0),
    CHECK (status IN ('pending', 'processing', 'settled', 'failed', 'cancelled'))
);
CREATE INDEX idx_claims_stream ON claims(stream_id);
CREATE INDEX idx_claims_user ON claims(user_id);
CREATE INDEX idx_claims_status ON claims(status);

-- #1.3 Audit Events (Immutable append-only system & user action log)
CREATE TABLE audit_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type      TEXT NOT NULL,
    actor_id        UUID REFERENCES users(id) ON DELETE SET NULL,
    resource_type   TEXT NOT NULL,
    resource_id     UUID NOT NULL,
    metadata        JSONB NOT NULL DEFAULT '{}',
    ip_address      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audit_resource ON audit_events(resource_type, resource_id);
CREATE INDEX idx_audit_actor ON audit_events(actor_id);
CREATE INDEX idx_audit_event_type ON audit_events(event_type);
CREATE INDEX idx_audit_created ON audit_events(created_at);

-- #1.4 Widget Nonces (Ephemeral single-use tokens for anti-sybil vote authentication)
CREATE TABLE widget_nonces (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stream_id   UUID NOT NULL REFERENCES streams(id) ON DELETE CASCADE,
    nonce       TEXT NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ NOT NULL,
    consumed    BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_nonces_stream ON widget_nonces(stream_id);
CREATE INDEX idx_nonces_expiry ON widget_nonces(expires_at);

-- #1.5 Webhook Events Expiration (Time-bounded replay cleanup column)
ALTER TABLE webhook_events ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours';
CREATE INDEX IF NOT EXISTS idx_webhook_events_expires ON webhook_events(expires_at);

-- #1.6 Votes Anti-Sybil Extensions (Browser fingerprinting, user agent, time decay)
ALTER TABLE votes ADD COLUMN IF NOT EXISTS fingerprint_hash TEXT;
ALTER TABLE votes ADD COLUMN IF NOT EXISTS user_agent TEXT;
ALTER TABLE votes ADD COLUMN IF NOT EXISTS decay_weight DECIMAL(4, 3) NOT NULL DEFAULT 1.000;
CREATE UNIQUE INDEX IF NOT EXISTS idx_votes_dedup ON votes(stream_id, voter_ip, fingerprint_hash);
