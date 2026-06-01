import React, { useEffect, useState, useRef } from 'react';

/**
 * LiveTicker - High-fidelity animated counter that interpolates between 5-second polling updates.
 * 
 * @param {number} initialValue - The base balance fetched from the server.
 * @param {number} flowRatePerSecond - Computed stream reward rate in USDC/sec.
 */
export default function LiveTicker({ initialValue, flowRatePerSecond }) {
  const [displayValue, setDisplayValue] = useState(initialValue);
  const lastUpdateTimeRef = useRef(performance.now());
  const currentValueRef = useRef(initialValue);

  // Synchronize ref whenever a new baseline value is polled from the API
  useEffect(() => {
    currentValueRef.current = initialValue;
  }, [initialValue]);

  useEffect(() => {
    let animationFrameId;

    const tick = (now) => {
      const deltaSeconds = (now - lastUpdateTimeRef.current) / 1000;
      lastUpdateTimeRef.current = now;

      // Increment fractional amount based on the elapsed microseconds
      currentValueRef.current += flowRatePerSecond * deltaSeconds;
      setDisplayValue(currentValueRef.current);

      animationFrameId = requestAnimationFrame(tick);
    };

    lastUpdateTimeRef.current = performance.now();
    animationFrameId = requestAnimationFrame(tick);

    return () => cancelAnimationFrame(animationFrameId);
  }, [flowRatePerSecond]);

  return (
    <span className="ticker-value">
      ${displayValue.toFixed(6)}
    </span>
  );
}
