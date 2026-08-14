import React from 'react';

/**
 * DocuDripFooter Component
 * Swizzlable React component to embed the DocuDrip continuous reward widget
 * into Docusaurus documentation page footers.
 *
 * @param {{ streamId: string, className?: string }} props
 */
export default function DocuDripFooter({ streamId, className = '' }) {
  if (!streamId) return null;

  return (
    <div className={`docudrip-footer-container ${className}`.trim()}>
      <docudrip-widget data-stream={streamId} />
    </div>
  );
}
