# React Dashboard Client (`frontend/`)

The frontend of DocuDrip is a high-density, glassmorphic single-page application built using **React 19**, **Vite 8**, **Zustand**, and **React Query**.

---

## 🏗️ State & Cache Architecture

To maintain a responsive UI with minimal network overhead, the frontend divides its state management:

### 1. React Query (`@tanstack/react-query`) — Server Cache
* Handles all data fetches (`GET /pools`, `GET /streams`, `GET /stats`).
* Automatically coordinates **5-second background polling** on active streams and statistics, maintaining a lively look without overloading the server.
* Handles data mutations (`POST /pools`, `POST /streams/:id/vote`), immediately invalidating query caches upon success to trigger UI updates.

### 2. Zustand — Client State
* **`authStore.js`**: Tracks active authenticated user sessions, roles (`sponsor` / `contributor`), and handles OAuth redirections and JWT token persistence inside `localStorage`.
* **`poolStore.js`**, **`streamStore.js`**, **`statsStore.js`**: Manage visual search filters, dashboard metric ranges, and table sorting options.

---

## 🛡️ Routing & Navigation Guards

Routing is coordinated in `App.jsx` using `react-router-dom`:

* **Public Paths:**
  * `/login`: Houses the sleek glassmorphic GitHub OAuth button.
  * `/auth/callback`: Collects incoming cryptographic JWT parameters from the backend callback and establishes the session.
* **Protected Paths (`/*`):**
  * Wrapped inside a `RequireAuth` guard. If no token is detected, users are redirected to `/login`.
  * Sponsors are presented with the "Deploy Smart Pool" creator panel, while Standard Contributors are automatically restricted to read-only views with informative status banners.

---

## 💎 The `LiveTicker` Decimal Interpolator

Because active streams are polled from the server every 5 seconds, displaying standard numbers would cause balances to jump abruptly. We solved this by developing `LiveTicker.jsx`, which continuously interpolates values on the client side:

```javascript
// High-performance decimal progression
const tick = (now) => {
  const deltaSeconds = (now - lastUpdateTimeRef.current) / 1000;
  lastUpdateTimeRef.current = now;

  // Increment fractional amount based on precise elapsed microseconds
  currentValueRef.current += flowRatePerSecond * deltaSeconds;
  setDisplayValue(currentValueRef.current);

  animationFrameId = requestAnimationFrame(tick);
};
```

### Flow Rate Calculations
The flow rate per second returned by the backend is determined as:
$$\text{Rate (USDC/sec)} = \frac{\text{Character Count} \times \text{Base Rate} \times \text{Locale Multiplier} \times \text{Vote Multiplier}}{86400}$$

By feeding this rate directly into our hardware-accelerated `LiveTicker` component, the UI renders fluid decimal increases up to 6 digits, simulating real-time streaming payments.
