import React, { useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useNavigate, useSearchParams } from 'react-router-dom';
import { QueryClient, QueryClientProvider, useQuery } from '@tanstack/react-query';
import { Droplets, LayoutDashboard, Activity, Terminal, Database, Zap, HeartHandshake, ThumbsUp, LogOut, User, Wallet, Building2, ScrollText } from 'lucide-react';
import { useAuthStore } from './stores/authStore';
import { api } from './lib/api';

import Dashboard from './components/Dashboard';
import Streams from './components/Streams';
import Sandbox from './components/Sandbox';
import LoginPage from './pages/LoginPage';
import ClaimPage from './pages/ClaimPage';
import SettlementSetup from './pages/SettlementSetup';
import AuditTrail from './pages/AuditTrail';

import './index.css';

// Initialize the React Query Client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

// Authentication Guard Component
function RequireAuth({ children }) {
  const { isAuthenticated, isLoading, loadUser } = useAuthStore();

  useEffect(() => {
    loadUser();
  }, [loadUser]);

  if (isLoading) {
    return (
      <div className="login-page-container">
        <div className="login-glow-bg"></div>
        <div className="glass-card login-card" style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <h2 className="logo-text">Booting Session...</h2>
          <div className="pulse-dot" style={{ margin: '2rem auto' }}></div>
          <p className="logo-tagline">Validating credentials & state ledger</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return children;
}

// GitHub OAuth Callback Route Handler
function AuthCallback() {
  const setToken = useAuthStore((state) => state.setToken);
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();

  useEffect(() => {
    const token = searchParams.get('token');
    if (token) {
      setToken(token);
      navigate('/');
    } else {
      navigate('/login');
    }
  }, [searchParams, setToken, navigate]);

  return (
    <div className="login-page-container">
      <div className="login-glow-bg"></div>
      <div className="glass-card login-card" style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <h2 className="logo-text">Authenticating...</h2>
        <div className="pulse-dot" style={{ margin: '2rem auto' }}></div>
        <p className="logo-tagline">Establishing secure cryptographic session</p>
      </div>
    </div>
  );
}

// Main Authenticated Dashboard Shell Component
function DashboardShell() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const { user, logout } = useAuthStore();

  // Query global system stats
  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: ['globalStats'],
    queryFn: () => api.get('/stats'),
    refetchInterval: 5000, // Poll every 5 seconds for a dynamic feel
  });

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
            <LayoutDashboard size={18} strokeWidth={1.5} style={{ marginRight: '8px' }} /> Dashboard
          </button>
          <button className={`nav-btn ${activeTab === 'streams' ? 'active' : ''}`} onClick={() => setActiveTab('streams')}>
            <Activity size={18} strokeWidth={1.5} style={{ marginRight: '8px' }} /> Active Streams
          </button>
          <button className={`nav-btn ${activeTab === 'claims' ? 'active' : ''}`} onClick={() => setActiveTab('claims')}>
            <Wallet size={18} strokeWidth={1.5} style={{ marginRight: '8px' }} /> Claims & Payouts
          </button>
          <button className={`nav-btn ${activeTab === 'settlement' ? 'active' : ''}`} onClick={() => setActiveTab('settlement')}>
            <Building2 size={18} strokeWidth={1.5} style={{ marginRight: '8px' }} /> Destinations
          </button>
          <button className={`nav-btn ${activeTab === 'audit' ? 'active' : ''}`} onClick={() => setActiveTab('audit')}>
            <ScrollText size={18} strokeWidth={1.5} style={{ marginRight: '8px' }} /> Audit Ledger
          </button>
          <button className={`nav-btn ${activeTab === 'sandbox' ? 'active' : ''}`} onClick={() => setActiveTab('sandbox')}>
            <Terminal size={18} strokeWidth={1.5} style={{ marginRight: '8px' }} /> Integration Sandbox
          </button>
        </nav>

        <div className="header-wallet">
          <div className="wallet-badge">
            <span className="wallet-status"></span>
            <span className="wallet-address" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <User size={14} style={{ color: 'var(--clr-primary)' }} />
              @{user?.username || 'user'} ({user?.role || 'contributor'})
            </span>
            <button onClick={logout} className="logout-inline-btn" title="Sign Out">
              <LogOut size={14} />
            </button>
          </div>
        </div>
      </header>

      <main className="app-container">
        <section className="stats-panel">
          <div className="stat-card">
            <div className="stat-icon pink"><Database size={20} strokeWidth={1.5} /></div>
            <div className="stat-info">
              <span className="stat-label">Total Reward Pools</span>
              <span className="stat-value">
                ${statsLoading ? '...' : (stats?.total_pools_funding || 0).toLocaleString()} <span className="currency">USDC</span>
              </span>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon cyan"><Zap size={20} strokeWidth={1.5} /></div>
            <div className="stat-info">
              <span className="stat-label">Total Dripped</span>
              <span className="stat-value">
                ${statsLoading ? '...' : (parseFloat(stats?.total_dripped || '0')).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })} <span className="currency">USDC</span>
              </span>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-info">
              <span className="stat-label">Active Drip Streams</span>
              <span className="stat-value">{statsLoading ? '...' : stats?.active_streams_count || 0} Streams</span>
            </div>
            <div className="stat-icon green"><HeartHandshake size={20} strokeWidth={1.5} /></div>
          </div>
          <div className="stat-card">
            <div className="stat-info">
              <span className="stat-label">Avg Helpfulness</span>
              <span className="stat-value">{statsLoading ? '...' : `${(stats?.average_helpfulness_rating || 0).toFixed(1)}%`}</span>
            </div>
            <div className="stat-icon purple"><ThumbsUp size={20} strokeWidth={1.5} /></div>
          </div>
        </section>

        {activeTab === 'dashboard' && <Dashboard />}
        {activeTab === 'streams' && <Streams />}
        {activeTab === 'claims' && <ClaimPage />}
        {activeTab === 'settlement' && <SettlementSetup />}
        {activeTab === 'audit' && <AuditTrail />}
        {activeTab === 'sandbox' && <Sandbox />}
      </main>

      <footer className="app-footer">
        <p>&copy; 2026 DocuDrip Protocol. Designed for highly resilient open-source documentation ecosystems. Running on Rust Axum and PostgreSQL.</p>
      </footer>
    </>
  );
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/auth/callback" element={<AuthCallback />} />
          <Route 
            path="/*" 
            element={
              <RequireAuth>
                <DashboardShell />
              </RequireAuth>
            } 
          />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}
