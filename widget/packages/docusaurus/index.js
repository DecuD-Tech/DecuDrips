const path = require('path');

/**
 * Official Docusaurus plugin for DocuDrip Protocol (#5.1 / #9.3).
 * Automatically injects the DocuDrip Web Component script tag into Docusaurus site HTML head,
 * and provides swizzlable theme components.
 */
module.exports = function docuDripDocusaurusPlugin(context, options = {}) {
  const backendUrl = options.backendUrl || 'https://api.docudrip.org/api/v1';

  if (!options.backendUrl) {
    console.warn('[@docudrip/docusaurus-plugin] No backendUrl specified, defaulting to production API.');
  }

  return {
    name: '@docudrip/docusaurus-plugin',

    getThemePath() {
      return path.resolve(__dirname, './theme');
    },

    injectHtmlTags() {
      return {
        headTags: [
          {
            tagName: 'script',
            attributes: {
              src: `${backendUrl.replace('/api/v1', '')}/widget.js`,
              'data-backend-url': backendUrl,
              async: true,
            },
          },
        ],
      };
    },
  };
};
