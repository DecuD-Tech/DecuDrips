# Rust API Server (`backend/`)

The backend for DocuDrip V1 is a highly performant, stateless REST API server built using **Rust**, **Axum**, and **SQLx (PostgreSQL)**. 

---

## 🧭 API Route Map

All endpoints are prefixed with `/api/v1` except for the public widget static asset routers.

| Method | Endpoint | Authorization | Purpose |
|:---|:---|:---|:---|
| `GET` | `/health` | None | Simple health check. |
| `GET` | `/pools` | Optional | List all active reward pools with statistics. |
| `POST` | `/pools` | Required (**Sponsor** only) | Deploy and fund a new reward pool for a repository. |
| `GET` | `/pools/:id` | Optional | Get pool configuration details. |
| `PATCH` | `/pools/:id` | Required (**Owner** only) | Update a pool's status (e.g., mark as suspended). |
| `GET` | `/streams` | Optional | List active contributor streams with pre-calculated balances. |
| `GET` | `/streams/:id` | Optional | Get stream details, voter records, and computed flow rates. |
| `POST` | `/streams/:id/vote` | None (Wildcard CORS) | Submit an anonymous reader helpfulness vote. |
| `GET` | `/stats` | None | Get global system-wide aggregates for the landing page. |
| `POST` | `/webhooks/github` | HMAC-SHA256 Signature | Idempotent webhook receiver for GitHub PR merge hooks. |
| `GET` | `/auth/github` | None | Initiate GitHub OAuth 2.0 redirection handshake. |
| `GET` | `/auth/github/callback` | None | OAuth callback handler that issues JWT tokens. |
| `GET` | `/users/me` | Required (Valid JWT) | Fetch profile details for the authenticated session. |

---

## 🔒 Security & Middleware Heuristics

### 1. Role-Restriction Guards
The API enforces strict access control at compile-time using custom Axum extractors:
* `AuthUser`: Parses the HS256 JWT authorization header and loads user sessions.
* `SponsorUser`: Validates that the active session belongs to a verified organization account with `role = 'sponsor'`, automatically throwing a `403 Forbidden` if a standard contributor attempts to deploy a funding pool.

### 2. GitHub Webhook Verification & Idempotency
To secure the Github event listener, the backend incorporates:
* **HMAC-SHA256 Signatures:** Raw request bodies are hashed using the shared `GITHUB_WEBHOOK_SECRET` and constant-time compared against the incoming `X-Hub-Signature-256` header.
* **Database deduplication:** GitHub retries are deduplicated at the PostgreSQL layer by inserting the `X-GitHub-Delivery` ID into a table with a `UNIQUE` constraint, avoiding double-crediting merged documentation.

---

## 🧮 Precise Financial Database Schema

All mathematical rewards are tracked using PostgreSQL **`DECIMAL`** types (represented in Rust via the `rust_decimal` crate) to prevent floating-point rounding errors on payout claims:

```sql
-- Pools table tracking Sponsor holdings
CREATE TABLE pools (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id        UUID NOT NULL REFERENCES users(id),
    repo_full_name  TEXT NOT NULL,
    funding_amount  DECIMAL(18, 6) NOT NULL,
    base_rate       DECIMAL(12, 8) NOT NULL,
    total_dripped   DECIMAL(18, 6) NOT NULL DEFAULT 0,
    status          TEXT NOT NULL DEFAULT 'active',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Streams table tracking individual documentation merges
CREATE TABLE streams (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pool_id         UUID NOT NULL REFERENCES pools(id),
    author_id       UUID NOT NULL REFERENCES users(id),
    pr_number       INT,
    file_path       TEXT NOT NULL,
    character_count INT NOT NULL,
    locale          TEXT NOT NULL DEFAULT 'en',
    accumulated     DECIMAL(18, 8) NOT NULL DEFAULT 0,
    status          TEXT NOT NULL DEFAULT 'active',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

> [!IMPORTANT]
> **SQLx Offline Compilation:**
> The backend compiles using SQLx offline metadata (`sqlx-data.json`). If you modify any SQL queries inside the Rust files, you must run:
> `DATABASE_URL=postgresql://postgres:postgres@localhost:5432/docudrip cargo sqlx prepare`
> locally to regenerate this cache file so that CI/CD pipelines compile cleanly without needing a live database.
