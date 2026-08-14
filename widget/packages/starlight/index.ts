import type { StarlightPlugin } from '@astrojs/starlight/types';

export interface DocuDripStarlightOptions {
  backendUrl?: string;
}

/**
 * Official Starlight Astro integration plugin for DocuDrip Protocol (#5.2 / #9.4).
 * Configures automatic integration hooks and defines environment constants for DocuDrip widgets.
 */
export default function docuDripStarlight(
  options: DocuDripStarlightOptions = {}
): StarlightPlugin {
  const backendUrl = options.backendUrl || 'https://api.docudrip.org/api/v1';

  return {
    name: '@docudrip/starlight-astro',
    hooks: {
      setup({ addIntegration }) {
        addIntegration({
          name: '@docudrip/starlight-astro-integration',
          hooks: {
            'astro:config:setup'({ updateConfig }) {
              updateConfig({
                vite: {
                  define: {
                    __DOCUDRIP_BACKEND_URL__: JSON.stringify(backendUrl),
                  },
                },
              });
            },
          },
        });
      },
    },
  };
}
