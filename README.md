# DocuDrip

**Continuous micro-funding for open-source documentation.**

DocuDrip is a decentralized protocol that rewards technical writers and documentation maintainers with real-time, continuous micro-payments. Instead of locking incentives behind large milestones or bounty completions, DocuDrip calculates small automated payouts — "drips" — that stream directly into contributor accounts based on contribution quality, community feedback, and localization reach.

## The Problem

Open-source documentation is consistently underfunded. Writers contribute critical work — guides, API references, translations — but rarely see direct compensation. Existing bounty and grant models are slow, opaque, and favour one-off contributions over sustained maintenance. DocuDrip fixes this by making documentation funding continuous, transparent, and algorithmic.

## How It Works

1. **Maintainers** create funding pools tied to their repositories and set per-character rates, locale multipliers, and quality thresholds.
2. **Contributors** claim documentation pages, submit improvements, and immediately begin receiving a live payment stream calculated from contribution size, translation locale, and community helpfulness ratings.
3. **Community members** vote on documentation quality through an embeddable feedback widget. Votes directly adjust a contributor's payout multiplier in real time.
4. **The protocol** handles stream calculation, rate adjustment, and payout distribution — simulating on-chain streaming mechanics (inspired by Superfluid) on the client side for V1, with real smart contract integration planned for V2.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Rust (Axum, Tokio, SQLx) |
| Database | PostgreSQL 16 |
| Cache / PubSub | Redis 7 |
| Frontend | React 19, Vite 8, Zustand, React Query |
| Embeddable Widget | Vanilla JS, Shadow DOM (< 5 KB) |
| Auth | GitHub OAuth 2.0 + JWT |
| Styling | Vanilla CSS (no frameworks) |

## Project Structure

```
docudrip/
├── backend/          # Rust API server (Axum + SQLx)
├── frontend/         # React dashboard client
├── widget/           # Embeddable documentation feedback widget
├── docker-compose.yml
├── PRODUCT.md        # Brand and design guidelines
└── README.md
```

Each package is independently buildable and deployable.

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [Rust](https://www.rust-lang.org/tools/install) (latest stable)
- [Docker](https://docs.docker.com/get-docker/) and Docker Compose

### 1. Clone the repository

```bash
git clone git@github.com:XQurator-Tech/DecuDrips.git
cd DecuDrips
```

### 2. Start infrastructure

```bash
docker compose up -d
```

This spins up PostgreSQL 16 and Redis 7 locally.

### 3. Run the backend

```bash
cd backend
cp .env.example .env
cargo run
```

Server starts at `http://localhost:8080`.

### 4. Run the frontend

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

Client starts at `http://localhost:5173`.

## V1 Scope

- GitHub OAuth login for maintainers and contributors
- Funding pool creation and management dashboard
- Real-time streaming payout engine with live-ticking counters
- Embeddable helpfulness widget (👍 / 👎) that adjusts payout rates
- Multi-locale translation multipliers
- Simulated blockchain layer (real on-chain integration in V2)

## License

This project is open source. License details will be added in a subsequent update.
