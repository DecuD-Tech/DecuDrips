import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Building2, CreditCard, ShieldCheck, Plus, Trash2 } from 'lucide-react';
import { api } from '../lib/api';

export default function SettlementSetup() {
  const queryClient = useQueryClient();
  const [provider, setProvider] = useState('usdc_base');
  const [providerRef, setProviderRef] = useState('');
  const [error, setError] = useState(null);

  const { data: accounts, isLoading } = useQuery({
    queryKey: ['settlementAccounts'],
    queryFn: () => api.get('/settlement-accounts'),
  });

  const createMutation = useMutation({
    mutationFn: (newAcc) => api.post('/settlement-accounts', newAcc),
    onSuccess: () => {
      queryClient.invalidateQueries(['settlementAccounts']);
      setProviderRef('');
      setError(null);
    },
    onError: (err) => setError(err.message || 'Failed to add settlement destination'),
  });

  const deleteMutation = useMutation({
    mutationFn: (id) => api.delete(`/settlement-accounts/${id}`),
    onSuccess: () => queryClient.invalidateQueries(['settlementAccounts']),
  });

  const handleAdd = (e) => {
    e.preventDefault();
    if (!providerRef) {
      setError('Please enter account ID or wallet address');
      return;
    }
    createMutation.mutate({ provider, provider_ref: providerRef });
  };

  return (
    <div className="settlement-setup-container" style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      <div>
        <h2 style={{ fontSize: '1.5rem', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Building2 style={{ color: 'var(--clr-primary)' }} /> Settlement Destinations
        </h2>
        <p style={{ color: 'var(--clr-text-muted)', marginTop: '0.25rem' }}>
          Configure verified payout accounts (Stripe Connect, Base USDC, OpenCollective).
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
        {/* Form */}
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ marginBottom: '1rem', fontSize: '1.1rem' }}>Register New Payout Destination</h3>
          {error && <div style={{ color: 'var(--clr-accent-pink)', marginBottom: '1rem' }}>{error}</div>}

          <form onSubmit={handleAdd} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div>
              <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Payout Provider</label>
              <select
                value={provider}
                onChange={(e) => setProvider(e.target.value)}
                style={{ width: '100%', padding: '0.75rem', background: '#09090b', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '6px', color: '#fff' }}
              >
                <option value="usdc_base">USDC (Base / Polygon L2 EVM Wallet)</option>
                <option value="stripe">Stripe Connect Custom Account</option>
                <option value="opencollective">OpenCollective Grant API</option>
                <option value="lightning">Lightning Network (LNURL / LN-Address)</option>
              </select>
            </div>

            <div>
              <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Provider Reference / Wallet Address</label>
              <input
                type="text"
                placeholder={provider === 'usdc_base' ? '0x1234...5678' : 'acct_stripe123'}
                value={providerRef}
                onChange={(e) => setProviderRef(e.target.value)}
                style={{ width: '100%', padding: '0.75rem', background: '#09090b', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '6px', color: '#fff' }}
              />
            </div>

            <button
              type="submit"
              disabled={createMutation.isPending}
              style={{ padding: '0.75rem', background: 'var(--clr-primary)', color: '#000', fontWeight: 600, border: 'none', borderRadius: '6px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}
            >
              <Plus size={16} /> Register Destination
            </button>
          </form>
        </div>

        {/* Existing Accounts List */}
        <div className="glass-card" style={{ padding: '1.5rem' }}>
          <h3 style={{ marginBottom: '1rem', fontSize: '1.1rem' }}>Active Accounts</h3>
          {isLoading ? (
            <p>Loading accounts...</p>
          ) : accounts?.length === 0 ? (
            <p style={{ color: 'var(--clr-text-muted)' }}>No settlement destinations configured.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {accounts?.map((acc) => (
                <div key={acc.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0.75rem', background: 'rgba(255,255,255,0.03)', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.06)' }}>
                  <div>
                    <div style={{ fontWeight: 600, textTransform: 'uppercase', fontSize: '0.85rem', color: 'var(--clr-primary)', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                      <ShieldCheck size={14} /> {acc.provider}
                    </div>
                    <div style={{ fontSize: '0.85rem', color: '#fff', marginTop: '0.25rem' }}>{acc.provider_ref}</div>
                  </div>
                  <button onClick={() => deleteMutation.mutate(acc.id)} style={{ background: 'none', border: 'none', color: 'var(--clr-accent-pink)', cursor: 'pointer' }}>
                    <Trash2 size={16} />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
