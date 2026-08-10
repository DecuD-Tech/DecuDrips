# 💧 DocuDrip Protocol Wiki

Welcome to the official developer, architecture, and contributor wiki for **DocuDrip** — the continuous micro-sponsorship protocol for open-source documentation.

---

## 🧭 Wiki Quick Navigation

| Topic | Description | Link |
| :--- | :--- | :--- |
| **System Architecture** | High-level system map, Mermaid diagrams, compute-on-read engine | [[Architecture-&-Data-Flows]] |
| **Strategic Roadmap** | Multi-phase protocol milestones, KPIs, and vision | [[Strategic-Roadmap]] |
| **Phase 1 Execution Plan** | Hardening & settlement blueprint, DB migrations, API contracts, risk register | [[Phase-1-Execution-Plan]] |
| **Product & Brand Identity** | "Dark Tech" design system, color tokens, visual directives | [[Product-&-Visual-Identity]] |
| **Rust API Server** | Axum HTTP router, SQLx schemas, webhook processing, auth middleware | [[Rust-API-Server-Spec]] |
| **React Dashboard SPA** | React 19 SPA, Zustand stores, React Query polling, `LiveTicker` component | [[React-Dashboard-SPA-Spec]] |
| **Embeddable Feedback Widget** | Shadow DOM Web Component, anti-sybil protections, integration guide | [[Embeddable-Feedback-Widget-Spec]] |
| **Flutter Mobile Caching** | Offline-first Drift (SQLite) persistence schema, reactive watches, sync service | [[Flutter-Mobile-Caching-Spec]] |

---

## 🛠️ Monorepo Structure

```
docudrip/
├── backend/          # Rust API server (Axum + Tokio + SQLx PostgreSQL)
├── frontend/         # React 19 dashboard client (Vite + Zustand + React Query)
├── widget/           # Embeddable documentation feedback Web Component (< 5KB Vanilla JS)
├── mobile/           # Flutter app companion (Drift SQLite persistence layer)
├── docs/             # Core repository technical documentation
├── docker-compose.yml# Local database setup (PostgreSQL 16)
├── PRODUCT.md        # Brand identity and visual tokens
├── ROADMAP.md        # Strategic product roadmap
└── LICENSE           # MIT Open Source License
```
