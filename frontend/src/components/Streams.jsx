import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { FileText, Activity, HeartHandshake } from 'lucide-react';
import { api } from '../lib/api';
import LiveTicker from './LiveTicker';

// Client-side mapping of approval ratio to visual multiplier rating
export const calculateFeedbackMultiplier = (approvalRatio) => {
  const rating = Math.round(approvalRatio * 100);
  if (rating >= 95) return 1.5;
  if (rating >= 90) return 1.2;
  if (rating >= 75) return 1.0;
  if (rating >= 60) return 0.8;
  return 0.5;
};

export default function Streams() {
  // Query active streams from the server with continuous polling
  const { data: streams = [], isLoading, error } = useQuery({
    queryKey: ['streams'],
    queryFn: () => api.get('/streams'),
    refetchInterval: 5000, // Background updates every 5 seconds
  });

  return (
    <div id="view-streams" className="tab-view active">
      <div className="section-header">
        <div>
          <h2 className="section-title">Continuous Drip Streams</h2>
          <p className="section-subtitle">Real-time rewards flowing directly to technical writers based on documentation merges.</p>
        </div>
        <div className="live-pulse-badge">
          <span className="pulse-dot"></span> Dynamic Ledger Synchronized
        </div>
      </div>

      {isLoading ? (
        <div style={{ textAlign: 'center', padding: '5rem 0', color: 'var(--text-muted)' }}>
          <div className="pulse-dot" style={{ margin: '0 auto 1.5rem' }}></div>
          Checking data streams...
        </div>
      ) : error ? (
        <div style={{ padding: '1rem', background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.2)', color: '#ef4444', borderRadius: '8px', fontSize: '0.85rem' }}>
          Error loading stream metrics: {error.message}
        </div>
      ) : streams.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '5rem 2rem', color: 'var(--text-muted)', border: '1px dashed var(--border-light)', borderRadius: '8px' }}>
          <Activity size={40} style={{ margin: '0 auto 1rem', opacity: 0.3 }} />
          <p style={{ fontSize: '0.9rem' }}>No active drip streams found in the protocol. Merge a documentation PR to spawn one.</p>
        </div>
      ) : (
        <div className="streams-grid">
          {streams.map((stream) => {
            const rating = Math.round(stream.approval_ratio * 100);
            const multiplier = calculateFeedbackMultiplier(stream.approval_ratio);

            let ratingColor = 'var(--clr-secondary)'; // Muted/Pink
            if (rating >= 90) ratingColor = 'var(--clr-success)'; // Green
            else if (rating >= 75) ratingColor = 'var(--clr-warning)'; // Orange/Amber

            return (
              <div key={stream.id} className="stream-card">
                <div className="sc-indicator"></div>
                <div className="stream-card-header">
                  <div className="sc-author-info">
                    <div className="sc-avatar">{stream.author_username.substring(0, 2).toUpperCase()}</div>
                    <div>
                      <span className="sc-name">@{stream.author_username}</span>
                      <div className="sc-file">
                        <FileText size={14} />
                        <span title={stream.file_path}>
                          {stream.file_path.length > 25 ? `...${stream.file_path.substring(stream.file_path.length - 22)}` : stream.file_path}
                        </span>
                      </div>
                    </div>
                  </div>
                  <span className="lang-pill">{stream.locale}</span>
                </div>
                
                {/* Embedded High-Fidelity Ticker */}
                <div className="sc-drip-counter">
                  <span className="ticker-label">Continuous Payout</span>
                  <LiveTicker 
                    initialValue={parseFloat(stream.accumulated)} 
                    flowRatePerSecond={parseFloat(stream.flow_rate_per_second)} 
                  />
                </div>
                
                <div className="sc-metrics-row">
                  <div className="sc-metric">
                    <span className="scm-lbl">Character Count</span>
                    <span className="scm-val">{stream.character_count}</span>
                  </div>
                  <div className="sc-metric">
                    <span className="scm-lbl">Helpfulness Rating</span>
                    <span className="scm-val" style={{ color: ratingColor }}>{rating}%</span>
                  </div>
                  <div className="sc-metric">
                    <span className="scm-lbl">Flow Rate (USDC/min)</span>
                    <span className="scm-val cyan">{(parseFloat(stream.flow_rate_per_second) * 60).toFixed(4)}</span>
                  </div>
                  <div className="sc-metric">
                    <span className="scm-lbl">Multiplier</span>
                    <span className="scm-val">{multiplier.toFixed(1)}x</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
