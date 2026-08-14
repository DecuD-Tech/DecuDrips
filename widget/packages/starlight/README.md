# @docudrip/starlight-astro

Official Astro Starlight plugin and component for the **DocuDrip Protocol** — bringing continuous micro-rewards and interactive reader feedback widgets to Astro Starlight documentation sites.

---

## Installation

```bash
npm install @docudrip/starlight-astro
# or
yarn add @docudrip/starlight-astro
# or
pnpm add @docudrip/starlight-astro
```

---

## Configuration

Add the plugin to your `astro.config.mjs`:

```javascript
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import docuDripStarlight from '@docudrip/starlight-astro';

export default defineConfig({
  integrations: [
    starlight({
      title: 'My Docs',
      plugins: [
        docuDripStarlight({
          backendUrl: 'https://api.docudrip.org/api/v1', // Optional
        }),
      ],
    }),
  ],
});
```

---

## Usage

Import the Astro component in your custom layout, page, or footer override:

```astro
---
import DocuDripWidget from '@docudrip/starlight-astro/DocuDripWidget.astro';
---

<footer>
  <DocuDripWidget streamId="YOUR_STREAM_UUID" />
</footer>
```

---

## License

MIT © DecuD-Tech
