import React, { useState } from 'react';
import { PlusCircle, Rocket, Database, FolderGit2 } from 'lucide-react';

export default function Dashboard({ pools, setPools }) {
  const [name, setName] = useState('');
  const [funding, setFunding] = useState(5000);
  const [rate, setRate] = useState(0.02);
  const [multEs, setMultEs] = useState(1.2);
  const [multZh, setMultZh] = useState(1.5);
  const [multDe, setMultDe] = useState(1.1);

  const createNewPool = (e) => {
    e.preventDefault();
    const newId = pools.length;
    setPools([
      ...pools,
      {
        id: newId,
        name,
        funding,
        rate,
        dripped: 0,
        mults: { es: multEs, zh: multZh, de: multDe }
      }
    ]);
    setName('');
    alert(`Reward Pool successfully initialized for ${name}!`);
  };

  return (
    <div id="view-dashboard" className="tab-view active">
      <div className="dashboard-grid">
        <div className="glass-card pool-creator">
          <div className="card-header">
            <h2 className="card-title">
              <PlusCircle className="title-icon" size={24} /> Initialize Doc Reward Pool
            </h2>
            <p className="card-subtitle">Deploy a new documentation pool to stream rewards for target files or languages.</p>
          </div>
          <form id="pool-form" onSubmit={createNewPool}>
            <div className="form-group">
              <label htmlFor="pool-name">Repository / Project Name</label>
              <input type="text" id="pool-name" placeholder="stellar/stellar-sdk-js" value={name} onChange={(e) => setName(e.target.value)} required />
            </div>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="pool-funding">Funding Amount (USDC)</label>
                <input type="number" id="pool-funding" value={funding} onChange={(e) => setFunding(parseFloat(e.target.value))} min="100" required />
              </div>
              <div className="form-group">
                <label htmlFor="pool-rate">Base Rate (USDC/Character)</label>
                <input type="number" id="pool-rate" value={rate} onChange={(e) => setRate(parseFloat(e.target.value))} step="0.005" min="0.001" required />
              </div>
            </div>
            <div className="form-group">
              <label>Locale Multipliers</label>
              <div className="multipliers-grid">
                <div className="multiplier-tag">
                  <span>ES (Spanish)</span>
                  <input type="number" value={multEs} onChange={(e) => setMultEs(parseFloat(e.target.value))} step="0.1" />x
                </div>
                <div className="multiplier-tag">
                  <span>ZH (Chinese)</span>
                  <input type="number" value={multZh} onChange={(e) => setMultZh(parseFloat(e.target.value))} step="0.1" />x
                </div>
                <div className="multiplier-tag">
                  <span>DE (German)</span>
                  <input type="number" value={multDe} onChange={(e) => setMultDe(parseFloat(e.target.value))} step="0.1" />x
                </div>
              </div>
            </div>
            <button type="submit" className="action-btn-gradient">
              <span>Deploy Smart Pool</span>
              <Rocket size={18} />
            </button>
          </form>
        </div>

        <div className="glass-card active-pools">
          <div className="card-header">
            <h2 className="card-title">
              <Database className="title-icon" size={24} /> Active Repo Pools
            </h2>
            <p className="card-subtitle">Smart contracts currently streaming funding for documentation.</p>
          </div>
          <div className="table-container">
            <table className="premium-table">
              <thead>
                <tr>
                  <th>Project Pool</th>
                  <th>Total Fund</th>
                  <th>Dripping Rate</th>
                  <th>Dripped</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {pools.map(pool => {
                  const locales = Object.keys(pool.mults).map(l => `${l.toUpperCase()}(${pool.mults[l]}x)`).join(', ');
                  return (
                    <tr key={pool.id}>
                      <td>
                        <div className="table-repo-name">
                          <FolderGit2 size={16} style={{ color: 'var(--clr-primary)' }} />
                          <span>{pool.name}</span>
                        </div>
                        <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Locales: {locales}</span>
                      </td>
                      <td style={{ fontWeight: 700 }}>
                        ${pool.funding.toLocaleString()} <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>USDC</span>
                      </td>
                      <td>{pool.rate} USDC/char</td>
                      <td style={{ color: 'var(--clr-primary)', fontFamily: 'var(--font-display)', fontWeight: 700 }}>
                        ${pool.dripped.toFixed(2)}
                      </td>
                      <td><span className="badge-status">Streaming</span></td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
