import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Wallet, DollarSign, CheckCircle2, AlertCircle, ArrowUpRight } from 'lucide-react';
import { api } from '../lib/api';
import { useClaimStore } from '../stores/claimStore';

export default function ClaimPage() {
  const queryClient = useQueryClient();
  const { selectedStreamId, setSelectedStreamId, claimAmount, setClaimAmount } = useClaimStore();
  const [submitError, setSubmitError] = useState(null);

  // Fetch active streams to claim from
  const { data: streams } = useQuery({
    queryKey: ['streams'],
    queryFn: () => api.get('/streams'),
  });

  // Fetch user claims
  const { data: claims, isLoading: claimsLoading } = useQuery({
    queryKey: ['claims'],
    queryFn: () => api.get('/claims'),
  });

  // Fetch registered settlement accounts
  const { data: accounts } = useQuery({
    queryKey: ['settlementAccounts'],
    queryFn: () => api.get('/settlement-accounts'),
  });

  // Claim mutation
  const claimMutation = useMutation({
    mutationFn: (newClaim) => api.post('/claims', newClaim),
    onSuccess: () => {
      queryClient.invalidateQueries(['claims']);
      queryClient.invalidateQueries(['streams']);
      setSubmitError(null);
      setClaimAmount('');
      setSelectedStreamId(null);
    },
    onError: (err) => {
      setSubmitError(err.message || 'Failed to submit claim request');
    },
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!selectedStreamId || !claimAmount) {
      setSubmitError('Please select a stream and enter a valid amount');
      return;
    }
    const val = parseFloat(claimAmount);
    if (val < 1.0) {
      setSubmitError('Minimum claim threshold is $1.00 USDC');
      return;
    }
    claimMutation.mutate({
      stream_id: selectedStreamId,
      amount: val,
      settlement_id: accounts?.[0]?.id || null,
    });
  };

  return (
    <div className="claims-view-container" style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      <div className="section-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Wallet style={{ color: 'var(--clr-primary)' }} /> Claim & Payout Management
          </h2>
          <p style={{ color: 'var(--clr-text-muted)', marginTop: '0.25rem' }}>
            Withdraw accumulated continuous documentation rewards to your verified settlement account.
          </p>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
        {/* Claim Submission Form */}
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ marginBottom: '1rem', fontSize: '1.1rem' }}>Submit New Claim</h3>
          {submitError && (
            <div style={{ padding: '0.75rem', background: 'rgba(255, 0, 127, 0.1)', border: '1px solid var(--clr-accent-pink)', borderRadius: '6px', color: 'var(--clr-accent-pink)', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <AlertCircle size={16} /> {submitError}
            </div>
          )}

          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div>
              <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem', color: 'var(--clr-text-muted)' }}>Target Stream</label>
              <select
                value={selectedStreamId || ''}
                onChange={(e) => setSelectedStreamId(e.target.value)}
                style={{ width: '100%', padding: '0.75rem', background: '#09090b', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '6px', color: '#fff' }}
              >
                <option value="">-- Select Documentation Stream --</option>
                {streams?.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.file_path} (${parseFloat(s.accumulated || 0).toFixed(4)} USDC)
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem', color: 'var(--clr-text-muted)' }}>Claim Amount (USDC)</label>
              <input
                type="number"
                step="0.01"
                min="1.00"
                placeholder="10.00"
                value={claimAmount}
                onChange={(e) => setClaimAmount(e.target.value)}
                style={{ width: '100%', padding: '0.75rem', background: '#09090b', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '6px', color: '#fff' }}
              />
              <span style={{ fontSize: '0.75rem', color: 'var(--clr-text-muted)', marginTop: '0.25rem', display: 'block' }}>
                Minimum claim threshold: $1.00 USDC (Safety Cap: Max 25% pool drawdown / 3 claims daily)
              </span>
            </div>

            <button
              type="submit"
              disabled={claimMutation.isPending}
              style={{
                padding: '0.75rem 1.5rem',
                background: 'var(--clr-primary)',
                color: '#000',
                fontWeight: 600,
                border: 'none',
                borderRadius: '6px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '0.5rem',
              }}
            >
              {claimMutation.isPending ? 'Processing Lock...' : 'Initiate Claim Request'} <ArrowUpRight size={16} />
            </button>
          </form>
        </div>

        {/* Recent Claims List */}
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ marginBottom: '1rem', fontSize: '1.1rem' }}>Claim History</h3>
          {claimsLoading ? (
            <p>Loading claims history...</p>
          ) : claims?.length === 0 ? (
            <p style={{ color: 'var(--clr-text-muted)' }}>No reward claims submitted yet.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {claims?.map((c) => (
                <div key={c.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0.75rem', background: 'rgba(255,255,255,0.03)', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.06)' }}>
                  <div>
                    <span style={{ fontWeight: 600, fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                      <DollarSign size={14} style={{ color: 'var(--clr-primary)' }} /> {parseFloat(c.amount).toFixed(2)} USDC
                    </span>
                    <span style={{ fontSize: '0.75rem', color: 'var(--clr-text-muted)' }}>
                      {new Date(c.claimed_at).toLocaleString()}
                    </span>
                  </div>
                  <span style={{
                    padding: '0.25rem 0.5rem',
                    borderRadius: '4px',
                    fontSize: '0.75rem',
                    fontWeight: 600,
                    background: c.status === 'settled' ? 'rgba(16, 185, 129, 0.15)' : 'rgba(255, 255, 255, 0.1)',
                    color: c.status === 'settled' ? '#10b981' : '#f4f4f5'
                  }}>
                    ● {c.status.toUpperCase()}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
