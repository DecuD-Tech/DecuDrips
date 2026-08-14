/**
 * DecuDrip GitBook Integration Embed Script (#5.3 / #9.5)
 * Lightweight (<1.5KB) embed script that bootstraps the DocuDrip Web Component
 * and auto-injects <docudrip-widget> into GitBook documentation page layouts.
 *
 * Usage in GitBook Custom Header HTML:
 *   <script src="https://api.docudrip.org/gitbook.js"
 *           data-backend-url="https://api.docudrip.org/api/v1"
 *           data-stream="YOUR_STREAM_UUID"></script>
 */
(function () {
  'use strict';

  var script = document.currentScript;
  if (!script) return;

  var backendUrl = script.getAttribute('data-backend-url') || 'https://api.docudrip.org/api/v1';
  var streamId = script.getAttribute('data-stream');

  function injectWidget() {
    // 1. Ensure the core widget.js Web Component script is loaded
    if (!customElements.get('docudrip-widget')) {
      var widgetScript = document.createElement('script');
      widgetScript.src = backendUrl.replace('/api/v1', '') + '/widget.js';
      widgetScript.setAttribute('data-backend-url', backendUrl);
      widgetScript.async = true;
      document.head.appendChild(widgetScript);
    }

    // 2. If a stream ID is provided, auto-inject into GitBook page structure
    if (streamId && !document.querySelector('docudrip-widget[data-stream="' + streamId + '"]')) {
      var target =
        document.querySelector('.page-inner') ||
        document.querySelector('main') ||
        document.querySelector('.markdown-section') ||
        document.querySelector('[data-testid="page.content"]') ||
        document.body;

      if (target) {
        var widget = document.createElement('docudrip-widget');
        widget.setAttribute('data-stream', streamId);
        target.appendChild(widget);
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', injectWidget);
  } else {
    injectWidget();
  }
})();
