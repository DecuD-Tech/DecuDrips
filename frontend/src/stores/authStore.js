import { create } from 'zustand';
import { api } from '../lib/api';

export const useAuthStore = create((set, get) => ({
  user: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,

  loadUser: async () => {
    const token = localStorage.getItem('docudrip_token');
    if (!token) {
      set({ user: null, isAuthenticated: false, isLoading: false });
      return;
    }

    set({ isLoading: true, error: null });
    try {
      const user = await api.get('/users/me');
      set({ user, isAuthenticated: true, isLoading: false });
    } catch (err) {
      console.error('Failed to load user:', err);
      localStorage.removeItem('docudrip_token');
      set({ user: null, isAuthenticated: false, isLoading: false, error: err.message });
    }
  },

  setToken: (token) => {
    localStorage.setItem('docudrip_token', token);
    get().loadUser();
  },

  login: () => {
    const backendUrl = import.meta.env.VITE_API_URL || 'http://localhost:8080/api/v1';
    window.location.href = `${backendUrl}/auth/github`;
  },

  logout: () => {
    localStorage.removeItem('docudrip_token');
    set({ user: null, isAuthenticated: false, error: null });
    window.location.href = '/login';
  },
}));
