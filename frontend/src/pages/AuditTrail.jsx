import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { ScrollText, ShieldAlert, CheckCircle, Clock } from 'lucide-react';
import { api } from '../lib/api';

export default function AuditTrail() {
  const { data: events, isLoading } = useQuery({
    queryKey: ['auditEvents'],
    queryFn: () => api.get('/audit?resource_type=stream&resource_id=00000000-0000-0000-0000-000000000000').catch(() => []),
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

      <div className="glass-card" style={{ padding: '1.5rem' }}>
        {isLoading ? (
          <p>Loading audit ledger...</p>
        ) : events?.length === 0 ? (
          <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--clr-text-muted)' }}>
            <Clock size={32} style={{ margin: '0 auto 1rem', display: 'block', opacity: 0.5 }} />
            <p>No audit events recorded for current filter criteria.</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {events?.map((ev) => (
              <div key={ev.id} style={{ display: 'flex', gap: '1rem', alignItems: 'flex-start', padding: '1rem', background: 'rgba(255,255,255,0.02)', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.05)' }}>
                <CheckCircle size={18} style={{ color: 'var(--clr-primary)', marginTop: '2px' }} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 600, fontSize: '0.95rem' }}>{ev.event_type}</div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--clr-text-muted)', marginTop: '0.25rem' }}>
                    Resource: {ev.resource_type} ({ev.resource_id})
                  </div>
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
