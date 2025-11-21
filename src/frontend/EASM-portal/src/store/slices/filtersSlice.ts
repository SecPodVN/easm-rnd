import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface DateRange {
  start: Date;
  end: Date;
}

export interface FiltersState {
  dateRange: DateRange;
  severity: string[];
  assetTypes: string[];
  issueStatus: string[];
  searchQuery: string;
  sortBy: string;
  sortOrder: 'asc' | 'desc';
}

const initialState: FiltersState = {
  dateRange: {
    start: new Date(new Date().setDate(new Date().getDate() - 30)),
    end: new Date(),
  },
  severity: [],
  assetTypes: [],
  issueStatus: [],
  searchQuery: '',
  sortBy: 'createdAt',
  sortOrder: 'desc',
};

const filtersSlice = createSlice({
  name: 'filters',
  initialState,
  reducers: {
    setDateRange: (state, action: PayloadAction<DateRange>) => {
      state.dateRange = action.payload;
    },
    setSeverity: (state, action: PayloadAction<string[]>) => {
      state.severity = action.payload;
    },
    setAssetTypes: (state, action: PayloadAction<string[]>) => {
      state.assetTypes = action.payload;
    },
    setIssueStatus: (state, action: PayloadAction<string[]>) => {
      state.issueStatus = action.payload;
    },
    setSearchQuery: (state, action: PayloadAction<string>) => {
      state.searchQuery = action.payload;
    },
    setSortBy: (state, action: PayloadAction<string>) => {
      state.sortBy = action.payload;
    },
    setSortOrder: (state, action: PayloadAction<'asc' | 'desc'>) => {
      state.sortOrder = action.payload;
    },
    resetFilters: () => initialState,
  },
});

export const {
  setDateRange,
  setSeverity,
  setAssetTypes,
  setIssueStatus,
  setSearchQuery,
  setSortBy,
  setSortOrder,
  resetFilters,
} = filtersSlice.actions;

export default filtersSlice.reducer;
