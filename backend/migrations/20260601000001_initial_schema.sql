-- DocuDrip V1 — Initial Schema
-- All tables, constraints, and indexes for the micro-funding protocol.

-- Users (populated from GitHub OAuth)
CREATE TABLE users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    github_id   BIGINT UNIQUE NOT NULL,
    username    TEXT NOT NULL,
    avatar_url  TEXT,
    role        TEXT NOT NULL DEFAULT 'contributor',  -- 'contributor' | 'sponsor' | 'admin'
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reward Pools (created by sponsors)
CREATE TABLE pools (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id        UUID NOT NULL REFERENCES users(id),
    repo_full_name  TEXT NOT NULL,              -- e.g. 'stellar/stellar-sdk-js'
    funding_amount  DECIMAL(18, 6) NOT NULL,    -- total USDC deposited
    base_rate       DECIMAL(12, 8) NOT NULL,    -- USDC per character per day
    total_dripped   DECIMAL(18, 6) NOT NULL DEFAULT 0,
    status          TEXT NOT NULL DEFAULT 'active',  -- 'active' | 'paused' | 'exhausted'
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Locale Multipliers (per pool, optional per-locale boost)
CREATE TABLE locale_multipliers (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pool_id     UUID NOT NULL REFERENCES pools(id) ON DELETE CASCADE,
    locale      TEXT NOT NULL,       -- ISO 639-1: 'es', 'zh', 'de', etc.
    multiplier  DECIMAL(4, 2) NOT NULL DEFAULT 1.0,
    UNIQUE(pool_id, locale)
);

-- Drip Streams (one per merged doc contribution)
CREATE TABLE streams (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pool_id         UUID NOT NULL REFERENCES pools(id),
    author_id       UUID NOT NULL REFERENCES users(id),
    pr_number       INT,
    file_path       TEXT NOT NULL,
    character_count INT NOT NULL,
    locale          TEXT NOT NULL DEFAULT 'en',
    accumulated     DECIMAL(18, 8) NOT NULL DEFAULT 0,
    status          TEXT NOT NULL DEFAULT 'active',  -- 'active' | 'paused' | 'completed'
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Helpfulness Votes (anonymous, from widget)
CREATE TABLE votes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stream_id   UUID NOT NULL REFERENCES streams(id) ON DELETE CASCADE,
    voter_ip    TEXT,                -- anonymous voting (no auth required)
    is_upvote   BOOLEAN NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Transaction Ledger (snapshots on claim/withdrawal — not written on every tick)
CREATE TABLE transactions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stream_id   UUID NOT NULL REFERENCES streams(id),
    amount      DECIMAL(18, 8) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Webhook Event Log (audit trail + idempotency via delivery_id)
CREATE TABLE webhook_events (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id TEXT UNIQUE NOT NULL,  -- GitHub's X-GitHub-Delivery header
    event_type  TEXT NOT NULL,
    payload     JSONB NOT NULL,
    processed   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Performance Indexes
CREATE INDEX idx_streams_pool_id ON streams(pool_id);
CREATE INDEX idx_streams_author_id ON streams(author_id);
CREATE INDEX idx_streams_status ON streams(status);
CREATE INDEX idx_votes_stream_id ON votes(stream_id);
CREATE INDEX idx_transactions_stream_id ON transactions(stream_id);
CREATE INDEX idx_pools_status ON pools(status);
CREATE INDEX idx_webhook_events_delivery_id ON webhook_events(delivery_id);
