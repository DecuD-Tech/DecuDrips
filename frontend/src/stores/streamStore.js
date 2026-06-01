import { create } from 'zustand';

export const useStreamStore = create((set) => ({
  filterLanguage: 'all',
  setFilterLanguage: (lang) => set({ filterLanguage: lang }),
  sortBy: 'accumulated', // accumulated, characterCount, rating
  setSortBy: (sort) => set({ sortBy: sort }),
}));
