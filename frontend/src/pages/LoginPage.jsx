import React from 'react';
import { useAuthStore } from '../stores/authStore';
import { Droplets, ShieldAlert, Sparkles, Terminal } from 'lucide-react';

// Custom high-fidelity inline GitHub logo SVG
const GithubIcon = ({ size = 20, className }) => (
  <svg 
    viewBox="0 0 24 24" 
    width={size} 
    height={size} 
    stroke="currentColor" 
    strokeWidth="2" 
    fill="none" 
    strokeLinecap="round" 
    strokeLinejoin="round" 
    className={className}
  >
    <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" />
    <path d="M9 18c-4.51 2-5-2-7-2" />
  </svg>
);

export default function LoginPage() {
  const login = useAuthStore((state) => state.login);
  const error = useAuthStore((state) => state.error);
  const isLoading = useAuthStore((state) => state.isLoading);

  return (
    <div className="login-page-container">
      <div className="login-glow-bg"></div>
      
      <div className="glass-card login-card">
        <div className="login-header">
          <div className="logo-icon-wrapper animate-drip">
            <Droplets className="logo-icon" size={32} />
          </div>
          <h1 className="logo-text">Docu<span>Drip</span></h1>
          <p className="logo-tagline">Continuous Docs Micro-Funding Protocol</p>
        </div>

        <div className="login-intro">
          <p>
            Welcome to the documentation micro-funding hub. DocuDrip streams continuous reward drips in USDC directly to open-source contributors based on character diffs and reader helpfulness voting.
          </p>
        </div>

        {error && (
          <div className="login-error-box">
            <ShieldAlert size={18} className="error-icon" />
            <span>{error}</span>
          </div>
        )}

        <div className="login-actions">
          <button 
            onClick={login} 
            disabled={isLoading}
            className="action-btn-gradient login-btn"
          >
            <GithubIcon size={20} />
            <span>{isLoading ? 'Connecting...' : 'Sign in with GitHub'}</span>
          </button>
        </div>

        <div className="login-footer-terminal">
          <div className="t-header">
            <div className="t-dot"></div>
            <div className="t-dot"></div>
            <div className="t-dot"></div>
            <span className="t-title">drip-client-boot.sh</span>
          </div>
          <div className="t-body">
            <span className="t-cmd">&gt; docudrip --connect --network=simulated</span>
            <span className="t-success">Status: Ready. Awaiting OAuth handshake...</span>
          </div>
        </div>
      </div>
    </div>
  );
}
