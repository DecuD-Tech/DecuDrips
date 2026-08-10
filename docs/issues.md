# 📋 DocuDrip — Detailed Master Issue Specification Index

This document serves as the authoritative local technical specification for every issue in the DocuDrip monorepo (**Backend**, **Frontend**, **Widget**, **Mobile**, and **Infrastructure**). Each issue contains detailed implementation steps, code schemas, file targets, and acceptance criteria.

---

## 🔒 Phase 1: Core Protocol Hardening & Settlement Engine

---

### Epic 1: Database Phase 1 Schema Migration (`[database]`)

- [x] **#1.1** `[database]` `[schema]` Create `claims` table migration with status constraints (`pending`, `processing`, `settled`, `failed`, `cancelled`)
- [x] **#1.2** `[database]` `[schema]` Create `settlement_accounts` table migration with unique user/provider constraints
- [x] **#1.3** `[database]` `[schema]` Create `audit_events` append-only log table migration with indexes
- [x] **#1.4** `[database]` `[schema]` Create `widget_nonces` ephemeral token table migration with expiration indexes
- [x] **#1.5** `[database]` `[schema]` Add `expires_at` column & index to `webhook_events` table
- [x] **#1.6** `[database]` `[schema]` Add `fingerprint_hash`, `user_agent`, `decay_weight` & compound index to `votes` table

#### #1.1 Create `claims` table migration with status constraints
* **Target File:** `backend/migrations/20260801000001_phase1_hardening.sql`
* **Subsystem:** `backend` / `database`
* **Description:** Create PostgreSQL table `claims` to track contributor reward withdrawal lifecycles (`pending`, `processing`, `settled`, `failed`, `cancelled`).
* **Implementation Details:**
  ```sql
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
  ```
* **Acceptance Criteria:** `sqlx migrate run` applies cleanly without syntax errors.

---

#### #1.2 Create `settlement_accounts` table migration
* **Target File:** `backend/migrations/20260801000001_phase1_hardening.sql`
* **Subsystem:** `backend` / `database`
* **Description:** Create `settlement_accounts` table linking users to verified payout destinations (Stripe Connect ID, Base/Polygon USDC wallet address, Lightning LNURL, OpenCollective ID).
* **Implementation Details:**
  ```sql
  CREATE TABLE settlement_accounts (
      id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id         UUID NOT NULL REFERENCES users(id),
      provider        TEXT NOT NULL, -- 'stripe', 'opencollective', 'usdc_base', 'lightning'
      provider_ref    TEXT NOT NULL,
      is_verified     BOOLEAN NOT NULL DEFAULT false,
      is_default      BOOLEAN NOT NULL DEFAULT false,
      created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE(user_id, provider, provider_ref)
  );
  ```
* **Acceptance Criteria:** Duplicate user provider references trigger a unique constraint violation (`409 Conflict`).

---

#### #1.3 Create `audit_events` append-only log table migration
* **Target File:** `backend/migrations/20260801000001_phase1_hardening.sql`
* **Subsystem:** `backend` / `database`
* **Description:** Create immutable append-only `audit_events` log table storing cryptographic event history for claims, pools, webhooks, and votes.
* **Implementation Details:**
  ```sql
  CREATE TABLE audit_events (
      id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      event_type      TEXT NOT NULL,
      actor_id        UUID,
      resource_type   TEXT NOT NULL,
      resource_id     UUID NOT NULL,
      metadata        JSONB NOT NULL DEFAULT '{}',
      ip_address      TEXT,
      created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );
  CREATE INDEX idx_audit_resource ON audit_events(resource_type, resource_id);
  CREATE INDEX idx_audit_actor ON audit_events(actor_id);
  ```
* **Acceptance Criteria:** Fast queries on `resource_type` and `resource_id` (< 5ms execution time).

---

#### #1.4 Create `widget_nonces` ephemeral token table migration
* **Target File:** `backend/migrations/20260801000001_phase1_hardening.sql`
* **Subsystem:** `backend` / `database`
* **Description:** Ephemeral token table for anti-sybil widget vote authentication with short-lived TTLs (5 mins).
* **Implementation Details:**
  ```sql
  CREATE TABLE widget_nonces (
      id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      stream_id   UUID NOT NULL REFERENCES streams(id),
      nonce       TEXT NOT NULL UNIQUE,
      expires_at  TIMESTAMPTZ NOT NULL,
      consumed    BOOLEAN NOT NULL DEFAULT false,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );
  CREATE INDEX idx_nonces_stream ON widget_nonces(stream_id);
  CREATE INDEX idx_nonces_expiry ON widget_nonces(expires_at);
  ```
* **Acceptance Criteria:** Nonce validation queries check both `consumed = false` and `expires_at > NOW()`.

---

#### #1.5 Add `expires_at` column & index to `webhook_events` table
* **Target File:** `backend/migrations/20260801000001_phase1_hardening.sql`
* **Subsystem:** `backend` / `database`
* **Description:** Add timestamp expiration tracking to `webhook_events` to enable automatic cleanup of old webhook delivery IDs.
* **Implementation Details:**
  ```sql
  ALTER TABLE webhook_events ADD COLUMN expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours';
  CREATE INDEX idx_webhook_events_expires ON webhook_events(expires_at);
  ```
* **Acceptance Criteria:** Cleanup cron/job purges expired delivery events older than 24 hours.

---

#### #1.6 Add fingerprint_hash, user_agent, decay_weight & compound index to `votes` table
* **Target File:** `backend/migrations/20260801000001_phase1_hardening.sql`
* **Subsystem:** `backend` / `database`
* **Description:** Extend `votes` table with anti-sybil browser fingerprinting, user agent string, and vote time-decay weight.
* **Implementation Details:**
  ```sql
  ALTER TABLE votes ADD COLUMN fingerprint_hash TEXT;
  ALTER TABLE votes ADD COLUMN user_agent TEXT;
  ALTER TABLE votes ADD COLUMN decay_weight DECIMAL(4, 3) NOT NULL DEFAULT 1.000;
  CREATE UNIQUE INDEX idx_votes_dedup ON votes(stream_id, voter_ip, fingerprint_hash);
  ```
* **Acceptance Criteria:** Prevents duplicate voting from same IP + browser fingerprint combination.

---

### Epic 2: Server Security, Middleware & Audit Engine (`[backend]`)
- [x] **#2.1** `[backend]` `[security]` Build `ip_extractor.rs` middleware parsing `X-Forwarded-For`, `X-Real-IP`, and socket info
- [x] **#2.2** `[backend]` `[security]` Replace `CorsLayer::permissive()` with configurable `CORS_ALLOWED_ORIGINS` allowlist
- [ ] **#2.3** `[backend]` `[security]` Integrate `tower-governor` token-bucket rate limiter across anonymous and authed routes
- [x] **#2.4** `[backend]` `[audit]` Build `audit::log_event()` logger module and database query helpers
- [x] **#2.5** `[backend]` `[security]` Inject Content-Security-Policy (CSP) headers into static asset routes (`/widget.js`)

#### #2.1 Build `ip_extractor.rs` middleware for client IP resolution
* **Target File:** `backend/src/middleware/ip_extractor.rs`
* **Subsystem:** `backend` / `security`
* **Description:** Extract real client IP addresses, prioritizing `X-Forwarded-For` and `X-Real-IP` reverse proxy headers over raw socket `ConnectInfo`.
* **Implementation Details:**
  ```rust
  pub fn extract_client_ip(headers: &HeaderMap, connect_info: Option<&ConnectInfo<SocketAddr>>) -> String {
      if let Some(forwarded) = headers.get("X-Forwarded-For") {
          if let Ok(v) = forwarded.to_str() {
              if let Some(first) = v.split(',').next() {
                  return first.trim().to_string();
              }
          }
      }
      connect_info.map(|ci| ci.0.ip().to_string()).unwrap_or_else(|| "127.0.0.1".into())
  }
  ```
* **Acceptance Criteria:** Unit tests verify correct extraction under proxy headers and fallback states.

---

#### #2.2 Replace `CorsLayer::permissive()` with environment-driven CORS allowlist
* **Target File:** `backend/src/routes/mod.rs`
* **Subsystem:** `backend` / `security`
* **Description:** Replace wildcard permissive CORS with explicit `CORS_ALLOWED_ORIGINS` comma-separated environment configuration.
* **Implementation Details:** Configure `CorsLayer::new().allow_origin(...)` with allowed methods `GET, POST, PATCH, DELETE` and credentials support.
* **Acceptance Criteria:** Requests from non-allowlisted origins return CORS preflight failure in browsers.

---

#### #2.3 Integrate `tower-governor` token-bucket rate limiter
* **Target File:** `backend/src/routes/mod.rs` & `Cargo.toml`
* **Subsystem:** `backend` / `security`
* **Description:** Rate limit anonymous vote submissions (10 req/min/IP) and authenticated routes (60 req/min/user).
* **Acceptance Criteria:** Exceeding limit returns `429 Too Many Requests`.

---

#### #2.4 Build `audit::log_event()` logger module and database query helpers
* **Target File:** `backend/src/audit/mod.rs`
* **Subsystem:** `backend` / `security`
* **Description:** Helper module to record structured system audit entries into `audit_events`.
* **Acceptance Criteria:** Asynchronous logging does not block HTTP response handlers.

---

#### #2.5 Inject Content-Security-Policy (CSP) headers into static asset routes
* **Target File:** `backend/src/routes/mod.rs`
* **Subsystem:** `backend` / `widget` / `security`
* **Description:** Inject strict CSP headers for `/widget.js` static asset delivery.
* **Acceptance Criteria:** Header `Content-Security-Policy: default-src 'none'; script-src 'self'` returned on static asset requests.

---

### Epic 3: Webhook & Ingestion Hardening (`[backend]`)

#### #3.1 Implement `X-GitHub-Hook-Timestamp` 5-minute replay window validation
* **Target File:** `backend/src/routes/webhooks.rs`
* **Subsystem:** `backend` / `webhook`
* **Description:** Validate incoming `X-GitHub-Hook-Timestamp` is within a 5-minute (300 seconds) window.
* **Acceptance Criteria:** Webhooks older than 300 seconds are rejected with `400 Bad Request`.

---

#### #3.2 Build AST-aware Markdown diff parser module (`engine/diff_parser.rs`)
* **Target File:** `backend/src/engine/diff_parser.rs`
* **Subsystem:** `backend` / `webhook`
* **Description:** Analyze unified diff hunks and extract only meaningful prose/code additions.
* **Acceptance Criteria:** Ignores whitespace, formatting changes, and auto-generated content.

---

#### #3.3 Implement pattern filters for Table of Contents, YAML frontmatter, and whitespace
* **Target File:** `backend/src/engine/diff_parser.rs`
* **Subsystem:** `backend` / `webhook`
* **Description:** Regex and AST pattern matching for TOC markers (`<!-- TOC -->`) and YAML frontmatter (`---`).
* **Acceptance Criteria:** Diff consisting solely of TOC updates yields 0 meaningful additions.

---

#### #3.4 Integrate GitHub API PR fetch to verify author login and merged state
* **Target File:** `backend/src/services/github.rs` & `routes/webhooks.rs`
* **Subsystem:** `backend` / `webhook`
* **Description:** Call `GET /repos/{owner}/{repo}/pulls/{number}` to verify PR is merged (`merged == true`) and author matches payload.
* **Acceptance Criteria:** Unmerged PRs or author mismatches throw `400 Bad Request`.

---

### Epic 4: Settlement Engine & Claims Architecture (`[backend]`)
- [x] **#4.1** `[backend]` `[settlement]` Define `SettlementAdapter` async trait and request/response models
- [x] **#4.2** `[backend]` `[settlement]` Implement `PoolSafetyConfig` safety cap validator ($1.00 min, 25% pool max, daily caps)
- [x] **#4.3** `[backend]` `[settlement]` Implement Stripe Connect settlement adapter with idempotency keys
- [x] **#4.4** `[backend]` `[settlement]` Implement USDC / Base crypto settlement adapter
- [x] **#4.5** `[backend]` `[settlement]` Implement `POST /api/v1/claims` submission and `POST /claims/:id/cancel` endpoints
- [x] **#4.6** `[backend]` `[settlement]` Implement `GET/POST/DELETE /api/v1/settlement-accounts` management endpoints
- [x] **#4.7** `[backend]` `[settlement]` Implement `GET /api/v1/audit` endpoints for contributors and pool sponsors

#### #4.1 Define `SettlementAdapter` async trait and request/response models
* **Target File:** `backend/src/settlement/mod.rs`
* **Subsystem:** `backend` / `settlement`
* **Description:** Define `SettlementAdapter` async trait (`execute`, `check_status`) and request/response types.
* **Acceptance Criteria:** Provider-agnostic interface supporting Stripe, USDC, and OpenCollective.

#### #4.2 Implement `PoolSafetyConfig` safety cap validator
* **Target File:** `backend/src/engine/safety.rs`
* **Subsystem:** `backend` / `settlement`
* **Description:** Validate claim rules: min $1.00 USDC, max 25% pool drawdown, max 3 claims per contributor per 24 hours.
* **Acceptance Criteria:** Rejects claims breaking pool reserve or drawdown limits.

---

#### #4.3 Implement Stripe Connect settlement adapter with idempotency keys
* **Target File:** `backend/src/settlement/stripe_adapter.rs`
* **Subsystem:** `backend` / `settlement`
* **Description:** Stripe Connect adapter executing payouts using idempotency keys derived from claim IDs.
* **Acceptance Criteria:** Retried requests with identical claim ID return existing transaction status without double payout.

---

#### #4.4 Implement USDC / Base crypto settlement adapter
* **Target File:** `backend/src/settlement/crypto_adapter.rs`
* **Subsystem:** `backend` / `settlement`
* **Description:** Settlement adapter for EVM Base/Polygon USDC transfers.
* **Acceptance Criteria:** Returns transaction hash and confirmation status.

---

#### #4.5 Implement `POST /api/v1/claims` submission and cancellation endpoints
* **Target File:** `backend/src/routes/claims.rs`
* **Subsystem:** `backend` / `settlement`
* **Description:** HTTP route handlers for initiating and cancelling claims.
* **Acceptance Criteria:** Updates claim status atomically in PostgreSQL.

---

#### #4.6 Implement `GET/POST/DELETE /api/v1/settlement-accounts` management endpoints
* **Target File:** `backend/src/routes/settlement_accounts.rs`
* **Subsystem:** `backend` / `settlement`
* **Description:** HTTP handlers for listing, registering, and deleting payout destinations.
* **Acceptance Criteria:** Restricts management to authenticated owner (`user_id == claimer.id`).

---

#### #4.7 Implement `GET /api/v1/audit` endpoints for contributors and pool sponsors
* **Target File:** `backend/src/routes/audit.rs`
* **Subsystem:** `backend` / `security` / `settlement`
* **Description:** REST endpoint returning paginated audit events for user streams or sponsor pools.
* **Acceptance Criteria:** Enforces role checking (sponsors view pool events; contributors view personal events).

---

### Epic 5: Anti-Sybil Protections & Widget Hardening (`[widget]`)
- [x] **#5.1** `[backend]` `[widget]` Implement `GET /api/v1/widget/nonce` generation and TTL persistence
- [x] **#5.2** `[backend]` `[widget]` Implement weighted exponential vote time-decay engine
- [x] **#5.3** `[widget]` `[security]` Build browser fingerprint generator in `widget.js`
- [x] **#5.4** `[widget]` `[security]` Integrate pre-fetch nonce authentication flow into `<docudrip-widget>`
- [x] **#5.5** `[widget]` `[widget]` Implement dynamic backend URL resolution in `widget.js`

#### #5.1 Implement `GET /api/v1/widget/nonce` generation and TTL persistence
* **Target File:** `backend/src/routes/widget.rs`
* **Subsystem:** `backend` / `widget` / `security`
* **Description:** Issue single-use nonces with 5-minute TTL saved to `widget_nonces`.
* **Acceptance Criteria:** Consumed or expired nonces fail validation.

---

#### #5.2 Implement weighted exponential vote time-decay engine
* **Target File:** `backend/src/engine/vote_decay.rs`
* **Subsystem:** `backend` / `widget`
* **Description:** Exponential time-decay math (30-day half-life: $w = e^{-\lambda \cdot t}$) for voting weight.
* **Acceptance Criteria:** Recent votes carry higher weight than votes cast 60 days ago.

---

#### #5.3 Build browser fingerprint generator in `widget.js`
* **Target File:** `widget/src/fingerprint.js`
* **Subsystem:** `widget` / `security`
* **Description:** Client-side non-tracking canvas and screen fingerprinting for anti-sybil vote deduplication.
* **Acceptance Criteria:** Produces consistent hash across page reloads in same browser.

---

#### #5.4 Integrate pre-fetch nonce authentication flow into `<docudrip-widget>`
* **Target File:** `widget/src/widget.js`
* **Subsystem:** `widget` / `security`
* **Description:** Fetch nonce token from `/widget/nonce` before rendering vote buttons.
* **Acceptance Criteria:** Vote submission payload includes valid nonce token.

---

#### #5.5 Implement dynamic backend URL resolution in `widget.js`
* **Target File:** `widget/src/widget.js`
* **Subsystem:** `widget`
* **Description:** Dynamically resolve backend API base URL from `data-backend-url` attribute or script source host.
* **Acceptance Criteria:** Eliminates hardcoded `http://localhost:8080` in production.

---

### Epic 6: Frontend Dashboard SPA (React 19) (`[frontend]`)
- [x] **#6.1** `[frontend]` `[state]` Create `claimStore.js` Zustand store with selection and status filter state
- [x] **#6.2** `[frontend]` `[ui]` Build `ClaimPage.jsx` with stream selection, pool remaining display, and submission form
- [x] **#6.3** `[frontend]` `[ui]` Build `SettlementSetup.jsx` view for managing payout accounts (Stripe, USDC wallet)
- [x] **#6.4** `[frontend]` `[ui]` Build `AuditTrail.jsx` view for chronological event visualization
- [x] **#6.5** `[frontend]` `[ui]` Update `App.jsx` navigation shell with Claims & Audit tabs

#### #6.1 Create `claimStore.js` Zustand store
* **Target File:** `frontend/src/stores/claimStore.js`
* **Subsystem:** `frontend` / `settlement`
* **Description:** Zustand store managing active claims list, selection state, and filter criteria.
* **Acceptance Criteria:** Tracks active claim state across component re-renders.

---

#### #6.2 Build `ClaimPage.jsx` with stream selection and submission form
* **Target File:** `frontend/src/pages/ClaimPage.jsx` & `components/ClaimCard.jsx`
* **Subsystem:** `frontend` / `settlement`
* **Description:** Dashboard view for viewing accrued balances and submitting payout claims.
* **Acceptance Criteria:** Enforces client-side minimum $1.00 threshold validation.

---

#### #6.3 Build `SettlementSetup.jsx` view for managing payout accounts
* **Target File:** `frontend/src/pages/SettlementSetup.jsx`
* **Subsystem:** `frontend` / `settlement`
* **Description:** Settings view for connecting Stripe accounts or entering crypto payout wallet addresses.
* **Acceptance Criteria:** Allows adding, setting default, and deleting payout destinations.

---

#### #6.4 Build `AuditTrail.jsx` view for chronological event visualization
* **Target File:** `frontend/src/pages/AuditTrail.jsx`
* **Subsystem:** `frontend` / `security`
* **Description:** Timeline view displaying audit events (claims, pool drawdowns, rating changes).
* **Acceptance Criteria:** Displays chronological event timeline with status badges.

---

#### #6.5 Update `App.jsx` navigation shell with Claims & Audit tabs
* **Target File:** `frontend/src/App.jsx`
* **Subsystem:** `frontend`
* **Description:** Add navigation tabs for Claims and Audit Trail in `DashboardShell`.
* **Acceptance Criteria:** Navigation correctly switches active views and protects authenticated routes.

---

### Epic 7: Mobile Client Caching & Security (Flutter + Drift) (`[mobile]`)
- [x] **#7.1** `[mobile]` `[database]` Define `ClaimsTable`, `OfflineActionsTable`, and `SessionTable` in `database.dart`
- [x] **#7.2** `[mobile]` `[database]` Add Drift schema v2 migration strategy (`MigrationStrategy`)
- [x] **#7.3** `[mobile]` `[security]` Configure SQLCipher encrypted connection via `flutter_secure_storage`
- [x] **#7.4** `[mobile]` `[sync]` Build `SyncService` for periodic API fetch and batch upserts
- [x] **#7.5** `[mobile]` `[sync]` Build `OfflineActionsTable` queue processor with exponential backoff retries

#### #7.1 Define `ClaimsTable`, `OfflineActionsTable`, and `SessionTable` in `database.dart`
* **Target File:** `mobile/lib/db/database.dart`
* **Subsystem:** `mobile` / `database`
* **Description:** Drift SQLite table definitions for caching claims, session tokens, and queued offline actions.
* **Acceptance Criteria:** Compile-time verified Drift table schemas.

---

#### #7.2 Add Drift schema v2 migration strategy (`MigrationStrategy`)
* **Target File:** `mobile/lib/db/database.dart`
* **Subsystem:** `mobile` / `database`
* **Description:** Define Drift `MigrationStrategy` handling upgrade from schema version 1 to 2.
* **Acceptance Criteria:** Existing SQLite database upgrades without data loss.

---

#### #7.3 Configure SQLCipher encrypted connection via `flutter_secure_storage`
* **Target File:** `mobile/lib/db/database.dart` & `pubspec.yaml`
* **Subsystem:** `mobile` / `security`
* **Description:** Encrypt SQLite database file on device filesystem using SQLCipher key stored in device Keychain/Keystore.
* **Acceptance Criteria:** Database file cannot be read in plaintext without encryption key.

---

#### #7.4 Build `SyncService` for periodic API fetch and batch upserts
* **Target File:** `mobile/lib/services/sync_service.dart`
* **Subsystem:** `mobile`
* **Description:** Background service fetching pools, streams, and claims from REST API and batch upserting into Drift.
* **Acceptance Criteria:** Uses `insertAllOnConflictUpdate` for conflict-free cache sync.

---

#### #7.5 Build `OfflineActionsTable` queue processor with exponential backoff retries
* **Target File:** `mobile/lib/services/sync_service.dart`
* **Subsystem:** `mobile`
* **Description:** Offline queue processor executing cached votes/claims when network connection recovers.
* **Acceptance Criteria:** Retries failed operations up to 5 times with backoff before marking as failed.

---

## 🚀 Phase 2 & Phase 3 Future Expansion Specifications

#### #8.1 Integrate Automated LLM Quality & Formatting Scorer (`[backend]`)
* Evaluate merged documentation PR readability index and accuracy using lightweight LLM inference.

#### #8.2 Build GitLab and Codeberg Repository Webhook Drivers (`[backend]`)
* Expand ingestion pipeline to process webhook events from self-hosted GitLab and Codeberg.

#### #8.3 Package Native `@docudrip/docusaurus-plugin` and Starlight Astro Integrations (`[widget]`)
* Release framework-native npm packages for automated widget injection on Docusaurus and Astro Starlight sites.

#### #8.4 Build Corporate Match-Funding Pool Engine (`[backend]`)
* Enable 1:1 corporate matching funds for open-source documentation grants.

#### #8.5 Build Open Documentation Health Telemetry GraphQL/REST API (`[backend]`)
* Expose public telemetry endpoints displaying documentation coverage and funding flows across open-source ecosystems.
