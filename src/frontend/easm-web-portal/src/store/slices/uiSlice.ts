import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface UiState {
  sidebarOpen: boolean;
  selectedAssets: string[];
  selectedIssues: string[];
  activeModal: string | null;
  notifications: Notification[];
  theme: 'light' | 'dark';
  viewMode: 'grid' | 'list' | 'map';
}

export interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  timestamp: number;
}

const initialState: UiState = {
  sidebarOpen: true,
  selectedAssets: [],
  selectedIssues: [],
  activeModal: null,
  notifications: [],
  theme: 'light',
  viewMode: 'grid',
};

const uiSlice = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    toggleSidebar: (state) => {
      state.sidebarOpen = !state.sidebarOpen;
    },
    setSidebarOpen: (state, action: PayloadAction<boolean>) => {
      state.sidebarOpen = action.payload;
    },
    setSelectedAssets: (state, action: PayloadAction<string[]>) => {
      state.selectedAssets = action.payload;
    },
    toggleAssetSelection: (state, action: PayloadAction<string>) => {
      const index = state.selectedAssets.indexOf(action.payload);
      if (index > -1) {
        state.selectedAssets.splice(index, 1);
      } else {
        state.selectedAssets.push(action.payload);
      }
    },
    setSelectedIssues: (state, action: PayloadAction<string[]>) => {
      state.selectedIssues = action.payload;
    },
    toggleIssueSelection: (state, action: PayloadAction<string>) => {
      const index = state.selectedIssues.indexOf(action.payload);
      if (index > -1) {
        state.selectedIssues.splice(index, 1);
      } else {
        state.selectedIssues.push(action.payload);
      }
    },
    openModal: (state, action: PayloadAction<string>) => {
      state.activeModal = action.payload;
    },
    closeModal: (state) => {
      state.activeModal = null;
    },
    addNotification: (state, action: PayloadAction<Omit<Notification, 'id' | 'timestamp'>>) => {
      state.notifications.push({
        ...action.payload,
        id: Date.now().toString(),
        timestamp: Date.now(),
      });
    },
    removeNotification: (state, action: PayloadAction<string>) => {
      state.notifications = state.notifications.filter((n) => n.id !== action.payload);
    },
    clearNotifications: (state) => {
      state.notifications = [];
    },
    setTheme: (state, action: PayloadAction<'light' | 'dark'>) => {
      state.theme = action.payload;
    },
    setViewMode: (state, action: PayloadAction<'grid' | 'list' | 'map'>) => {
      state.viewMode = action.payload;
    },
  },
});

export const {
  toggleSidebar,
  setSidebarOpen,
  setSelectedAssets,
  toggleAssetSelection,
  setSelectedIssues,
  toggleIssueSelection,
  openModal,
  closeModal,
  addNotification,
  removeNotification,
  clearNotifications,
  setTheme,
  setViewMode,
} = uiSlice.actions;

export default uiSlice.reducer;
