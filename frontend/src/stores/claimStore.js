import { create } from 'zustand';

export const useClaimStore = create((set) => ({
  selectedStreamId: null,
  setSelectedStreamId: (id) => set({ selectedStreamId: id }),
  claimAmount: '',
  setClaimAmount: (amount) => set({ claimAmount: amount }),
  selectedSettlementId: null,
  setSelectedSettlementId: (id) => set({ selectedSettlementId: id }),
  activeFilter: 'all', // 'all' | 'pending' | 'settled' | 'failed'
  setActiveFilter: (filter) => set({ activeFilter: filter }),
  resetForm: () => set({ selectedStreamId: null, claimAmount: '', selectedSettlementId: null }),
}));
