import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { GitPullRequest, Merge, Smile, Droplet, ThumbsUp, ThumbsDown, Info, AlertCircle, CheckCircle2 } from 'lucide-react';
import { api } from '../lib/api';
import { calculateFeedbackMultiplier } from './Streams';

export default function Sandbox() {
  const queryClient = useQueryClient();
  const [author, setAuthor] = useState('techWriter99');
  const [filePath, setFilePath] = useState('docs/guide.md');
  const [additions, setAdditions] = useState(650);
  const [logs, setLogs] = useState([
    { id: 0, text: 'System: Bot terminal ready. Configure the pull request params above and click Merge to trigger validation.', type: 't-system' }
  ]);
  const [selectedStreamId, setSelectedStreamId] = useState('');
  const [simError, setSimError] = useState('');
  const [simSuccess, setSimSuccess] = useState('');

  // Fetch active streams and pools to drive the sandbox dropdowns
  const { data: streams = [], isLoading: streamsLoading } = useQuery({
    queryKey: ['streams'],
    queryFn: () => api.get('/streams'),
  });

  const { data: pools = [], isLoading: poolsLoading } = useQuery({
    queryKey: ['pools'],
    queryFn: () => api.get('/pools'),
  });

  const [selectedPoolId, setSelectedPoolId] = useState('');

  // Set default selection values once queries load
  React.useEffect(() => {
    if (streams.length > 0 && !selectedStreamId) {
      setSelectedStreamId(streams[0].id);
    }
  }, [streams, selectedStreamId]);

  React.useEffect(() => {
    if (pools.length > 0 && !selectedPoolId) {
      setSelectedPoolId(pools[0].id);
    }
  }, [pools, selectedPoolId]);

  // Mutation to record reader votes end-to-end
  const voteMutation = useMutation({
    mutationFn: ({ streamId, isUpvote }) => 
      api.post(`/streams/${streamId}/vote`, {
        is_upvote: isUpvote,
        voter_ip: `mock-ip-${Math.random().toString(36).substring(2, 6)}`, // Ensure unique mock IP
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['streams'] });
      queryClient.invalidateQueries({ queryKey: ['globalStats'] });
    },
    onError: (err) => {
      alert(err.message || 'Already voted or failed to record vote.');
    },
  });

  const handleVote = (isUpvote) => {
    if (!selectedStreamId) return;
    voteMutation.mutate({ streamId: selectedStreamId, isUpvote });
  };

  const simulatePRMerge = () => {
    if (!author.trim()) {
      alert('Please enter a contributor username!');
      return;
    }
    if (!selectedPoolId) {
      alert('Please deploy at least one reward pool first!');
      return;
    }

    const pool = pools.find(p => p.id === selectedPoolId);
    const locale = filePath.includes('/es/') ? 'es' : filePath.includes('/zh/') ? 'zh' : filePath.includes('/de/') ? 'de' : 'en';

    setLogs([{ id: Date.now() + 1, text: `Triggering local GitHub merge simulation for @${author}...`, type: 't-system' }]);

    setTimeout(() => {
      setLogs(prev => [...prev, { id: Date.now() + 2, text: `Analyzing commits in repository ${pool.repo_full_name}...`, type: 't-cmd' }]);
    }, 500);

    setTimeout(() => {
      setLogs(prev => [...prev, { id: Date.now() + 3, text: `Found doc modification: ${filePath} (+${additions} additions)`, type: 't-cmd' }]);
    }, 1000);

    setTimeout(() => {
      setLogs(prev => [
        ...prev,
        { id: Date.now() + 4, text: `Signature Bypass mode active for dev sandbox environment.`, type: 't-warning' },
        { id: Date.now() + 5, text: `CI build: PASSED ✅`, type: 't-success' },
        { id: Date.now() + 6, text: `Identified locale: [${locale.toUpperCase()}]`, type: 't-system' }
      ]);
    }, 1500);

    setTimeout(() => {
      setLogs(prev => [
        ...prev,
        { id: Date.now() + 7, text: `Continuous reward stream initialized successfully!`, type: 't-success' },
        { id: Date.now() + 8, text: `Please merge a real GitHub PR using webhooks to trigger the server-level HMAC verifier.`, type: 't-pink' }
      ]);
      queryClient.invalidateQueries({ queryKey: ['streams'] });
      queryClient.invalidateQueries({ queryKey: ['globalStats'] });
      setSimSuccess('Simulation executed! If you set up a mock client stream in your test database, query lists are refreshed.');
      setTimeout(() => setSimSuccess(''), 6000);
    }, 2200);
  };

  // Find active data details
  const selectedStream = streams.find(s => s.id === selectedStreamId);
  const rating = selectedStream ? Math.round(selectedStream.approval_ratio * 100) : 100;
  const multiplier = selectedStream ? calculateFeedbackMultiplier(selectedStream.approval_ratio) : 1.0;
  const flowRateMin = selectedStream ? (parseFloat(selectedStream.flow_rate_per_second) * 60).toFixed(4) : '0.0000';

  let ratingColor = 'var(--clr-secondary)';
  if (rating >= 90) ratingColor = 'var(--clr-success)';
  else if (rating >= 75) ratingColor = 'var(--clr-warning)';

  return (
    <div id="view-sandbox" className="tab-view active">
      <div className="sandbox-grid">
        
        {/* GitHub Bot Simulator Card */}
        <div className="glass-card sandbox-column">
          <div className="card-header">
            <h2 className="card-title"><GitPullRequest className="title-icon" size={24} /> GitHub Webhook Simulator</h2>
            <p className="card-subtitle">Simulate merging a documentation pull request to trigger the DocuDrip reward calculator.</p>
          </div>
          
          <div className="simulator-panel">
            {simSuccess && (
              <div style={{ padding: '0.75rem 1rem', background: 'rgba(16, 185, 129, 0.1)', border: '1px solid rgba(16, 185, 129, 0.2)', color: '#10b981', borderRadius: '8px', fontSize: '0.8rem' }}>
                {simSuccess}
              </div>
            )}
            
            <div className="form-group">
              <label htmlFor="sim-author">Contributor Username</label>
              <input 
                type="text" 
                id="sim-author" 
                value={author} 
                onChange={e => setAuthor(e.target.value)} 
                placeholder="e.g. techWriter99" 
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="sim-file">Documentation File Path</label>
              <select id="sim-file" value={filePath} onChange={e => setFilePath(e.target.value)}>
                <option value="docs/guide.md">docs/guide.md (English)</option>
                <option value="docs/es/getting_started.md">docs/es/getting_started.md (Spanish)</option>
                <option value="docs/zh/smart_contracts.md">docs/zh/smart_contracts.md (Chinese)</option>
                <option value="README.md">README.md (Core Overview)</option>
              </select>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="sim-diff">Character Additions</label>
                <input 
                  type="number" 
                  id="sim-diff" 
                  value={additions} 
                  onChange={e => setAdditions(parseInt(e.target.value))} 
                  min="50" 
                  max="10000" 
                />
              </div>
              <div className="form-group">
                <label htmlFor="sim-pool">Target Deployed Pool</label>
                <select id="sim-pool" value={selectedPoolId} onChange={e => setSelectedPoolId(e.target.value)}>
                  {poolsLoading ? (
                    <option>Loading pools...</option>
                  ) : pools.length === 0 ? (
                    <option value="">No pools deployed yet</option>
                  ) : (
                    pools.map(pool => (
                      <option key={pool.id} value={pool.id}>{pool.repo_full_name}</option>
                    ))
                  )}
                </select>
              </div>
            </div>
            
            <button onClick={simulatePRMerge} className="action-btn-secondary">
              <Merge size={18} /> Merge PR & Simulate Hook
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

        {/* Embedded Helpful Widget Preview */}
        <div className="glass-card sandbox-column">
          <div className="card-header">
            <h2 className="card-title"><Smile className="title-icon" size={24} /> Docs Feedback Widget (Sandbox Preview)</h2>
            <p className="card-subtitle">Submit real reader votes to `/vote` and watch the contributor's flow multiplier change immediately.</p>
          </div>
          
          <div className="widget-sandbox-wrapper">
            <div className="form-group">
              <label htmlFor="widget-stream-selector">Select Active Stream to Rate</label>
              <select 
                id="widget-stream-selector" 
                value={selectedStreamId} 
                onChange={e => setSelectedStreamId(e.target.value)}
                disabled={streamsLoading || streams.length === 0}
              >
                {streamsLoading ? (
                  <option>Loading streams...</option>
                ) : streams.length === 0 ? (
                  <option value="">No active streams found</option>
                ) : (
                  streams.map(stream => (
                    <option key={stream.id} value={stream.id}>
                      @{stream.author_username} ({stream.file_path.split('/').pop()})
                    </option>
                  ))
                )}
              </select>
            </div>

            {streams.length === 0 ? (
              <div className="mock-doc-container" style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-muted)' }}>
                <AlertCircle size={24} style={{ margin: '0 auto 0.5rem', opacity: 0.5 }} />
                <p>Deploy a reward pool and merge a PR to generate a stream contract for ratings.</p>
              </div>
            ) : selectedStream ? (
              <div className="mock-doc-container">
                <div className="mock-doc-header">
                  <span className="mock-doc-title">{selectedStream.pool_repo_name} / {selectedStream.file_path}</span>
                  <span className="mock-doc-lang">{selectedStream.locale}</span>
                </div>
                <div className="mock-doc-body">
                  <p><strong>Integration Guide:</strong></p>
                  <p>To initialize the micro-funding script on your site, add the following script tag containing your target stream identifier:</p>
                  <pre><code>{`<script src="http://localhost:8080/widget.js"\n        data-stream="${selectedStream.id}"></script>`}</code></pre>
                  <p className="mock-placeholder-text">This will inject the feedback box below directly into your documentation page's Shadow DOM, isolating styles and linking reader reactions directly to the continuous payouts system.</p>
                </div>

                <div className="docudrip-embedded-widget">
                  <div className="widget-brand">
                    <Droplet className="brand-drip" size={16} />
                    <span>Powered by DocuDrip</span>
                  </div>
                  <div className="widget-question">Was this documentation page helpful?</div>
                  <div className="widget-actions">
                    <button 
                      className="widget-vote-btn upvote" 
                      onClick={() => handleVote(true)}
                      disabled={voteMutation.isPending}
                    >
                      <ThumbsUp size={16} /> Helpful
                    </button>
                    <button 
                      className="widget-vote-btn downvote" 
                      onClick={() => handleVote(false)}
                      disabled={voteMutation.isPending}
                    >
                      <ThumbsDown size={16} /> Unhelpful
                    </button>
                  </div>
                  <div className="widget-meta">
                    Current Rating: <span className="rating-badge" style={{ color: ratingColor }}>{rating}%</span>
                  </div>
                </div>
              </div>
            ) : null}

            {selectedStream && (
              <div className="widget-effect-panel">
                <h4>Dynamic Flow-Multiplier Effect</h4>
                <div className="multiplier-display">
                  <div className="m-card">
                    <span className="m-lbl">Live Flow Rate</span>
                    <span className="m-val highlight">{flowRateMin} USDC/min</span>
                  </div>
                  <div className="m-card">
                    <span className="m-lbl">Calculated Multiplier</span>
                    <span className="m-val">{multiplier.toFixed(1)}x</span>
                  </div>
                </div>
                <p className="multiplier-explanation">
                  <Info className="info-icon" size={16} /> Upvotes scale the writer's micro-payout stream up to **1.5x** rewards. Downvotes reduce the rating and throttle flow rates down to **0.5x**.
                </p>
              </div>
            )}
          </div>
        </div>

      </div>
    </div>
  );
}
