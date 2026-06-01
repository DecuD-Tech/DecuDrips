import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { PlusCircle, Rocket, Database, FolderGit2, AlertTriangle, ShieldAlert } from 'lucide-react';
import { api } from '../lib/api';
import { useAuthStore } from '../stores/authStore';

export default function Dashboard() {
  const queryClient = useQueryClient();
  const { user } = useAuthStore();
  const isSponsor = user?.role === 'sponsor';

  // Form states
  const [repoName, setRepoName] = useState('');
  const [fundingAmount, setFundingAmount] = useState(5000);
  const [baseRate, setBaseRate] = useState(0.02);
  const [formError, setFormError] = useState('');
  const [formSuccess, setFormSuccess] = useState('');

  // Query active repository pools
  const { data: pools = [], isLoading, error: queryError } = useQuery({
    queryKey: ['pools'],
    queryFn: () => api.get('/pools'),
  });

  // Mutation to deploy a new pool
  const createPoolMutation = useMutation({
    mutationFn: (newPool) => api.post('/pools', newPool),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['pools'] });
      queryClient.invalidateQueries({ queryKey: ['globalStats'] });
      setRepoName('');
      setFormSuccess(`Reward Pool successfully initialized for ${data.repo_full_name}!`);
      setFormError('');
      setTimeout(() => setFormSuccess(''), 5000);
    },
    onError: (err) => {
      setFormError(err.message || 'Failed to initialize pool.');
      setFormSuccess('');
    },
  });

  const handleCreatePool = (e) => {
    e.preventDefault();
    if (!isSponsor) {
      setFormError('Access Denied: Only sponsors can initialize reward pools.');
      return;
    }
    if (!repoName.trim()) {
      setFormError('Please enter a repository full name.');
      return;
    }

    createPoolMutation.mutate({
      repo_full_name: repoName,
      funding_amount: fundingAmount.toString(),
      base_rate: baseRate.toString(),
    });
  };

  return (
    <div id="view-dashboard" className="tab-view active">
      <div className="dashboard-grid">
        
        {/* Pool Creator Form (Sponsors Only) */}
        <div className="glass-card pool-creator">
          <div className="card-header">
            <h2 className="card-title">
              <PlusCircle className="title-icon" size={24} /> Initialize Doc Reward Pool
            </h2>
            <p className="card-subtitle">Deploy a new documentation pool to stream rewards for technical writers.</p>
          </div>

          {!isSponsor ? (
            <div className="role-restriction-notice" style={{ padding: '1.5rem', background: 'rgba(255, 0, 127, 0.05)', border: '1px solid rgba(255, 0, 127, 0.15)', borderRadius: '8px', textAlign: 'center' }}>
              <ShieldAlert size={32} style={{ color: 'var(--clr-secondary)', marginBottom: '0.75rem' }} />
              <h4 style={{ fontFamily: 'var(--font-display)', marginBottom: '0.25rem' }}>Contributor Account</h4>
              <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                Your GitHub account is registered as a writer. Only verified **Sponsor** organizations can deploy and fund micro-payment pools.
              </p>
            </div>
          ) : (
            <form id="pool-form" onSubmit={handleCreatePool}>
              {formError && (
                <div className="form-alert error" style={{ padding: '0.75rem 1rem', background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.2)', color: '#ef4444', borderRadius: '8px', fontSize: '0.8rem', marginBottom: '1rem' }}>
                  {formError}
                </div>
              )}
              {formSuccess && (
                <div className="form-alert success" style={{ padding: '0.75rem 1rem', background: 'rgba(16, 185, 129, 0.1)', border: '1px solid rgba(16, 185, 129, 0.2)', color: '#10b981', borderRadius: '8px', fontSize: '0.8rem', marginBottom: '1rem' }}>
                  {formSuccess}
                </div>
              )}

              <div className="form-group">
                <label htmlFor="pool-name">Repository / Project Name</label>
                <input 
                  type="text" 
                  id="pool-name" 
                  placeholder="e.g. stellar/stellar-sdk-js" 
                  value={repoName} 
                  onChange={(e) => setRepoName(e.target.value)} 
                  required 
                  disabled={createPoolMutation.isPending}
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label htmlFor="pool-funding">Funding Amount (USDC)</label>
                  <input 
                    type="number" 
                    id="pool-funding" 
                    value={fundingAmount} 
                    onChange={(e) => setFundingAmount(parseFloat(e.target.value))} 
                    min="100" 
                    required 
                    disabled={createPoolMutation.isPending}
                  />
                </div>
                <div className="form-group">
                  <label htmlFor="pool-rate">Base Rate (USDC/Char)</label>
                  <input 
                    type="number" 
                    id="pool-rate" 
                    value={baseRate} 
                    onChange={(e) => setBaseRate(parseFloat(e.target.value))} 
                    step="0.001" 
                    min="0.001" 
                    required 
                    disabled={createPoolMutation.isPending}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Simulated Localized Boosts</label>
                <div className="multipliers-grid">
                  <div className="multiplier-tag"><span>ES (Spanish)</span><strong>1.2x</strong></div>
                  <div className="multiplier-tag"><span>ZH (Chinese)</span><strong>1.5x</strong></div>
                  <div className="multiplier-tag"><span>DE (German)</span><strong>1.1x</strong></div>
                </div>
              </div>

              <button 
                type="submit" 
                className="action-btn-gradient" 
                disabled={createPoolMutation.isPending}
              >
                <span>{createPoolMutation.isPending ? 'Deploying Pool...' : 'Deploy Smart Pool'}</span>
                <Rocket size={18} />
              </button>
            </form>
          )}
        </div>

        {/* Active Pools List */}
        <div className="glass-card active-pools">
          <div className="card-header">
            <h2 className="card-title">
              <Database className="title-icon" size={24} /> Deployed Funding Pools
            </h2>
            <p className="card-subtitle">Repository contracts currently streaming micropayments on Github merges.</p>
          </div>

          {isLoading ? (
            <div style={{ textAlign: 'center', padding: '3rem 0', color: 'var(--text-muted)' }}>
              <div className="pulse-dot" style={{ margin: '0 auto 1rem' }}></div>
              Loading repository pools...
            </div>
          ) : queryError ? (
            <div style={{ padding: '1rem', background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.2)', color: '#ef4444', borderRadius: '8px', fontSize: '0.85rem' }}>
              Error fetching pools: {queryError.message}
            </div>
          ) : pools.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '3rem 1.5rem', color: 'var(--text-muted)', border: '1px dashed var(--border-light)', borderRadius: '8px' }}>
              <FolderGit2 size={36} style={{ margin: '0 auto 0.75rem', opacity: 0.4 }} />
              <p style={{ fontSize: '0.85rem' }}>No pools active yet. Deploy one to get started.</p>
            </div>
          ) : (
            <div className="table-container">
              <table className="premium-table">
                <thead>
                  <tr>
                    <th>Project Pool</th>
                    <th>Total Fund</th>
                    <th>Rate</th>
                    <th>Dripped</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {pools.map((pool) => (
                    <tr key={pool.id}>
                      <td>
                        <div className="table-repo-name">
                          <FolderGit2 size={16} style={{ color: 'var(--clr-primary)' }} />
                          <span>{pool.repo_full_name}</span>
                        </div>
                      </td>
                      <td style={{ fontWeight: 700 }}>
                        ${parseFloat(pool.funding_amount).toLocaleString()} <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>USDC</span>
                      </td>
                      <td>{parseFloat(pool.base_rate)}/char</td>
                      <td style={{ color: 'var(--clr-primary)', fontFamily: 'var(--font-display)', fontWeight: 700 }}>
                        ${parseFloat(pool.total_dripped).toFixed(2)}
                      </td>
                      <td>
                        <span className={`badge-status ${pool.status !== 'active' ? 'exhausted' : ''}`}>
                          {pool.status === 'active' ? 'Streaming' : pool.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
