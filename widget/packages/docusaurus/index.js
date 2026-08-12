/**
 * Official Docusaurus plugin for DocuDrip Protocol (#9.3).
 * Automatically injects the DocuDrip Web Component script tag into Docusaurus site HTML head.
 */
module.exports = function docuDripDocusaurusPlugin(context, options) {
  const backendUrl = options.backendUrl || 'https://api.docudrip.org/api/v1';

  return {
    name: '@docudrip/docusaurus-plugin',

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
