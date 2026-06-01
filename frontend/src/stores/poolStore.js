import { create } from 'zustand';

export const usePoolStore = create((set) => ({
  searchQuery: '',
  setSearchQuery: (query) => set({ searchQuery: query }),
  selectedPoolId: null,
  setSelectedPoolId: (id) => set({ selectedPoolId: id }),
}));
