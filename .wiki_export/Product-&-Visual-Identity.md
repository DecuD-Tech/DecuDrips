# DocuDrip — Product & Visual Identity System

This document outlines the product vision, core audience segments, visual personality directives, and design system tokens for DocuDrip. Maintainers, developers, and designers should reference these rules to ensure any new feature, screen, or widget adheres to the unified product ethos.

---

## 🎯 Product Purpose & Value Proposition

DocuDrip is a continuous documentation micro-sponsorship protocol. It solves the critical underfunding of open-source documentation by streaming automated, real-time rewards ("drips") directly to writers based on character contributions, translation locale multipliers, and direct community helpfulness metrics.

* **Stateless Financial Math:** Payout rates are calculated dynamically on-read, ensuring auditability and eliminating complex state synchronization.
* **Tension-Free Micro-payments:** Promotes sustained documentation maintenance over one-off bounty claims.
* **Direct Feedback Loop:** Embedding reader-rating elements connects reader helpfulness directly to the contributor's dynamic reward multiplier.

---

## 👥 Target Audience Profiles

### 1. Technical Writers & Contributors (Authors)
* **Needs:** Continuous recognition and direct compensation for detailed, sustained maintenance of guides, API references, and translations.
* **Values:** Highly readable text, simple markdown integrations, and smooth visual representations of accumulating reward flows.

### 2. Open-Source Maintainers (Organizers)
* **Needs:** Tools to attract high-quality writers, manage localization outreach, and evaluate docs helpfulness without overhead.
* **Values:** Automated webhook processing, reliable merge heuristics, and clear stream audit controls.

### 3. Sponsors & Organizations (Funders)
* **Needs:** Verifiable distribution of documentation grants and real-time visualization of funding allocations.
* **Values:** Strict escrow limits, compile-time query verifications, and professional role-restricted dashboard controls.

---

## 🧬 Brand Personality & Aesthetics

DocuDrip adopts a **"Dark Tech" / "Industrial"** design personality. The interface is engineered to feel like a high-precision, military-grade terminal or developer tool rather than a generic consumer application.

* **Utilitarian Density:** Prioritize functional dashboards with high information density, sharp contrast, and structured grids.
* **Tactile Elevation:** Cards and UI boundaries utilize flat depth, glassmorphic blurs, and crisp boundaries rather than heavy 3D skeuomorphism.
* **Focused Motion:** Animation is restricted purely to visual feedback, state transitions, and smooth decimal visual dripping.

---

## 🎨 Visual Design Tokens

Implemented as standard CSS variables inside `/frontend/src/index.css` and `/widget/src/widget.css`:

### 1. Color Palette

| Token Name | Hex Code | Visual Application |
|:---|:---|:---|
| **Base Background** | `#09090b` | Dark Zinc base, grounding the UI in high-contrast shadows. |
| **Glassmorphic Card** | `rgba(15, 15, 18, 0.65)` | Backdrop filter blurred containers (`12px`) for content isolation. |
| **Electric Cyan** | `#00f0ff` | Central primary accent, representing active state glows and flow tickers. |
| **Magenta / Pink** | `#ff007f` | Specialized multiplier badges, alerts, and high-performance boosts. |
| **Emerald Green** | `#10b981` | Success confirmations and helpfulness ratings $\ge 90\%$. |
| **Text Primary** | `#f4f4f5` | High-contrast off-white for reading comfort. |
| **Text Muted** | `#a1a1aa` | Medium-contrast silver for taglines, labels, and secondary keys. |

### 2. Structural Directives
* **Border Radii:** Locked strictly to **`8px`** for dashboards and **`6px`** for status badges.
* **Border Lines:** `1px` lines utilizing low-opacity whites (`rgba(255,255,255,0.08)`).

### 3. Typography Hierarchy
* **Headings & Quantitative Numbers:** **Space Grotesk**
* **Body Text & Heuristics:** **Inter**
* **Code Blocks & CLI Terminals:** **JetBrains Mono**

---

## 🚫 Brand Anti-References (Banned Cheap Patterns)

* ❌ **No AI Purples & Blue Glows:** Avoid generic gradient flows; lock accents to Electric Cyan and Magenta.
* ❌ **No Warm Off-Whites or Beige:** Backgrounds must stay inside the cold dark zinc spectrum.
* ❌ **No Playful Softness:** Banish large border-radius settings (`32px` or pill-shaped cards).
* ❌ **No Placeholders:** All sections must feature actual working code or interactive data visualizations.
