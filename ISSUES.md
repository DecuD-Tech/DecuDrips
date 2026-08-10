# 📋 DocuDrip — Master Project Issue Index

This document breaks down the DocuDrip roadmap into atomic, actionable sub-issues grouped by **Epics**. Each sub-issue is independently trackable, buildable, and testable.

---

## 🔒 Phase 1: Core Protocol Hardening & Settlement Engine

### Epic 1: Database Phase 1 Schema Migration (`[database]`)
- [ ] **#1.1** `[database]` `[schema]` Create `claims` table migration with status constraints (`pending`, `processing`, `settled`, `failed`, `cancelled`)
- [ ] **#1.2** `[database]` `[schema]` Create `settlement_accounts` table migration with unique user/provider constraints
- [ ] **#1.3** `[database]` `[schema]` Create `audit_events` append-only log table migration with indexes
- [ ] **#1.4** `[database]` `[schema]` Create `widget_nonces` ephemeral token table migration with expiration indexes
- [ ] **#1.5** `[database]` `[schema]` Add `expires_at` column & index to `webhook_events` table
- [ ] **#1.6** `[database]` `[schema]` Add `fingerprint_hash`, `user_agent`, `decay_weight` & compound index to `votes` table

---

### Epic 2: Server Security, Middleware & Audit Engine (`[backend]`)
- [ ] **#2.1** `[backend]` `[security]` Build `ip_extractor.rs` middleware parsing `X-Forwarded-For`, `X-Real-IP`, and socket info
- [ ] **#2.2** `[backend]` `[security]` Replace `CorsLayer::permissive()` with configurable `CORS_ALLOWED_ORIGINS` allowlist
- [ ] **#2.3** `[backend]` `[security]` Integrate `tower-governor` token-bucket rate limiter across anonymous and authed routes
- [ ] **#2.4** `[backend]` `[audit]` Build `audit::log_event()` logger module and database query helpers
- [ ] **#2.5** `[backend]` `[security]` Inject Content-Security-Policy (CSP) headers into static asset routes (`/widget.js`)

---

### Epic 3: Webhook & Ingestion Hardening (`[backend]`)
- [ ] **#3.1** `[backend]` `[webhook]` Implement `X-GitHub-Hook-Timestamp` 5-minute replay window validation
- [ ] **#3.2** `[backend]` `[webhook]` Build AST-aware Markdown diff parser module (`engine/diff_parser.rs`)
- [ ] **#3.3** `[backend]` `[webhook]` Implement pattern filters for Table of Contents, YAML frontmatter, and whitespace
- [ ] **#3.4** `[backend]` `[webhook]` Integrate GitHub API PR fetch to verify author login and merged state

---

### Epic 4: Settlement Engine & Claims Architecture (`[backend]`)
- [ ] **#4.1** `[backend]` `[settlement]` Define `SettlementAdapter` async trait and request/response models
- [ ] **#4.2** `[backend]` `[settlement]` Implement `PoolSafetyConfig` safety cap validator ($1.00 min, 25% pool max, daily caps)
- [ ] **#4.3** `[backend]` `[settlement]` Implement Stripe Connect settlement adapter with idempotency keys
- [ ] **#4.4** `[backend]` `[settlement]` Implement USDC / Base crypto settlement adapter
- [ ] **#4.5** `[backend]` `[settlement]` Implement `POST /api/v1/claims` submission and `POST /claims/:id/cancel` endpoints
- [ ] **#4.6** `[backend]` `[settlement]` Implement `GET/POST/DELETE /api/v1/settlement-accounts` management endpoints
- [ ] **#4.7** `[backend]` `[settlement]` Implement `GET /api/v1/audit` endpoints for contributors and pool sponsors

---

### Epic 5: Anti-Sybil Protections & Widget Hardening (`[widget]`)
- [ ] **#5.1** `[backend]` `[widget]` Implement `GET /api/v1/widget/nonce` generation and 5-min TTL expiration DB persistence
- [ ] **#5.2** `[backend]` `[engine]` Implement weighted exponential vote time-decay engine (30-day half-life)
- [ ] **#5.3** `[widget]` `[security]` Build privacy-preserving canvas & hardware browser fingerprint generator in `widget.js`
- [ ] **#5.4** `[widget]` `[security]` Integrate pre-fetch nonce authentication flow into `<docudrip-widget>` Web Component
- [ ] **#5.5** `[widget]` `[config]` Implement dynamic backend URL resolution from attributes and script tags

---

### Epic 6: Frontend Dashboard SPA (React 19) (`[frontend]`)
- [ ] **#6.1** `[frontend]` `[state]` Create `claimStore.js` Zustand store with selection and status filter state
- [ ] **#6.2** `[frontend]` `[ui]` Build `ClaimPage.jsx` with stream selection, pool remaining display, and submission form
- [ ] **#6.3** `[frontend]` `[ui]` Build `SettlementSetup.jsx` view for managing payout accounts (Stripe, USDC wallet)
- [ ] **#6.4** `[frontend]` `[ui]` Build `AuditTrail.jsx` view for chronological event visualization
- [ ] **#6.5** `[frontend]` `[ui]` Update `App.jsx` navigation shell with Claims & Audit tabs

---

### Epic 7: Mobile Client Caching & Security (Flutter + Drift) (`[mobile]`)
- [ ] **#7.1** `[mobile]` `[database]` Define `ClaimsTable`, `OfflineActionsTable`, and `SessionTable` in `database.dart`
- [ ] **#7.2** `[mobile]` `[database]` Add Drift schema v2 migration strategy (`MigrationStrategy`)
- [ ] **#7.3** `[mobile]` `[security]` Configure SQLCipher encrypted connection via `flutter_secure_storage`
- [ ] **#7.4** `[mobile]` `[sync]` Build `SyncService` for periodic API fetch and batch upserts
- [ ] **#7.5** `[mobile]` `[sync]` Build `OfflineActionsTable` queue processor with exponential backoff retries

---

## 🚀 Phase 2 & Phase 3 Future Expansion

- [ ] **#8.1** `[backend]` `[ai]` Integrate Automated LLM Quality & Formatting Scorer
- [ ] **#8.2** `[backend]` `[integrations]` Build GitLab and Codeberg Repository Webhook Drivers
- [ ] **#8.3** `[widget]` `[plugins]` Package Native `@docudrip/docusaurus-plugin` and Starlight Astro Integrations
- [ ] **#8.4** `[backend]` `[matching]` Build Corporate Match-Funding Pool Engine
- [ ] **#8.5** `[backend]` `[telemetry]` Build Open Documentation Health Telemetry GraphQL/REST API
