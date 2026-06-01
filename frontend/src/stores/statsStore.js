import { create } from 'zustand';

export const useStatsStore = create((set) => ({
  timeRange: '30d', // 24h, 7d, 30d, all
  setTimeRange: (range) => set({ timeRange: range }),
}));
