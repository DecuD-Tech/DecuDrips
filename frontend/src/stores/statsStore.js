import { create } from 'zustand';

export const useStatsStore = create((set) => ({
  timeRange: '30d', // 24h, 7d, 30d, all
  total_pools_active: 0,
  total_funding_usdc: '0.00',
  total_dripped_usdc: '0.00',
  active_streams_count: 0,
  setTimeRange: (range) => set({ timeRange: range }),
  setStats: (stats) => set(stats),
}));
