# @docudrip/docusaurus-plugin

Official Docusaurus plugin for the **DocuDrip Protocol** — enabling continuous micro-rewards and interactive reader feedback widgets on open-source documentation portals.

---

## Installation

```bash
npm install @docudrip/docusaurus-plugin
# or
yarn add @docudrip/docusaurus-plugin
# or
pnpm add @docudrip/docusaurus-plugin
```

---

## Configuration

Add the plugin to your `docusaurus.config.js`:

```javascript
module.exports = {
  // ... other docusaurus config
  plugins: [
    [
      '@docudrip/docusaurus-plugin',
      {
        backendUrl: 'https://api.docudrip.org/api/v1', // Optional, defaults to production
      },
    ],
  ],
};
```

---

## Usage

### 1. Direct Web Component Embedding
Once the plugin is installed, `<docudrip-widget>` is automatically registered on every doc page:

```html
<docudrip-widget data-stream="YOUR_STREAM_UUID"></docudrip-widget>
```

### 2. Swizzling the Footer Component
You can import or swizzle the React component into your custom doc page footer:

```jsx
import DocuDripFooter from '@docudrip/docusaurus-plugin/theme/DocuDripFooter';

export default function CustomDocFooter({ streamId }) {
  return (
    <footer>
      <DocuDripFooter streamId={streamId} />
    </footer>
  );
}
```

---

## License

MIT © DecuD-Tech
