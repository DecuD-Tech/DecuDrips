# @docudrip/gitbook-integration

Official zero-dependency embed loader script for the **DocuDrip Protocol** on GitBook documentation spaces.

---

## Features

- 🪶 **Ultra-lightweight:** `< 1.5 KB` unminified bundle size.
- ⚡ **Zero dependencies:** Self-contained script running natively in modern browsers.
- 🔄 **Auto-injection:** Automatically targets GitBook layout structures (`.page-inner`, `.markdown-section`, `main`).

---

## Usage in GitBook

### Option 1: GitBook Custom HTML (Recommended)
In your GitBook Space settings under **Customization → Custom HTML (Head)**, paste:

```html
<script
  src="https://api.docudrip.org/widget.js"
  data-backend-url="https://api.docudrip.org/api/v1"
  async
></script>
```

Then place the custom tag inside your documentation markdown or footer block:

```html
<docudrip-widget data-stream="YOUR_STREAM_UUID"></docudrip-widget>
```

---

### Option 2: Automated Embed Script
Alternatively, include the dedicated embed script with `data-stream`:

```html
<script
  src="https://cdn.docudrip.dev/gitbook.js"
  data-backend-url="https://api.docudrip.org/api/v1"
  data-stream="YOUR_STREAM_UUID"
  async
></script>
```

---

## License

MIT © DecuD-Tech
