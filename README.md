# DocuDrip (Continuous Docs Micro-Funding Protocol)

DocuDrip is a continuous, real-time documentation micro-funding dashboard designed for modern open-source ecosystems. It monitors documentation contributions, translates engagement/helpfulness metrics into algorithmic weights, and distributes continuous funding streams directly to contributors.

## Product Philosophy
DocuDrip operates on the principle of **Continuous Value Realization**. Rather than locking developer incentives behind large, static, and delayed milestones, DocuDrip calculates small, automated, real-time payouts ("drips") that flow continuously into contributor accounts based on character counts, localization multipliers, and helpfulness metrics.

This UI has been fully redesigned under strict **Dark Tech / Industrial** aesthetics to serve developers, open-source maintainers, and sponsors. It prioritizes data density, high-utility layouts, and transparent metrics over visual fluff.

---

## 🎨 Visual System & Design Architecture

DocuDrip follows a unified Design System tailored for premium, high-density dashboard interfaces.

- **Primary Colors**: Sleek terminal black and dark-zinc foundations (`zinc-950` as background, `zinc-900`/`zinc-800` borders and panel backgrounds).
- **Accent Color**: Electric Cyan (`#00f0ff` / `hsl(180, 100%, 50%)`) used sparingly for focused feedback, status indicators, and selected states.
- **Typography**: Inter (sans-serif) for high legibility in labels and metrics; Space Grotesk (sans-serif) for high-impact structural headers.
- **Border Radii**: Strict, uniform `8px` corner treatments for an industrial, precise grid feel.
- **Elevations**: Flat, high-contrast borders (`1px solid var(--border-color)`) without soft drop shadows or noisy glassmorphism.
- **Micro-Animations**: Purposeful, GPU-accelerated feedback states (e.g., scale adjustments on hover, clean progress bars, and high-performance ticker states).

---

## ⚙️ Key Technical Features

1. **Continuous Payout Simulation Engine**:
   - Updates every 100 milliseconds using standard interval timers.
   - Algorithmic micro-funding calculated based on:
     $$\text{Drip Rate (USDC/sec)} = \frac{\text{File Character Count} \times \text{Base Pool Rate} \times \text{Locale Multiplier} \times \text{Feedback Multiplier} \times \text{Demo Boost}}{86,400}$$

2. **Multi-Locale Translation Boosts**:
   - Encourages global translation streams by scaling reward rates dynamically for high-demand regions (e.g., Spanish, Chinese, and German localization multipliers).

3. **Active Helpfulness / Peer-Voting Loop**:
   - Real-time rating dynamics driven by Upvote / Downvote distributions.
   - Payout multiplier adjustments calculated instantly on feedback fluctuations:
     - $\ge 95\%$ Rating $\rightarrow 1.5\times$ Multiplier
     - $\ge 90\%$ Rating $\rightarrow 1.2\times$ Multiplier
     - $\ge 75\%$ Rating $\rightarrow 1.0\times$ Multiplier
     - $\ge 60\%$ Rating $\rightarrow 0.8\times$ Multiplier
     - $< 60\%$ Rating $\rightarrow 0.5\times$ Multiplier

4. **Integration Sandbox**:
   - Allows developers to dynamically spawn new micro-funding streams by specifying file parameters, locale settings, author details, and initial upvote scores.

---

## 🛠️ Monorepo Structure & Local Development

DocuDrip is structured as a monorepo containing three core packages:

1. **`backend/`**: Rust Axum + SQLx + Postgres web server.
2. **`frontend/`**: React 19 + Vite 8 client application.
3. **`widget/`**: Lightweight vanilla JS embeddable widget.

### Prerequisites
- Node.js (v18 or higher recommended)
- Rust and Cargo (latest stable)
- Docker and Docker Compose (for PostgreSQL & Redis)

### Step 1: Start Database and Cache
Run the docker-compose environment from the root directory:
```bash
docker compose up -d
```

### Step 2: Setup Backend (Rust)
Navigate to the `backend/` directory:
```bash
cd backend
cp .env.example .env
cargo run
```
The server will start on `http://localhost:8080/`.

### Step 3: Setup Frontend (React)
Navigate to the `frontend/` directory:
```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```
The client app will run at `http://localhost:5173/`.

### Step 4: Setup Widget (Vanilla JS)
Navigate to the `widget/` directory:
```bash
cd widget
cp .env.example .env
npm install
```

---

## 💾 Roadmap & Local Storage (Drift)

To evolve DocuDrip from a client-side simulation into a resilient, persistent protocol, the next architectural step is the integration of **Drift** for local data storage.

We will leverage Drift (the reactive persistence library for Flutter and Dart, or corresponding local SQL storage layers) to:
- Persist simulated funding pools and streams across browser sessions.
- Queue offline micro-transactions securely until a connection is re-established.
- Maintain persistent transaction logs and contributor identities locally on-device.

*Refer to the [Drift Documentation](https://drift.simonbinder.eu/) for schema patterns, migration hooks, and reactive query setups.*
