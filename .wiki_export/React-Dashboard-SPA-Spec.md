# React Dashboard Client (`frontend/`)

The frontend of DocuDrip is a high-density, glassmorphic single-page application built using **React 19**, **Vite 8**, **Zustand**, and **React Query**.

---

## 🏗️ State & Cache Architecture

### 1. React Query (`@tanstack/react-query`) — Server Cache
* Handles all data fetches (`GET /pools`, `GET /streams`, `GET /stats`).
* Automatically coordinates **5-second background polling** on active streams.
* Handles data mutations (`POST /pools`, `POST /streams/:id/vote`), invalidating query caches upon success.

### 2. Zustand — Client State
* **`authStore.js`**: Tracks active authenticated user sessions, roles (`sponsor` / `contributor`), and handles OAuth redirections and JWT token persistence.
* **`poolStore.js`**, **`streamStore.js`**, **`statsStore.js`**: Manage visual search filters, dashboard metric ranges, and table sorting options.

---

## 🛡️ Routing & Navigation Guards

* **Public Paths:** `/login`, `/auth/callback`
* **Protected Paths (`/*`):** Wrapped inside a `RequireAuth` guard. Sponsors access the "Deploy Smart Pool" creator panel; Contributors are presented with stream views.

---

## 💎 The `LiveTicker` Decimal Interpolator

Because active streams are polled every 5 seconds, `LiveTicker.jsx` interpolates values on the client side using `requestAnimationFrame`:

$$\text{Rate (USDC/sec)} = \frac{\text{Character Count} \times \text{Base Rate} \times \text{Locale Multiplier} \times \text{Vote Multiplier}}{86400}$$

This hardware-accelerated component renders fluid 6-digit decimal increases in real-time.
