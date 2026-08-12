import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { ScrollText, CheckCircle, Clock, Filter } from 'lucide-react';
import { api } from '../lib/api';

export default function AuditTrail() {
  const [selectedResourceType, setSelectedResourceType] = useState('stream');
  const [selectedResourceId, setSelectedResourceId] = useState('');

  // Fetch streams and pools to populate resource picker
  const { data: streams } = useQuery({
    queryKey: ['streams'],
    queryFn: () => api.get('/streams'),
  });

  const { data: pools } = useQuery({
    queryKey: ['pools'],
    queryFn: () => api.get('/pools'),
  });

  // Fetch audit events dynamically based on selected resource
  const { data: events, isLoading } = useQuery({
    queryKey: ['auditEvents', selectedResourceType, selectedResourceId],
    queryFn: () => {
      let queryPath = '/audit';
      const params = new URLSearchParams();
      if (selectedResourceType) params.append('resource_type', selectedResourceType);
      if (selectedResourceId) params.append('resource_id', selectedResourceId);
      if (params.toString()) queryPath += `?${params.toString()}`;
      return api.get(queryPath).catch(() => []);
    },
  });

  return (
    <div className="audit-trail-container" style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      <div>
        <h2 style={{ fontSize: '1.5rem', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <ScrollText style={{ color: 'var(--clr-primary)' }} /> Immutable Audit Trail
        </h2>
        <p style={{ color: 'var(--clr-text-muted)', marginTop: '0.25rem' }}>
          Chronological cryptographic event history for claims, webhooks, rating updates, and pool drawdowns.
        </p>
      </div>

      {/* Resource Picker Filter Bar */}
      <div className="glass-card" style={{ padding: '1.25rem', display: 'flex', gap: '1rem', alignItems: 'center', flexWrap: 'wrap' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--clr-text-muted)', fontSize: '0.9rem' }}>
          <Filter size={16} /> Filter Resource:
        </div>

        <select
          value={selectedResourceType}
          onChange={(e) => {
            setSelectedResourceType(e.target.value);
            setSelectedResourceId('');
          }}
          style={{ padding: '0.5rem 0.75rem', background: '#09090b', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '6px', color: '#fff', fontSize: '0.85rem' }}
        >
          <option value="">All Types</option>
          <option value="stream">Documentation Stream</option>
          <option value="pool">Funding Pool</option>
          <option value="claim">Reward Claim</option>
        </select>

        <select
          value={selectedResourceId}
          onChange={(e) => setSelectedResourceId(e.target.value)}
          style={{ padding: '0.5rem 0.75rem', background: '#09090b', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '6px', color: '#fff', fontSize: '0.85rem', flex: 1, minWidth: '240px' }}
        >
          <option value="">-- Select Specific Resource --</option>
          {selectedResourceType === 'stream' && streams?.map((s) => (
            <option key={s.id} value={s.id}>
              Stream: {s.file_path} ({s.id.substring(0, 8)}...)
            </option>
          ))}
          {selectedResourceType === 'pool' && pools?.map((p) => (
            <option key={p.id} value={p.id}>
              Pool: {p.repo_full_name} ({p.id.substring(0, 8)}...)
            </option>
          ))}
        </select>
      </div>

      {/* Audit Events Ledger */}
      <div className="glass-card" style={{ padding: '1.5rem' }}>
        {isLoading ? (
          <p>Loading audit ledger...</p>
        ) : !events || events.length === 0 ? (
          <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--clr-text-muted)' }}>
            <Clock size={32} style={{ margin: '0 auto 1rem', display: 'block', opacity: 0.5 }} />
            <p>No audit events recorded for current filter criteria.</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {events.map((ev) => (
              <div key={ev.id} style={{ display: 'flex', gap: '1rem', alignItems: 'flex-start', padding: '1rem', background: 'rgba(255,255,255,0.02)', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.05)' }}>
                <CheckCircle size={18} style={{ color: 'var(--clr-primary)', marginTop: '2px' }} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 600, fontSize: '0.95rem' }}>{ev.event_type}</div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--clr-text-muted)', marginTop: '0.25rem' }}>
                    Resource: {ev.resource_type} ({ev.resource_id})
                  </div>
                  {ev.payload && (
                    <pre style={{ fontSize: '0.75rem', color: 'var(--clr-text-muted)', marginTop: '0.5rem', background: 'rgba(0,0,0,0.3)', padding: '0.5rem', borderRadius: '4px', overflowX: 'auto' }}>
                      {JSON.stringify(ev.payload, null, 2)}
                    </pre>
                  )}
                </div>
                <span style={{ fontSize: '0.75rem', color: 'var(--clr-text-muted)' }}>
                  {new Date(ev.created_at).toLocaleString()}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
