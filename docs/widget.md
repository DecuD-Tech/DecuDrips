# Embeddable Feedback Widget (`widget/`)

The DocuDrip Feedback Widget is a lightweight, framework-agnostic web component designed to be embedded on any external documentation platform (e.g. Docusaurus, GitBook, Jekyll, or standard static HTML files).

It enables readers to vote on documentation helpfulness, sending metrics directly back to the database to adjust contributor rewards.

---

## 🔌 Integration & Embedding Guide

### 1. Load the Script
Add the standalone script tag referencing your target stream identifier to the head or body of your documentation template:

```html
<script src="http://localhost:8080/widget.js" 
        data-stream="YOUR_STREAM_UUID" 
        defer></script>
```

### 2. Add the Component Placeholder
Insert the custom `<docudrip-widget>` element wherever you want the feedback card to render (e.g., at the footer of your documentation page):

```html
<docudrip-widget data-stream="YOUR_STREAM_UUID"></docudrip-widget>
```

---

## 🎨 Shadow DOM Encapsulation

To shield the widget's typography, borders, and layouts from host page stylesheets, the component is fully sealed inside the **Shadow DOM**:

```javascript
class DocuDripWidget extends HTMLElement {
  constructor() {
    super();
    // Seals styles completely from outer page bleed
    this.attachShadow({ mode: 'open' });
  }
}
```

* **Style Integrity:** Global CSS resets, theme overrides, or font specifications on the parent site cannot bleed inside the widget.
* **Asset Loading:** On boot, the widget dynamically appends the stylesheet served from `http://localhost:8080/widget.css` inside its shadow root, maintaining visual branding.

---

## 🔒 Voting Security & Deduplication

* **Duplicate Voting Locks:** Once a reader upvotes or downvotes, the widget saves a key (`docudrip_voted_YOUR_STREAM_UUID: true`) inside the client's `localStorage`.
* **State Preservation:** On subsequent page loads, the widget detects this token, disables interactive buttons, and displays a success badge to prevent double voting.
* **CORS Permissiveness:** The public `/streams/:id/vote` backend API is fitted with a permissive CORS layer, enabling secure anonymous AJAX requests from any external documentation hosting domain.
