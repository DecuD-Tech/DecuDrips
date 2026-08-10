# 📋 DocuDrip — Master Project Issue Index

This file tracks all engineering issues, security enhancements, and feature tasks across the DocuDrip monorepo (**Backend**, **Frontend**, **Widget**, **Mobile**, and **Infrastructure**).

---

## 🔒 Phase 1: Core Protocol Hardening & Settlement Engine

### 🛠️ Infrastructure, Security & Middleware
- [ ] **#1** `[database]` `[migration]` Create PostgreSQL Phase 1 Hardening Migration (`20260801000001_phase1_hardening.sql`)
- [ ] **#2** `[backend]` `[security]` Replace Permissive CORS with Environment-Driven Origin Allowlist
- [ ] **#3** `[backend]` `[security]` Implement Token-Bucket Rate Limiting via `tower-governor`
- [ ] **#4** `[backend]` `[security]` Implement Server-Side Real Client IP Extractor Middleware
- [ ] **#5** `[backend]` `[audit]` Build Immutable Audit Event Logger Module & API Endpoints

---

### 🎣 Webhook & Ingestion Hardening
- [ ] **#6** `[backend]` `[webhook]` `[security]` Add Time-Bounded Timestamp Replay Guard to GitHub Webhooks
- [ ] **#7** `[backend]` `[webhook]` Build AST-Aware Markdown Diff Parser to Filter TOCs and Formatting Noise
- [ ] **#8** `[backend]` `[webhook]` Implement PR Author Credential & Merge State Verification via GitHub API

---

### 💰 Settlement Engine & Claim Lifecycle
- [ ] **#9** `[backend]` `[settlement]` Define `SettlementAdapter` Trait and Provider Architecture
- [ ] **#10** `[backend]` `[settlement]` Implement Stripe Connect Settlement Adapter
- [ ] **#11** `[backend]` `[settlement]` Implement USDC / Base Crypto Settlement Adapter
- [ ] **#12** `[backend]` `[settlement]` Build Claim Lifecycle State Machine & Safety Cap Validator
- [ ] **#13** `[backend]` `[settlement]` Implement Claim Submission, Listing, and Cancellation API Endpoints
- [ ] **#14** `[backend]` `[settlement]` Implement Settlement Account Management API Endpoints

---

### 🛡️ Anti-Sybil Protections & Widget Hardening
- [ ] **#15** `[backend]` `[widget]` Implement Short-Lived Widget Nonce Generation & Validation API
- [ ] **#16** `[backend]` `[engine]` Implement Weighted Exponential Vote Time-Decay Engine
- [ ] **#17** `[widget]` `[security]` Integrate Browser Fingerprinting and Nonce Token Auth in Feedback Widget
- [ ] **#18** `[widget]` `[config]` Implement Dynamic Backend URL Resolution in Widget Web Component
- [ ] **#19** `[backend]` `[security]` Implement CSP Headers for Widget Static Asset Delivery

---

### 💻 Frontend Dashboard SPA (React 19)
- [ ] **#20** `[frontend]` `[ui]` Create Claim Management Store & Claim Submission Page
- [ ] **#21** `[frontend]` `[ui]` Create Settlement Account Setup & Management View
- [ ] **#22** `[frontend]` `[ui]` Create Chronological Audit Trail Viewer for Contributor Streams & Claims
- [ ] **#23** `[frontend]` `[ui]` Create Sponsor Pool Audit & Drawdown Analytics Dashboard

---

### 📱 Mobile Companion App (Flutter + Drift SQLite)
- [ ] **#24** `[mobile]` `[database]` Expand Drift SQLite Database Schema to Version 2 (`ClaimsTable`, `OfflineActionsTable`, `SessionTable`)
- [ ] **#25** `[mobile]` `[security]` Implement SQLCipher Database Encryption & Secure Key Storage via `flutter_secure_storage`
- [ ] **#26** `[mobile]` `[sync]` Build Background Sync Service & Offline Action Queue Engine
- [ ] **#27** `[mobile]` `[ui]` Scaffold Flutter Mobile UI Presentation Layer & Reactive Stream Dashboard

---

## 🚀 Phase 2 & Phase 3 Future Expansion

- [ ] **#28** `[backend]` `[ai]` Integrate Automated LLM Quality & Formatting Scorer
- [ ] **#29** `[backend]` `[integrations]` Build GitLab and Codeberg Repository Webhook Drivers
- [ ] **#30** `[widget]` `[plugins]` Package Native `@docudrip/docusaurus-plugin` and Starlight Astro Integrations
- [ ] **#31** `[backend]` `[matching]` Build Corporate Match-Funding Pool Engine
- [ ] **#32** `[backend]` `[telemetry]` Build Open Documentation Health Telemetry GraphQL/REST API
