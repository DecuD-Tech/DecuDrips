import React, { useState } from 'react';
import { GitPullRequest, Merge, Smile, Droplet, ThumbsUp, ThumbsDown, Info } from 'lucide-react';
import { getStreamRatePerSecond, calculateRating, calculateFeedbackMultiplier } from '../App';

export default function Sandbox({ streams, setStreams, pools }) {
  const [author, setAuthor] = useState('alphaCoder');
  const [file, setFile] = useState('README.md');
  const [diff, setDiff] = useState(450);
  const [poolId, setPoolId] = useState(pools[0]?.id || 0);
  const [logs, setLogs] = useState([
    { id: 0, text: 'System: Terminal ready. Select parameters above and merge to see the automated CI pipeline checks.', type: 't-system' }
  ]);
  const [currentWidgetStreamId, setCurrentWidgetStreamId] = useState(streams[0]?.id || null);

  const simulatePRMerge = () => {
    if (!author.trim()) {
      alert('Please enter a contributor username!');
      return;
    }

    const pool = pools.find(p => p.id === parseInt(poolId));
    const locale = file.includes('.') ? file.split('.')[file.split('.').length - 2] : 'en';

    setLogs([{ id: Date.now() + 1, text: `Fetching metadata for PR from @${author}...`, type: 't-system' }]);

    setTimeout(() => {
      setLogs(prev => [...prev, { id: Date.now() + 2, text: `Checking modified files: found ${file} (+${diff} characters)`, type: 't-cmd' }]);
    }, 600);

    setTimeout(() => {
      setLogs(prev => [
        ...prev,
        { id: Date.now() + 3, text: `Lint check: SUCCESS ✅`, type: 't-success' },
        { id: Date.now() + 4, text: `Localization Check: Locale identified as [${locale.toUpperCase()}]`, type: 't-system' },
        ...(locale !== 'en' ? [{ id: Date.now() + 5, text: `Locale multiplier matched: ${pool.mults[locale]}x base rate`, type: 't-pink' }] : [])
      ]);
    }, 1200);

    setTimeout(() => {
      setLogs(prev => [
        ...prev,
        { id: Date.now() + 6, text: `Deploying stream contract on-chain...`, type: 't-cmd' },
        { id: Date.now() + 7, text: `Init params: base_rate=${pool.rate} USDC/char, stream_period=30d`, type: 't-system' }
      ]);
    }, 1800);

    setTimeout(() => {
      const newId = `stream-${streams.length + 1}`;
      setStreams(prev => [
        ...prev,
        {
          id: newId,
          author,
          poolId: parseInt(poolId),
          file,
          characters: diff,
          locale,
          accumulated: 0,
          upvotes: 1,
          totalVotes: 1
        }
      ]);
      setLogs(prev => [
        ...prev,
        { id: Date.now() + 8, text: `Smart contract successfully linked! Sparking real-time stream.`, type: 't-success' },
        { id: Date.now() + 9, text: `New stream ID: ${newId} initialized. Rewards flowing!`, type: 't-pink' }
      ]);
    }, 2400);
  };

  const voteWidget = (type) => {
    setStreams(prevStreams => {
      return prevStreams.map(stream => {
        if (stream.id === currentWidgetStreamId) {
          return {
            ...stream,
            totalVotes: stream.totalVotes + 1,
            upvotes: stream.upvotes + (type === 'up' ? 1 : 0)
          };
        }
        return stream;
      });
    });
  };

  const selectedStream = streams.find(s => s.id === currentWidgetStreamId);
  const selectedPool = selectedStream ? pools.find(p => p.id === parseInt(selectedStream.poolId)) : null;

  let rating = 100;
  let ratePerSec = 0;
  let feedbackMult = 1;
  if (selectedStream) {
    rating = calculateRating(selectedStream);
    ratePerSec = getStreamRatePerSecond(selectedStream, pools);
    feedbackMult = calculateFeedbackMultiplier(selectedStream);
  }

  let ratingColor = 'var(--clr-secondary)';
  if (rating >= 90) ratingColor = 'var(--clr-success)';
  else if (rating >= 75) ratingColor = 'var(--clr-warning)';

  return (
    <div id="view-sandbox" className="tab-view active">
      <div className="sandbox-grid">
        <div className="glass-card sandbox-column">
          <div className="card-header">
            <h2 className="card-title"><GitPullRequest className="title-icon" size={24} /> GitHub Bot Simulator</h2>
            <p className="card-subtitle">Simulate merging a doc or localization pull request to trigger a real-time smart stream.</p>
          </div>
          <div className="simulator-panel">
            <div className="form-group">
              <label htmlFor="sim-author">Contributor Username</label>
              <input type="text" id="sim-author" value={author} onChange={e => setAuthor(e.target.value)} placeholder="e.g. techWriter99" required />
            </div>
            <div className="form-group">
              <label htmlFor="sim-file">Documentation File / Path</label>
              <select id="sim-file" value={file} onChange={e => setFile(e.target.value)}>
                <option value="README.md">README.md (Core Guide)</option>
                <option value="getting_started.es.md">getting_started.es.md (Spanish Guide)</option>
                <option value="smart_contracts.zh.md">smart_contracts.zh.md (Chinese Setup)</option>
                <option value="advanced_api_reference.md">advanced_api_reference.md (API docs)</option>
              </select>
            </div>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="sim-diff">Character Count Added</label>
                <input type="number" id="sim-diff" value={diff} onChange={e => setDiff(parseInt(e.target.value))} min="50" max="5000" />
              </div>
              <div className="form-group">
                <label htmlFor="sim-pool">Select Project Pool</label>
                <select id="sim-pool" value={poolId} onChange={e => setPoolId(parseInt(e.target.value))}>
                  {pools.map(pool => (
                    <option key={pool.id} value={pool.id}>{pool.name}</option>
                  ))}
                </select>
              </div>
            </div>
            <button onClick={simulatePRMerge} className="action-btn-secondary">
              <Merge size={18} /> Merge PR & Spark Stream
            </button>

            <div className="terminal-box">
              <div className="terminal-header">
                <div className="terminal-buttons"><span></span><span></span><span></span></div>
                <div className="terminal-title">docudrip-bot-cli</div>
              </div>
              <div className="terminal-content" id="terminal-log">
                {logs.map(log => (
                  <span key={log.id} className={log.type}>{`> ${log.text}`}</span>
                ))}
              </div>
            </div>
          </div>
        </div>

        <div className="glass-card sandbox-column">
          <div className="card-header">
            <h2 className="card-title"><Smile className="title-icon" size={24} /> Docs Helpful Widget (Live Preview)</h2>
            <p className="card-subtitle">See how reader feedback dynamically scales a contributor's stream multiplier in real time.</p>
          </div>
          <div className="widget-sandbox-wrapper">
            <div className="form-group">
              <label htmlFor="widget-stream-selector">Select Active Stream to Rate</label>
              <select id="widget-stream-selector" value={currentWidgetStreamId} onChange={e => setCurrentWidgetStreamId(e.target.value)}>
                {streams.map(stream => (
                  <option key={stream.id} value={stream.id}>{stream.author} ({stream.file})</option>
                ))}
              </select>
            </div>

            {selectedStream && selectedPool && (
              <div className="mock-doc-container">
                <div className="mock-doc-header">
                  <span className="mock-doc-title" id="mock-doc-title">{selectedPool.name.split('/')[1] || selectedPool.name} / {selectedStream.file}</span>
                  <span className="mock-doc-lang" id="mock-doc-lang">{selectedStream.locale}</span>
                </div>
                <div className="mock-doc-body">
                  <p><strong>Quick Start Guide:</strong></p>
                  <p>To initialize the client, construct an instance pointing to the public horizon endpoint:</p>
                  <pre><code>{`const server = new Horizon.Server("https://horizon.stellar.org");\nconst client = await server.accounts().accountId(PUB_KEY).call();`}</code></pre>
                  <p className="mock-placeholder-text">This SDK allows developers to easily query accounts, build transactions, and submit them securely on-chain. Follow the remaining sections below to set up a listener for real-time transaction updates.</p>
                </div>

                <div className="docudrip-embedded-widget">
                  <div className="widget-brand">
                    <Droplet className="brand-drip" size={16} />
                    <span>Powered by DocuDrip</span>
                  </div>
                  <div className="widget-question">Was this documentation page helpful?</div>
                  <div className="widget-actions">
                    <button className="widget-vote-btn upvote" onClick={() => voteWidget('up')}>
                      <ThumbsUp size={16} /> Helpful
                    </button>
                    <button className="widget-vote-btn downvote" onClick={() => voteWidget('down')}>
                      <ThumbsDown size={16} /> Unhelpful
                    </button>
                  </div>
                  <div className="widget-meta">
                    Current Rating: <span className="rating-badge" style={{ color: ratingColor }}>{rating}%</span>
                    ({selectedStream.totalVotes} readers)
                  </div>
                </div>
              </div>
            )}

            <div className="widget-effect-panel">
              <h4>Real-time Multiplier Impact</h4>
              <div className="multiplier-display">
                <div className="m-card">
                  <span className="m-lbl">Current Stream Rate</span>
                  <span className="m-val highlight">{(ratePerSec * 60).toFixed(4)} USDC/min</span>
                </div>
                <div className="m-card">
                  <span className="m-lbl">Feedback Multiplier</span>
                  <span className="m-val">{feedbackMult.toFixed(1)}x</span>
                </div>
              </div>
              <p className="multiplier-explanation">
                <Info className="info-icon" size={16} /> Upvotes increase the reader rating, scaling the contributor's stream multiplier up to **1.5x**. Downvotes drop the rating and can throttle the multiplier down to **0.5x**.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
