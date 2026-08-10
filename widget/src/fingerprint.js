/**
 * Generates a lightweight, privacy-preserving browser fingerprint hash (#5.3).
 * Combines language, screen resolution, timezone offset, hardware concurrency,
 * and low-entropy canvas rendering into a non-tracking hash.
 */
export function generateFingerprint() {
  try {
    const components = [
      navigator.language || '',
      screen.width + 'x' + screen.height,
      screen.colorDepth || 24,
      new Date().getTimezoneOffset(),
      navigator.hardwareConcurrency || 2,
      (() => {
        try {
          const canvas = document.createElement('canvas');
          const ctx = canvas.getContext('2d');
          ctx.textBaseline = 'top';
          ctx.font = '14px Arial';
          ctx.fillText('DocuDrip', 2, 2);
          return canvas.toDataURL().slice(-32);
        } catch {
          return 'no-canvas';
        }
      })(),
    ];

    const raw = components.join('|');
    let hash = 0;
    for (let i = 0; i < raw.length; i++) {
      hash = ((hash << 5) - hash + raw.charCodeAt(i)) | 0;
    }
    return Math.abs(hash).toString(36);
  } catch {
    return 'fallback_fp';
  }
}
