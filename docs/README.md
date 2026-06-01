# DocuDrip Protocol — Technical Documentation

Welcome to the official developer and integrator documentation for the **DocuDrip Protocol** — a continuous micro-funding framework engineered to stream real-time rewards directly to open-source documentation contributors.

This documentation maps our modular monorepo architecture and provides concise, essential specifications for each core component.

---

## 🗺️ Documentation Index

### 1. [System Architecture & Data Flows](architecture.md)
* Learn how backend, frontend, widget, and mobile caching layers synchronize to compute doc reward payouts.
* View high-level system maps and Mermaid data flow diagrams.

### 2. [Rust API Server Spec (backend/)](backend.md)
* Explore Axum HTTP route maps, webhook handlers, and database schemas.
* Review the pure compute-on-read engine and idempotency logic.

### 3. [React Dashboard SPA (frontend/)](frontend.md)
* View details on state management, protected routes, and authentication.
* Understand our high-fidelity, hardware-accelerated decimal interpolation component (`LiveTicker`).

### 4. [Embeddable Shadow-DOM Feedback Widget (widget/)](widget.md)
* Get instructions on embedding the lightweight rating element inside third-party documentation pages.
* Explore Shadow DOM isolation rules and AJAX CORS voting pipelines.

### 5. [Flutter Mobile Caching Boilerplate (mobile/)](mobile.md)
* Inspect details on offline-first caching schemas powered by Simon Binder's **Drift** reactive persistence engine.
* Review native SQLite watch streams and background synchronization strategies.

---

> [!TIP]
> **Getting Started Quickly:**
> If you are setting up DocuDrip locally for the first time, refer to the step-by-step instructions in the root [README.md](../README.md).
