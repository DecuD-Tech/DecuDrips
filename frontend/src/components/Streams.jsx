import React from 'react';
import { FileText } from 'lucide-react';
import { getStreamRatePerSecond, calculateRating, calculateFeedbackMultiplier } from '../App';

export default function Streams({ streams, pools }) {
  return (
    <div id="view-streams" className="tab-view active">
      <div className="section-header">
        <div>
          <h2 className="section-title">Real-Time Drip Streams</h2>
          <p className="section-subtitle">Funds currently streaming from deployed contracts directly to documentation contributors.</p>
        </div>
        <div className="live-pulse-badge">
          <span className="pulse-dot"></span> Real-time Ledger Active
        </div>
      </div>
      <div className="streams-grid">
        {streams.map(stream => {
          const ratePerSec = getStreamRatePerSecond(stream, pools);
          const rating = calculateRating(stream);
          const multiplier = calculateFeedbackMultiplier(stream);

          let ratingColor = 'var(--clr-secondary)';
          if (rating >= 90) ratingColor = 'var(--clr-success)';
          else if (rating >= 75) ratingColor = 'var(--clr-warning)';

          return (
            <div key={stream.id} className="stream-card">
              <div className="sc-indicator"></div>
              <div className="stream-card-header">
                <div className="sc-author-info">
                  <div className="sc-avatar">{stream.author.substring(0, 2).toUpperCase()}</div>
                  <div>
                    <span className="sc-name">@{stream.author}</span>
                    <div className="sc-file">
                      <FileText size={14} />
                      <span>{stream.file}</span>
                    </div>
                  </div>
                </div>
                <span className="lang-pill">{stream.locale}</span>
              </div>
              
              <div className="sc-drip-counter">
                <span className="ticker-label">Dripping Rewards</span>
                <span className="ticker-value">${stream.accumulated.toFixed(5)}</span>
              </div>
              
              <div className="sc-metrics-row">
                <div className="sc-metric">
                  <span className="scm-lbl">Character Count</span>
                  <span className="scm-val">{stream.characters}</span>
                </div>
                <div className="sc-metric">
                  <span className="scm-lbl">Helpfulness Rating</span>
                  <span className="scm-val" style={{ color: ratingColor }}>{rating}%</span>
                </div>
                <div className="sc-metric">
                  <span className="scm-lbl">Live Flow Rate</span>
                  <span className="scm-val cyan">{(ratePerSec * 60).toFixed(3)}/min</span>
                </div>
                <div className="sc-metric">
                  <span className="scm-lbl">Multiplier</span>
                  <span className="scm-val">{multiplier}x</span>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
