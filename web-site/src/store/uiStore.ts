import { create } from 'zustand';

interface UiState {
  isSettingsOpen: boolean;
  setSettingsOpen: (isOpen: boolean) => void;
  isAboutOpen: boolean;
  setAboutOpen: (isOpen: boolean) => void;
  isSmartwatchOpen: boolean;
  setSmartwatchOpen: (isOpen: boolean) => void;
  isShareOpen: boolean;
  setShareOpen: (isOpen: boolean) => void;
}

export const useUiStore = create<UiState>((set) => ({
  isSettingsOpen: false,
  setSettingsOpen: (isOpen) => set({ isSettingsOpen: isOpen }),
  isAboutOpen: false,
  setAboutOpen: (isOpen) => set({ isAboutOpen: isOpen }),
  isSmartwatchOpen: false,
  setSmartwatchOpen: (isOpen) => set({ isSmartwatchOpen: isOpen }),
  isShareOpen: false,
  setShareOpen: (isOpen) => set({ isShareOpen: isOpen }),
}));
