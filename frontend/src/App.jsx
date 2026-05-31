import React, { useState, useEffect } from 'react';
import { Droplets, LayoutDashboard, Activity, Terminal, Database, Zap, HeartHandshake, ThumbsUp } from 'lucide-react';
import Dashboard from './components/Dashboard';
import Streams from './components/Streams';
import Sandbox from './components/Sandbox';
import './index.css';

// Initial Mock State
const initialPools = [
  { id: 0, name: 'stellar/stellar-sdk-js', funding: 15000, rate: 0.02, dripped: 2450.12, mults: { es: 1.2, zh: 1.5, de: 1.1 } },
  { id: 1, name: 'stellar/soroban-react', funding: 25000, rate: 0.03, dripped: 4890.30, mults: { es: 1.2, zh: 1.6, de: 1.1 } },
  { id: 2, name: 'radicle/drips-sdk', funding: 10000, rate: 0.015, dripped: 820.40, mults: { es: 1.2, zh: 1.4, de: 1.1 } }
];

const initialStreams = [
  { id: 'stream-1', author: 'marissa_dev', poolId: 0, file: 'README.md', characters: 850, locale: 'en', accumulated: 18.42901, upvotes: 18, totalVotes: 19 },
  { id: 'stream-2', author: 'alejandro_tech', poolId: 0, file: 'getting_started.es.md', characters: 1540, locale: 'es', accumulated: 42.15830, upvotes: 24, totalVotes: 24 },
  { id: 'stream-3', author: 'li_wei', poolId: 1, file: 'smart_contracts.zh.md', characters: 2100, locale: 'zh', accumulated: 95.84920, upvotes: 31, totalVotes: 33 }
];

// Helper functions
export const calculateRating = (stream) => {
  if (stream.totalVotes === 0) return 100;
  return Math.round((stream.upvotes / stream.totalVotes) * 100);
};

export const calculateFeedbackMultiplier = (stream) => {
  const rating = calculateRating(stream);
  if (rating >= 95) return 1.5;
  if (rating >= 90) return 1.2;
  if (rating >= 75) return 1.0;
  if (rating >= 60) return 0.8;
  return 0.5;
};

export const getStreamRatePerSecond = (stream, pools) => {
  const pool = pools.find(p => p.id === parseInt(stream.poolId));
  if (!pool) return 0;
  
  const baseRate = stream.characters * pool.rate;
  const localeMult = (stream.locale !== 'en' && pool.mults[stream.locale]) ? pool.mults[stream.locale] : 1.0;
  const feedbackMult = calculateFeedbackMultiplier(stream);
  const demoBoost = 50; 
  return (baseRate * localeMult * feedbackMult * demoBoost) / 86400;
};

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [pools, setPools] = useState(initialPools);
  const [streams, setStreams] = useState(initialStreams);
  const [totalDrippedGlobal, setTotalDrippedGlobal] = useState(8160.82);

  useEffect(() => {
    const timer = setInterval(() => {
      setStreams(currentStreams => {
        let totalDrippedThisTick = 0;
        const newStreams = currentStreams.map(stream => {
          const rate = getStreamRatePerSecond(stream, pools);
          const increment = rate * 0.1;
          totalDrippedThisTick += increment;
          return { ...stream, accumulated: stream.accumulated + increment };
        });

        if (totalDrippedThisTick > 0) {
          setTotalDrippedGlobal(prev => prev + totalDrippedThisTick);
          setPools(currentPools => {
            const poolsCopy = [...currentPools];
            currentStreams.forEach(stream => {
              const poolIndex = poolsCopy.findIndex(p => p.id === parseInt(stream.poolId));
              if (poolIndex !== -1) {
                const rate = getStreamRatePerSecond(stream, poolsCopy);
                poolsCopy[poolIndex] = {
                  ...poolsCopy[poolIndex],
                  dripped: poolsCopy[poolIndex].dripped + (rate * 0.1)
                };
              }
            });
            return poolsCopy;
          });
        }
        return newStreams;
      });
    }, 100);
    return () => clearInterval(timer);
  }, [pools]);

  const totalPoolsFund = pools.reduce((acc, p) => acc + p.funding, 0);

  return (
    <>
      <header className="app-header">
        <div className="logo-container">
          <div className="logo-icon-wrapper">
            <Droplets className="logo-icon animate-drip" />
          </div>
          <div>
            <h1 className="logo-text">Docu<span>Drip</span></h1>
            <p className="logo-tagline">Continuous Docs Micro-Funding</p>
          </div>
        </div>

        <nav className="app-nav">
          <button className={`nav-btn ${activeTab === 'dashboard' ? 'active' : ''}`} onClick={() => setActiveTab('dashboard')}>
            <LayoutDashboard size={18} strokeWidth={1.5} style={{marginRight: '8px'}} /> Dashboard
          </button>
          <button className={`nav-btn ${activeTab === 'streams' ? 'active' : ''}`} onClick={() => setActiveTab('streams')}>
            <Activity size={18} strokeWidth={1.5} style={{marginRight: '8px'}} /> Active Streams
          </button>
          <button className={`nav-btn ${activeTab === 'sandbox' ? 'active' : ''}`} onClick={() => setActiveTab('sandbox')}>
            <Terminal size={18} strokeWidth={1.5} style={{marginRight: '8px'}} /> Integration Sandbox
          </button>
        </nav>

        <div className="header-wallet">
          <div className="wallet-badge">
            <span className="wallet-status"></span>
            <span className="wallet-address">Simulated Wallet (0xDRIP...77c)</span>
          </div>
        </div>
      </header>

      <main className="app-container">
        <section className="stats-panel">
          <div className="stat-card">
            <div className="stat-icon pink"><Database size={20} strokeWidth={1.5} /></div>
            <div className="stat-info">
              <span className="stat-label">Total Reward Pools</span>
              <span className="stat-value">${totalPoolsFund.toLocaleString()} <span className="currency">USDC</span></span>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon cyan"><Zap size={20} strokeWidth={1.5} /></div>
            <div className="stat-info">
              <span className="stat-label">Total Dripped</span>
              <span className="stat-value">{totalDrippedGlobal.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})} <span className="currency">USDC</span></span>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-info">
              <span className="stat-label">Active Drip Streams</span>
              <span className="stat-value">{streams.length} Streams</span>
            </div>
            <div className="stat-icon green"><HeartHandshake size={20} strokeWidth={1.5} /></div>
          </div>
          <div className="stat-card">
            <div className="stat-info">
              <span className="stat-label">Avg Helpfulness</span>
              <span className="stat-value">94.8%</span>
            </div>
            <div className="stat-icon purple"><ThumbsUp size={20} strokeWidth={1.5} /></div>
          </div>
        </section>

        {activeTab === 'dashboard' && <Dashboard pools={pools} setPools={setPools} />}
        {activeTab === 'streams' && <Streams streams={streams} pools={pools} />}
        {activeTab === 'sandbox' && <Sandbox streams={streams} setStreams={setStreams} pools={pools} />}
      </main>

      <footer className="app-footer">
        <p>&copy; 2026 DocuDrip Protocol. Designed for highly resilient open-source ecosystems. All smart contracts are simulated on-client.</p>
      </footer>
    </>
  );
}
