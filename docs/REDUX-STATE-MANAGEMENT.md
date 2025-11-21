# 🏪 Redux Toolkit State Management Guide

**EASM-RND Frontend State Management Implementation**

This document provides comprehensive guidance for implementing and using Redux Toolkit with RTK Query in the EASM-RND platform.

---

## 📚 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Store Structure](#store-structure)
4. [State Slices](#state-slices)
5. [RTK Query API](#rtk-query-api)
6. [Usage Examples](#usage-examples)
7. [Migration Guide](#migration-guide)
8. [Best Practices](#best-practices)
9. [Backend Integration](#backend-integration)

---

## Overview

### Why Redux Toolkit?

Redux Toolkit (RTK) was chosen for the EASM-RND platform to handle state management at scale. With 100K+ assets and real-time scanning operations, we need:

- **Centralized State Management**: Single source of truth for application state
- **Scalability**: Handle large datasets efficiently with normalized state
- **Server State Management**: RTK Query provides caching, invalidation, and automatic refetching
- **Developer Experience**: Built-in DevTools, time-travel debugging, and predictable state updates
- **Type Safety**: Full TypeScript support with automatic type inference
- **Performance**: Selective re-renders and memoization out of the box

### What's Included

```
src/store/
├── index.ts                 # Store configuration
├── slices/
│   ├── filtersSlice.ts     # Global filter state (date range, severity, etc.)
│   └── uiSlice.ts          # UI state (sidebar, modals, selections, etc.)
└── services/
    └── api.ts              # RTK Query API endpoints
```

---

## Architecture

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         Components                           │
│  (dispatch actions, select state, use RTK Query hooks)      │
└───────────────┬────────────────────────┬────────────────────┘
                │                        │
                ▼                        ▼
       ┌────────────────┐      ┌──────────────────┐
       │  Redux Store   │      │   RTK Query      │
       │   (Slices)     │      │  (API Cache)     │
       └────────────────┘      └──────────────────┘
                │                        │
                │                        ▼
                │              ┌──────────────────┐
                │              │  Backend API     │
                │              │ (Django REST)    │
                └──────────────┴──────────────────┘
```

### Key Concepts

1. **Slices**: Feature-based state containers (filters, ui)
2. **RTK Query**: API layer with automatic caching and invalidation
3. **Typed Hooks**: Pre-typed `useAppSelector` and `useAppDispatch`
4. **Mock Data**: Development mode with mock responses (switch to real API when ready)

---

## Store Structure

### Store Configuration (`src/store/index.ts`)

```typescript
import { configureStore } from '@reduxjs/toolkit';
import filtersReducer from './slices/filtersSlice';
import uiReducer from './slices/uiSlice';
import { easmApi } from './services/api';

export const store = configureStore({
  reducer: {
    filters: filtersReducer,
    ui: uiReducer,
    [easmApi.reducerPath]: easmApi.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(easmApi.middleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// Pre-typed hooks
export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

### Provider Setup (`src/App.tsx`)

```typescript
import { Provider } from 'react-redux';
import { store } from './store';

function App() {
  return (
    <Provider store={store}>
      {/* Your app components */}
    </Provider>
  );
}
```

---

## State Slices

### Filters Slice (`src/store/slices/filtersSlice.ts`)

Manages global filter state used across the platform.

**State Structure:**
```typescript
interface FiltersState {
  dateRange: { start: Date; end: Date };
  severity: string[];
  assetTypes: string[];
  issueStatus: string[];
  searchQuery: string;
  sortBy: string;
  sortOrder: 'asc' | 'desc';
}
```

**Actions:**
- `setDateRange(dateRange)` - Update date filter
- `setSeverity(severity[])` - Filter by severity levels
- `setAssetTypes(types[])` - Filter by asset types
- `setIssueStatus(status[])` - Filter by issue status
- `setSearchQuery(query)` - Set search text
- `setSortBy(field)` - Set sort field
- `setSortOrder(order)` - Set sort direction
- `resetFilters()` - Reset to default state

**Usage Example:**
```typescript
import { useAppDispatch, useAppSelector } from '../../store';
import { setDateRange, setSeverity } from '../../store/slices/filtersSlice';

function FilterComponent() {
  const dispatch = useAppDispatch();
  const { dateRange, severity } = useAppSelector((state) => state.filters);

  const handleDateChange = (start: Date, end: Date) => {
    dispatch(setDateRange({ start, end }));
  };

  return (
    <div>
      <DatePicker value={dateRange} onChange={handleDateChange} />
    </div>
  );
}
```

### UI Slice (`src/store/slices/uiSlice.ts`)

Manages UI-specific state like modals, selections, and preferences.

**State Structure:**
```typescript
interface UiState {
  sidebarOpen: boolean;
  selectedAssets: string[];
  selectedIssues: string[];
  activeModal: string | null;
  notifications: Notification[];
  theme: 'light' | 'dark';
  viewMode: 'grid' | 'list' | 'map';
}
```

**Key Actions:**
- `toggleSidebar()` - Toggle sidebar open/close
- `setSelectedAssets(ids[])` - Set selected assets
- `toggleAssetSelection(id)` - Toggle single asset selection
- `openModal(modalName)` - Open a modal
- `closeModal()` - Close active modal
- `addNotification(notification)` - Show notification
- `setViewMode(mode)` - Change view mode

**Usage Example:**
```typescript
import { useAppDispatch, useAppSelector } from '../../store';
import { toggleAssetSelection, openModal } from '../../store/slices/uiSlice';

function AssetList() {
  const dispatch = useAppDispatch();
  const selectedAssets = useAppSelector((state) => state.ui.selectedAssets);

  const handleAssetClick = (assetId: string) => {
    dispatch(toggleAssetSelection(assetId));
  };

  const handleBulkAction = () => {
    dispatch(openModal('bulk-action-modal'));
  };

  return (
    <div>
      {selectedAssets.length > 0 && (
        <Button onClick={handleBulkAction}>
          Actions ({selectedAssets.length})
        </Button>
      )}
    </div>
  );
}
```

---

## RTK Query API

### API Definition (`src/store/services/api.ts`)

RTK Query provides automatic caching, loading states, and error handling.

**Endpoints:**

#### Assets
- `useGetAssetsQuery({ dateRange?, types?, search? })` - Get all assets
- `useGetAssetByIdQuery(id)` - Get single asset

#### Issues
- `useGetIssuesQuery({ severity?, status?, search? })` - Get all issues
- `useGetIssueByIdQuery(id)` - Get single issue

#### Dashboard
- `useGetDashboardMetricsQuery({ dateRange? })` - Get dashboard metrics

#### Scans
- `useGetScansQuery()` - Get all scans
- `useStartScanMutation()` - Start new scan

### Usage Example

```typescript
import { useGetDashboardMetricsQuery, useGetAssetsQuery } from '../../store/services/api';
import { useAppSelector } from '../../store';

function Dashboard() {
  const dateRange = useAppSelector((state) => state.filters.dateRange);

  // Automatic loading, error handling, and caching
  const { data: metrics, isLoading, error } = useGetDashboardMetricsQuery({ dateRange });
  const { data: assets } = useGetAssetsQuery({ dateRange });

  if (isLoading) return <CircularProgress />;
  if (error) return <Alert severity="error">Failed to load data</Alert>;

  return (
    <div>
      <Typography>Total Assets: {metrics?.totalAssets}</Typography>
      <Typography>Security Score: {metrics?.securityScore}</Typography>
    </div>
  );
}
```

### RTK Query Features

**Automatic Caching**
```typescript
// First call - fetches from server
const { data } = useGetAssetsQuery();

// Second call with same params - returns cached data
const { data: cachedData } = useGetAssetsQuery();
```

**Manual Refetching**
```typescript
const { data, refetch } = useGetAssetsQuery();

<Button onClick={() => refetch()}>Refresh</Button>
```

**Polling**
```typescript
// Auto-refresh every 30 seconds
const { data } = useGetAssetsQuery({}, {
  pollingInterval: 30000,
});
```

**Conditional Fetching**
```typescript
// Only fetch if assetId exists
const { data } = useGetAssetByIdQuery(assetId, {
  skip: !assetId,
});
```

**Mutations**
```typescript
const [startScan, { isLoading, error }] = useStartScanMutation();

const handleStartScan = async () => {
  try {
    const result = await startScan({
      name: 'Security Scan',
      type: 'full',
    }).unwrap();
    console.log('Scan started:', result);
  } catch (err) {
    console.error('Failed to start scan:', err);
  }
};
```

---

## Usage Examples

### Example 1: Filter State Management

**Before Redux (local state):**
```typescript
function Overview() {
  const [dateRange, setDateRange] = useState(30);
  const [severity, setSeverity] = useState<string[]>([]);

  // Props drilling to children
  return (
    <div>
      <FilterBar
        dateRange={dateRange}
        onDateChange={setDateRange}
        severity={severity}
        onSeverityChange={setSeverity}
      />
      <IssueList dateRange={dateRange} severity={severity} />
    </div>
  );
}
```

**After Redux (centralized state):**
```typescript
function Overview() {
  // No local state needed - filters are in Redux
  return (
    <div>
      <FilterBar />
      <IssueList />
    </div>
  );
}

function FilterBar() {
  const dispatch = useAppDispatch();
  const { dateRange, severity } = useAppSelector((state) => state.filters);

  return (
    <div>
      <DateRangePicker
        value={dateRange}
        onChange={(range) => dispatch(setDateRange(range))}
      />
      <SeverityFilter
        value={severity}
        onChange={(sev) => dispatch(setSeverity(sev))}
      />
    </div>
  );
}

function IssueList() {
  // Automatically gets filters from Redux
  const { dateRange, severity } = useAppSelector((state) => state.filters);
  const { data: issues } = useGetIssuesQuery({ severity });

  return (
    <List>
      {issues?.map(issue => <IssueCard key={issue.id} issue={issue} />)}
    </List>
  );
}
```

### Example 2: Dashboard with RTK Query

```typescript
import { useAppSelector } from '../../store';
import { useGetDashboardMetricsQuery } from '../../store/services/api';

function Dashboard() {
  const dateRange = useAppSelector((state) => state.filters.dateRange);

  const {
    data: metrics,
    isLoading,
    error,
    refetch
  } = useGetDashboardMetricsQuery({ dateRange });

  if (isLoading) {
    return <CircularProgress />;
  }

  if (error) {
    return (
      <Alert severity="error">
        Failed to load metrics
        <Button onClick={() => refetch()}>Retry</Button>
      </Alert>
    );
  }

  return (
    <Box>
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6">Total Assets</Typography>
              <Typography variant="h3">{metrics?.totalAssets}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6">Security Score</Typography>
              <Typography variant="h3">{metrics?.securityScore}</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
```

### Example 3: Asset Selection

```typescript
import { useAppDispatch, useAppSelector } from '../../store';
import { toggleAssetSelection, openModal } from '../../store/slices/uiSlice';

function AssetTable() {
  const dispatch = useAppDispatch();
  const selectedAssets = useAppSelector((state) => state.ui.selectedAssets);
  const { data: assets } = useGetAssetsQuery();

  const handleSelectAsset = (assetId: string) => {
    dispatch(toggleAssetSelection(assetId));
  };

  const handleBulkDelete = () => {
    dispatch(openModal('confirm-delete'));
  };

  return (
    <div>
      {selectedAssets.length > 0 && (
        <Toolbar>
          <Typography>{selectedAssets.length} selected</Typography>
          <Button onClick={handleBulkDelete}>Delete</Button>
        </Toolbar>
      )}
      <Table>
        {assets?.map(asset => (
          <TableRow key={asset.id}>
            <TableCell>
              <Checkbox
                checked={selectedAssets.includes(asset.id)}
                onChange={() => handleSelectAsset(asset.id)}
              />
            </TableCell>
            <TableCell>{asset.name}</TableCell>
          </TableRow>
        ))}
      </Table>
    </div>
  );
}
```

---

## Migration Guide

### Step-by-Step Component Migration

**Step 1: Identify Local State**
```typescript
// BEFORE - Local state
const [dateRange, setDateRange] = useState(30);
const [loading, setLoading] = useState(false);
const [data, setData] = useState([]);
```

**Step 2: Move Filter State to Redux**
```typescript
// AFTER - Use Redux filters
import { useAppSelector, useAppDispatch } from '../../store';
import { setDateRange } from '../../store/slices/filtersSlice';

const dispatch = useAppDispatch();
const dateRange = useAppSelector((state) => state.filters.dateRange);
```

**Step 3: Replace Fetch Logic with RTK Query**
```typescript
// BEFORE - Manual fetch
useEffect(() => {
  setLoading(true);
  fetch('/api/assets')
    .then(res => res.json())
    .then(data => {
      setData(data);
      setLoading(false);
    });
}, []);

// AFTER - RTK Query
const { data, isLoading } = useGetAssetsQuery();
```

**Step 4: Remove Props Drilling**
```typescript
// BEFORE - Pass filters through props
<ChildComponent dateRange={dateRange} onDateChange={setDateRange} />

// AFTER - Child accesses Redux directly
<ChildComponent />

// In ChildComponent:
const dateRange = useAppSelector((state) => state.filters.dateRange);
```

---

## Best Practices

### 1. Use Typed Hooks
```typescript
// ✅ DO: Use pre-typed hooks
import { useAppSelector, useAppDispatch } from '../../store';

// ❌ DON'T: Use raw hooks
import { useSelector, useDispatch } from 'react-redux';
```

### 2. Selector Patterns
```typescript
// ✅ DO: Create reusable selectors
const selectCriticalIssues = (state: RootState) =>
  state.filters.severity.includes('critical');

const hasCriticalFilter = useAppSelector(selectCriticalIssues);

// ❌ DON'T: Inline complex selectors repeatedly
const hasCritical = useAppSelector((state) =>
  state.filters.severity.includes('critical')
); // Repeated in multiple components
```

### 3. RTK Query Cache Management
```typescript
// ✅ DO: Use tag-based invalidation
export const easmApi = createApi({
  tagTypes: ['Assets', 'Issues'],
  endpoints: (builder) => ({
    getAssets: builder.query({
      providesTags: ['Assets'],
    }),
    updateAsset: builder.mutation({
      invalidatesTags: ['Assets'], // Auto-refetch assets after update
    }),
  }),
});
```

### 4. Error Handling
```typescript
// ✅ DO: Handle errors properly
const { data, error, isLoading } = useGetAssetsQuery();

if (error) {
  if ('status' in error) {
    return <Alert>Error {error.status}: {JSON.stringify(error.data)}</Alert>;
  }
  return <Alert>An error occurred</Alert>;
}
```

### 5. Conditional Fetching
```typescript
// ✅ DO: Skip unnecessary queries
const { data } = useGetAssetByIdQuery(assetId, {
  skip: !assetId, // Don't fetch if no ID
});
```

---

## Backend Integration

### Current State: Mock Data

The API is currently configured with mock data for development:

```typescript
// src/store/services/api.ts
getAssets: builder.query<Asset[], Params>({
  queryFn: async () => {
    await new Promise((resolve) => setTimeout(resolve, 500));
    return { data: mockAssets }; // Mock data
  },
}),
```

### Switching to Real Backend

When the backend team completes the Django REST API, simply update the endpoints:

**Step 1: Remove Mock Data**
```typescript
// Remove queryFn and mock data
getAssets: builder.query<Asset[], Params>({
  query: ({ dateRange, types, search }) => ({
    url: '/assets',
    params: {
      start: dateRange?.start,
      end: dateRange?.end,
      types: types?.join(','),
      search,
    },
  }),
  providesTags: ['Assets'],
}),
```

**Step 2: Configure Base URL**
```typescript
export const easmApi = createApi({
  reducerPath: 'easmApi',
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
    prepareHeaders: (headers) => {
      const token = localStorage.getItem('token');
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  // ... rest of config
});
```

**Step 3: Update Environment Variables**
```bash
# .env
REACT_APP_API_URL=http://backend:8000/api
```

### Backend API Contract

The backend should implement these endpoints:

```
GET    /api/assets                 # List assets
GET    /api/assets/:id             # Get asset details
POST   /api/assets                 # Create asset
PUT    /api/assets/:id             # Update asset
DELETE /api/assets/:id             # Delete asset

GET    /api/issues                 # List issues
GET    /api/issues/:id             # Get issue details

GET    /api/dashboard/metrics      # Dashboard metrics

GET    /api/scans                  # List scans
POST   /api/scans                  # Start scan
```

**Expected Response Format:**
```typescript
// Assets list
{
  "data": [
    {
      "id": "uuid",
      "name": "web-server-01",
      "type": "Server",
      "ip": "192.168.1.10",
      "status": "active",
      "discoveredAt": "2024-11-20T10:00:00Z",
      "riskScore": 75,
      "vulnerabilities": 12
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 50,
    "total": 131542
  }
}
```

---

## Redux DevTools

### Installation

Install Redux DevTools Extension:
- [Chrome](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd)
- [Firefox](https://addons.mozilla.org/en-US/firefox/addon/reduxdevtools/)

### Features

1. **State Inspection**: View entire Redux state tree
2. **Action History**: See all dispatched actions
3. **Time Travel**: Jump to any previous state
4. **Action Replay**: Replay actions to debug issues
5. **State Diff**: Compare state before/after actions

### Usage

Open browser DevTools → Redux tab → Explore:
- **State**: Current state tree
- **Diff**: Changes from last action
- **Action**: Dispatched action details
- **Test**: Export/import state for testing

---

## Summary

### Quick Reference

**Import Store Hooks:**
```typescript
import { useAppSelector, useAppDispatch } from '../../store';
```

**Dispatch Actions:**
```typescript
const dispatch = useAppDispatch();
dispatch(setDateRange({ start, end }));
```

**Select State:**
```typescript
const filters = useAppSelector((state) => state.filters);
```

**Use RTK Query:**
```typescript
const { data, isLoading, error } = useGetAssetsQuery();
```

**Handle Mutations:**
```typescript
const [startScan, { isLoading }] = useStartScanMutation();
await startScan({ name: 'Scan', type: 'full' });
```

### Benefits Achieved

✅ Centralized state management
✅ Automatic caching and invalidation
✅ Type-safe state access
✅ Simplified data fetching
✅ Better developer experience
✅ Scalable architecture
✅ Easy backend integration

---

## Additional Resources

- [Redux Toolkit Documentation](https://redux-toolkit.js.org/)
- [RTK Query Documentation](https://redux-toolkit.js.org/rtk-query/overview)
- [Redux DevTools Documentation](https://github.com/reduxjs/redux-devtools)
- [TypeScript with Redux](https://redux.js.org/usage/usage-with-typescript)

---

**Last Updated:** November 21, 2025
**Version:** 1.0.0
**Maintainer:** EASM-RND Frontend Team
