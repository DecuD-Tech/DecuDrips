# Embeddable Feedback Widget (`widget/`)

The DocuDrip Feedback Widget is a lightweight, framework-agnostic web component designed to be embedded on any external documentation platform (e.g. Docusaurus, GitBook, Jekyll, or static HTML files).

---

## 🔌 Integration & Embedding Guide

### 1. Load the Script
```html
<script src="http://localhost:8080/widget.js" 
        data-stream="YOUR_STREAM_UUID" 
        defer></script>
```

### 2. Add the Component Placeholder
```html
<docudrip-widget data-stream="YOUR_STREAM_UUID"></docudrip-widget>
```

---

## 🎨 Shadow DOM Encapsulation

To shield typography, borders, and layouts from host page stylesheets, the component is fully sealed inside the **Shadow DOM**:

```javascript
class DocuDripWidget extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }
}
```

---

## 🔒 Voting Security & Deduplication

* **Duplicate Voting Locks:** Stores `docudrip_voted_YOUR_STREAM_UUID: true` inside client `localStorage`.
* **CORS Permissiveness:** Public `/streams/:id/vote` backend API enables secure anonymous AJAX requests from external docs domains.
