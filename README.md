# DocuDrip

**Continuous micro-funding for open-source documentation.**

DocuDrip is a decentralized protocol that rewards technical writers and documentation maintainers with real-time, continuous micro-payments. Instead of locking incentives behind large milestones or bounty completions, DocuDrip calculates small automated payouts — "drips" — that stream directly into contributor accounts based on contribution size, localization locale, and community helpfulness ratings.

---

## 📐 How It Works

1. **Maintainers** deploy funding pools tied to their target GitHub repositories, defining per-character base rates, translation locale multipliers, and active balances.
2. **Webhooks** capture qualifying merged documentation pull requests (`.md`, `.mdx`, `.rst`, etc.), analyzing character volume addition and upserting author credentials.
3. **Stateless Compute-on-Read Engine:** The backend computes accumulated streams on-demand during request boundaries, keeping the architecture highly reliable and scalable without needing Redis state caches or background loops.
4. **Live Visual Tickers:** The client dashboard interpolates polled data streams using a high-fidelity `requestAnimationFrame` render loop, giving contributors a smooth, real-time "dripping" reward visualization.
5. **Community Feedback loops:** Readers vote on documentation helpfulness via a Shadow DOM encapsulated widget embedded directly in developer docs, scaling contributor multipliers from `0.5x` up to `1.5x` dynamically.

---

## 🛠️ Tech Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Backend API** | Rust (Axum, Tokio, SQLx) | Ultra-safe, compile-time verified database operations and lightweight containers. |
| **Database** | PostgreSQL 16 | ACID-compliant transaction ledgers with `rust_decimal` precision math. |
| **Frontend SPA** | React 19, Vite 8, Zustand, React Query | Sleek glassmorphic dark tech dashboard with robust polling and state sync. |
| **Feedback Widget** | Vanilla JS, Shadow DOM CSS | Lightweight (< 5KB), style-isolated Web Component suitable for any documentation site. |
| **Mobile Persistence** | Flutter + Drift (SQLite) | Conceptual offline-first database schemas and reactive watches for companion dashboards. |
| **Authentication** | GitHub OAuth 2.0 + JWTs | Seamless identity verification mapping directly to GitHub profile metrics. |

---

## 🗂️ Project Structure

```
docudrip/
├── backend/          # Rust API server (Axum + SQLx)
├── frontend/         # React dashboard client
├── widget/           # Embeddable documentation feedback widget (Vanilla JS)
├── mobile/           # Flutter app companion (caching via Drift persistence)
├── docker-compose.yml# Local database setup (Postgres 16)
└── README.md
```

Each package is independently configured, buildable, and deployable.

---

## 🚀 Getting Started

### Prerequisites
* [Node.js](https://nodejs.org/) v18+ & npm
* [Rust](https://www.rust-lang.org/tools/install) (latest stable)
* [Docker](https://docs.google.com/get-docker/) & Docker Compose

### 1. Start Database Infrastructure
Launch PostgreSQL locally:
```bash
docker compose up -d
```
*(Verify container status via `docker ps` to ensure port `5432` is bound).*

### 2. Configure & Run Backend
Navigate to the backend directory, set environment variables, and boot the Axum server:
```bash
cd backend
cp .env.example .env
# Set database and client credentials inside your .env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/docudrip cargo run
```
* Server starts on **`http://localhost:8080`**.
* Serves widget files directly at `/widget.js` and `/widget.css`.

### 3. Configure & Run Frontend
Navigate to the frontend directory, install dependencies, and launch Vite:
```bash
cd ../frontend
npm install
npm run dev
```
* Client dashboard boots on **`http://localhost:5173`**.
* Access `/login` to connect your GitHub session.

---

## 🔌 Embedding the Feedback Widget

Documentation maintainers can easily embed the rating widget on any documentation site (e.g. Docusaurus, GitBook, or static HTML).

1. Inject the Custom Element script tag referencing your active stream identifier:
   ```html
   <script src="http://localhost:8080/widget.js" 
           data-stream="YOUR_STREAM_UUID" 
           defer></script>
   ```

2. Add the custom element placeholder inside your document structure:
   ```html
   <docudrip-widget data-stream="YOUR_STREAM_UUID"></docudrip-widget>
   ```

All styles are completely isolated inside the **Shadow DOM**, shielding the widget from any custom CSS rules defined on the host documentation host page.

---

## ⚖️ License

This project is open-source software licensed under the [MIT License](file:///Users/adewuyi/Development/drips.repo/decudrips/LICENSE).

