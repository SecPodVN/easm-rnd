# Frontend Development Guide

**A comprehensive guide for developers new to the EASM Platform frontend**

This guide will walk you through working with the EASM Platform React frontend. Whether you're adding a new feature, fixing bugs, or integrating with backend APIs, this guide has you covered.

**Date: November 21, 2025**

---

## 📚 Table of Contents

1. [Quick Start](#-quick-start)
2. [Understanding the Architecture](#-understanding-the-architecture)
3. [Project Structure](#-project-structure)
4. [Technology Stack](#-technology-stack)
5. [Development Workflow](#-development-workflow)
6. [Adding Your First Feature - Quick Recipe](#-adding-your-first-feature---quick-recipe)
7. [Method 1: Adding to Existing Feature Module](#-method-1-adding-to-existing-feature-module)
8. [Method 2: Creating a New Feature Module](#-method-2-creating-a-new-feature-module)
9. [API Integration with RTK Query](#-api-integration-with-rtk-query)
10. [State Management with Redux](#-state-management-with-redux)
11. [Component Development](#-component-development)
12. [Styling & Theming](#-styling--theming)
13. [Testing](#-testing)
14. [Best Practices](#-best-practices)
15. [Troubleshooting](#-troubleshooting)
16. [Checklist & Quick Reference](#-checklist--quick-reference)

---

## 🚀 Quick Start

### The 5-Minute Overview

**Our frontend structure follows this pattern:**

```
easm-platform/
└── src/
    └── frontend/
        ├── easm-user-portal/              # 🎯 Main User Portal
        │   ├── public/               # Static assets
        │   │   ├── index.html
        │   │   └── manifest.json
        │   │
        │   ├── src/
        │   │   ├── features/         # 🎯 FEATURE MODULES (add features here)
        │   │   │   ├── dashboard/
        │   │   │   ├── discovery/
        │   │   │   ├── inventory/
        │   │   │   ├── vulnerabilities/
        │   │   │   ├── reports/
        │   │   │   ├── jobs/
        │   │   │   └── settings/
        │   │   │
        │   │   ├── shared/
        │   │   │   └── components/   # ⭐ Reusable UI components
        │   │   │
        │   │   ├── store/            # 🎯 Redux Store
        │   │   │   ├── index.ts      # Store configuration
        │   │   │   ├── slices/       # Redux state slices
        │   │   │   └── services/
        │   │   │       └── api.ts    # ⭐ ALL API endpoints
        │   │   │
        │   │   ├── components/       # Layout components
        │   │   │   └── DashboardLayout.tsx
        │   │   │
        │   │   ├── App.tsx           # ⭐ Routes & navigation
        │   │   └── index.tsx         # Entry point
        │   │
        │   ├── package.json          # Dependencies
        │   └── tsconfig.json         # TypeScript config
        │
        ├── easm-admin-portal/               # 📦 Admin Portal (future)
        └── easm-react/             # 📚 Shared UI library
```

**Key Concepts:**

- **Features** live in `src/features/[feature-name]/`
- **API calls** are defined in `src/store/services/api.ts`
- **Routes** are registered in `src/App.tsx`
- **Shared components** live in `src/shared/components/`
- **Redux state** is managed in `src/store/`

### Your First Feature in 3 Steps

```bash
# 1. Create component in features directory
# Create: src/features/[feature-name]/ComponentName.tsx

# 2. Add API endpoint (if needed)
# Edit: src/store/services/api.ts

# 3. Add route
# Edit: src/App.tsx
```

---

## 🏗️ Understanding the Architecture

### Frontend Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      EASM Frontend (React)                   │
│                                                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Dashboard │  │Inventory │  │  Vulns   │  │ Reports  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       └─────────────┴──────────────┴──────────────┘          │
│                            │                                  │
│                  ┌─────────▼────────┐                        │
│                  │ Shared Components │                        │
│                  └─────────┬────────┘                        │
│                            │                                  │
│       ┌────────────────────┴────────────────────┐           │
│       │    Redux Store + RTK Query (API)        │           │
│       └────────────────────┬────────────────────┘           │
└────────────────────────────┼────────────────────────────────┘
                             │
                   ┌─────────▼──────────┐
                   │  Django REST API   │
                   └────────────────────┘
```

### Data Flow

```
User Action → Component → RTK Query Hook → API Call → Backend
                                                          ↓
User sees update ← Component Re-renders ← Cache Updated ← Response
```

### State Management Strategy

| State Type | Solution | Example |
|------------|----------|---------|
| ✅ Server Data (API) | RTK Query | Assets, vulnerabilities, reports |
| ✅ Client State (UI) | Redux Slices | Filters, sidebar state, selections |
| ✅ Component State | React useState | Form inputs, modals, local UI |

---

## 📁 Project Structure

### Detailed Directory Structure

```
src/frontend/easm-user-portal/
├── public/
│   ├── index.html              # HTML template
│   ├── manifest.json           # PWA manifest
│   └── robots.txt              # SEO config
│
├── src/
│   ├── features/               # ✅ Feature modules (business logic)
│   │   ├── dashboard/
│   │   │   ├── Dashboard.tsx              # Main dashboard page
│   │   │   ├── Overview.tsx               # Overview section
│   │   │   ├── RecentActivity.tsx         # Activity feed
│   │   │   └── index.ts                   # Exports
│   │   │
│   │   ├── discovery/
│   │   │   ├── SeedList.tsx               # Seed management
│   │   │   ├── SeedForm.tsx               # Add/edit seed
│   │   │   └── index.ts
│   │   │
│   │   ├── inventory/
│   │   │   ├── AssetList.tsx              # Asset list view
│   │   │   ├── AssetDetail.tsx            # Asset details
│   │   │   ├── DomainInventory.tsx        # Domain-specific view
│   │   │   ├── IPInventory.tsx            # IP-specific view
│   │   │   └── index.ts
│   │   │
│   │   ├── vulnerabilities/
│   │   │   ├── VulnerabilityList.tsx      # Vulnerability list
│   │   │   ├── VulnerabilityDetail.tsx    # Vuln details
│   │   │   ├── SeverityChart.tsx          # Severity distribution
│   │   │   └── index.ts
│   │   │
│   │   ├── reports/
│   │   │   ├── ReportList.tsx             # Generated reports
│   │   │   ├── ReportGenerator.tsx        # Create new report
│   │   │   └── index.ts
│   │   │
│   │   ├── jobs/
│   │   │   ├── JobList.tsx                # Background jobs
│   │   │   ├── JobDetail.tsx              # Job details
│   │   │   └── index.ts
│   │   │
│   │   └── settings/
│   │       ├── Settings.tsx               # User settings
│   │       ├── ProfileSettings.tsx        # Profile management
│   │       └── index.ts
│   │
│   ├── shared/
│   │   └── components/         # ✅ Reusable UI components
│   │       ├── StatCard.tsx              # Metric display card
│   │       ├── InsightCard.tsx           # Insight/alert card
│   │       ├── PageHeader.tsx            # Page header with actions
│   │       ├── SearchBar.tsx             # Search input
│   │       ├── FilterBar.tsx             # Filter controls
│   │       ├── EmptyState.tsx            # No data state
│   │       ├── LoadingState.tsx          # Loading skeleton
│   │       ├── ErrorState.tsx            # Error display
│   │       └── index.ts                  # Barrel exports
│   │
│   ├── store/                  # ✅ Redux store & API
│   │   ├── index.ts                      # Store configuration
│   │   │
│   │   ├── slices/             # Redux state slices
│   │   │   ├── filtersSlice.ts          # Global filters (date, severity)
│   │   │   └── uiSlice.ts               # UI state (sidebar, modals)
│   │   │
│   │   └── services/
│   │       └── api.ts          # ⭐ RTK Query API definition
│   │
│   ├── components/             # Layout & utility components
│   │   ├── DashboardLayout.tsx          # Main app layout
│   │   ├── Sidebar.tsx                  # Navigation sidebar
│   │   ├── TopBar.tsx                   # Top navigation bar
│   │   └── PrivateRoute.tsx             # Auth-protected routes
│   │
│   ├── App.tsx                 # ⭐ Application routes
│   ├── App.css                 # Global styles
│   ├── index.tsx               # React entry point
│   ├── index.css               # Base styles
│   └── setupTests.ts           # Test configuration
│
├── package.json                # ⭐ NPM dependencies
├── tsconfig.json               # TypeScript configuration
├── .env                        # Environment variables
└── README.md                   # Project documentation
```

---

## 🛠️ Technology Stack

### Core Technologies

| Technology | Version | Purpose | Documentation |
|------------|---------|---------|---------------|
| **React** | 19.2.0 | UI library | [react.dev](https://react.dev) |
| **TypeScript** | 4.9.5 | Type safety | [typescriptlang.org](https://www.typescriptlang.org) |
| **Material-UI** | 7.3.4 | Component library | [mui.com](https://mui.com) |
| **Redux Toolkit** | 2.0.1 | State management | [redux-toolkit.js.org](https://redux-toolkit.js.org) |
| **RTK Query** | 2.0.1 | API integration | [redux-toolkit.js.org/rtk-query](https://redux-toolkit.js.org/rtk-query/overview) |
| **React Router** | 6.x | Routing | [reactrouter.com](https://reactrouter.com) |

### Additional Libraries

- **Recharts**: Charts and visualizations
- **date-fns**: Date manipulation
- **React Hook Form**: Form handling
- **React DevTools**: Development debugging

---

## 🔧 Development Workflow

### Installation & Setup

```powershell
# Navigate to frontend directory
cd src/frontend/easm-user-portal

# Install dependencies
npm install

# Start development server
npm start
```

Application opens at `http://localhost:3000` with hot reload enabled.

### Available Commands

```powershell
npm start          # Start dev server (port 3000)
npm test           # Run tests in watch mode
npm run build      # Production build
npm run lint       # Run ESLint
npm run format     # Format code with Prettier
```

### Environment Variables

Create `.env` file in `easm-user-portal/` directory:

```bash
REACT_APP_API_URL=http://localhost:8000/api
REACT_APP_ENV=development
```

---

## 🆕 Adding Your First Feature - Quick Recipe

### Scenario: Add "Notes" Feature

**Goal**: Create a new "Notes" feature where users can view and create notes.

#### Step 1: Create Component (`src/features/notes/NotesList.tsx`)

```typescript
import React from 'react';
import { Box, Button, Typography } from '@mui/material';
import { Add as AddIcon } from '@mui/icons-material';
import { PageHeader, LoadingState, EmptyState } from '../../shared/components';
import { useGetNotesQuery } from '../../store/services/api';

export const NotesList: React.FC = () => {
  const { data: notes, isLoading, error } = useGetNotesQuery();

  if (isLoading) return <LoadingState />;
  if (error) return <Typography color="error">Error loading notes</Typography>;
  if (!notes?.length) return <EmptyState title="No notes yet" />;

  return (
    <Box sx={{ p: 3 }}>
      <PageHeader
        title="Notes"
        subtitle="Manage your notes"
        actions={
          <Button variant="contained" startIcon={<AddIcon />}>
            Add Note
          </Button>
        }
      />

      <Box sx={{ mt: 3 }}>
        {notes.map(note => (
          <Box key={note.id} sx={{ p: 2, mb: 2, border: 1, borderColor: 'divider' }}>
            <Typography variant="h6">{note.title}</Typography>
            <Typography variant="body2" color="text.secondary">
              {note.content}
            </Typography>
          </Box>
        ))}
      </Box>
    </Box>
  );
};
```

#### Step 2: Create Index Export (`src/features/notes/index.ts`)

```typescript
export { NotesList } from './NotesList';
```

#### Step 3: Define API Endpoint (`src/store/services/api.ts`)

```typescript
// Add interface
interface Note {
  id: string;
  title: string;
  content: string;
  created_at: string;
}

// Add to endpoints
export const easmApi = createApi({
  // ... existing config
  endpoints: (builder) => ({
    // ... existing endpoints

    // ✅ Add these endpoints
    getNotes: builder.query<Note[], void>({
      query: () => '/notes/',
      providesTags: ['Notes'],
    }),

    createNote: builder.mutation<Note, { title: string; content: string }>({
      query: (body) => ({
        url: '/notes/',
        method: 'POST',
        body,
      }),
      invalidatesTags: ['Notes'],
    }),

    deleteNote: builder.mutation<void, string>({
      query: (id) => ({
        url: `/notes/${id}/`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Notes'],
    }),
  }),
});

// Export hooks
export const {
  useGetNotesQuery,
  useCreateNoteMutation,
  useDeleteNoteMutation,
  // ... other hooks
} = easmApi;
```

#### Step 4: Add Route (`src/App.tsx`)

```typescript
import { NotesList } from './features/notes';

// In your route switch/case
case 'notes':
  return <NotesList />;
```

#### Step 5: Add to Sidebar (`src/components/DashboardLayout.tsx`)

```typescript
import { Notes as NotesIcon } from '@mui/icons-material';

const menuItems = [
  // ... existing items
  {
    id: 'notes',
    label: 'Notes',
    icon: <NotesIcon />,
    path: 'notes'
  },
];
```

**Done!** 🎉 You now have a working Notes feature.

---

## 📦 Method 1: Adding to Existing Feature Module

### When to Use This Method

- Adding functionality to an existing feature (e.g., add export to Dashboard)
- Extending current pages with new components
- Adding new views within existing modules

### Example: Add Export to Dashboard

#### 1. Create Export Component (`src/features/dashboard/ExportButton.tsx`)

```typescript
import React from 'react';
import { Button } from '@mui/material';
import { Download as DownloadIcon } from '@mui/icons-material';

export const ExportButton: React.FC = () => {
  const handleExport = () => {
    // Export logic
    console.log('Exporting dashboard data...');
  };

  return (
    <Button
      variant="outlined"
      startIcon={<DownloadIcon />}
      onClick={handleExport}
    >
      Export
    </Button>
  );
};
```

#### 2. Update Dashboard Component

```typescript
// src/features/dashboard/Dashboard.tsx
import { ExportButton } from './ExportButton';

export const Dashboard: React.FC = () => {
  return (
    <Box>
      <PageHeader
        title="Dashboard"
        actions={<ExportButton />}  {/* ✅ Add here */}
      />
      {/* Rest of dashboard */}
    </Box>
  );
};
```

#### 3. Export from Index

```typescript
// src/features/dashboard/index.ts
export { Dashboard } from './Dashboard';
export { ExportButton } from './ExportButton';  // ✅ Add this
```

---

## 🆕 Method 2: Creating a New Feature Module

### When to Use This Method

- Adding a completely new feature (e.g., Notifications, Audit Logs)
- Creating a new top-level page
- Building independent functionality

### Step-by-Step: Create "Notifications" Feature

#### 1. Create Feature Directory

```
src/features/notifications/
├── NotificationList.tsx
├── NotificationItem.tsx
├── NotificationSettings.tsx
└── index.ts
```

#### 2. Create Main Component (`NotificationList.tsx`)

```typescript
import React, { useState } from 'react';
import { Box, List, Typography, Tabs, Tab } from '@mui/material';
import { PageHeader } from '../../shared/components';
import { useGetNotificationsQuery } from '../../store/services/api';
import { NotificationItem } from './NotificationItem';

export const NotificationList: React.FC = () => {
  const [filter, setFilter] = useState<'all' | 'unread'>('all');
  const { data: notifications, isLoading } = useGetNotificationsQuery({ filter });

  return (
    <Box sx={{ p: 3 }}>
      <PageHeader title="Notifications" />

      <Tabs value={filter} onChange={(_, v) => setFilter(v)}>
        <Tab label="All" value="all" />
        <Tab label="Unread" value="unread" />
      </Tabs>

      {isLoading ? (
        <LoadingState />
      ) : (
        <List>
          {notifications?.map(notif => (
            <NotificationItem key={notif.id} notification={notif} />
          ))}
        </List>
      )}
    </Box>
  );
};
```

#### 3. Create Item Component (`NotificationItem.tsx`)

```typescript
import React from 'react';
import { ListItem, ListItemText, IconButton } from '@mui/material';
import { Delete as DeleteIcon } from '@mui/icons-material';
import { useDeleteNotificationMutation } from '../../store/services/api';

interface NotificationItemProps {
  notification: {
    id: string;
    title: string;
    message: string;
    read: boolean;
  };
}

export const NotificationItem: React.FC<NotificationItemProps> = ({ notification }) => {
  const [deleteNotification] = useDeleteNotificationMutation();

  const handleDelete = async () => {
    await deleteNotification(notification.id).unwrap();
  };

  return (
    <ListItem
      sx={{
        bgcolor: notification.read ? 'transparent' : 'action.hover',
        mb: 1,
      }}
      secondaryAction={
        <IconButton onClick={handleDelete}>
          <DeleteIcon />
        </IconButton>
      }
    >
      <ListItemText
        primary={notification.title}
        secondary={notification.message}
      />
    </ListItem>
  );
};
```

#### 4. Create Index Exports (`index.ts`)

```typescript
export { NotificationList } from './NotificationList';
export { NotificationItem } from './NotificationItem';
```

#### 5. Add API Endpoints (`src/store/services/api.ts`)

```typescript
interface Notification {
  id: string;
  title: string;
  message: string;
  read: boolean;
  created_at: string;
}

// Add to endpoints
getNotifications: builder.query<Notification[], { filter: 'all' | 'unread' }>({
  query: ({ filter }) => `/notifications/?filter=${filter}`,
  providesTags: ['Notifications'],
}),

markAsRead: builder.mutation<void, string>({
  query: (id) => ({
    url: `/notifications/${id}/mark_read/`,
    method: 'POST',
  }),
  invalidatesTags: ['Notifications'],
}),

deleteNotification: builder.mutation<void, string>({
  query: (id) => ({
    url: `/notifications/${id}/`,
    method: 'DELETE',
  }),
  invalidatesTags: ['Notifications'],
}),

// Export hooks
export const {
  useGetNotificationsQuery,
  useMarkAsReadMutation,
  useDeleteNotificationMutation,
} = easmApi;
```

#### 6. Add Route (`src/App.tsx`)

```typescript
import { NotificationList } from './features/notifications';

// In routing
case 'notifications':
  return <NotificationList />;
```

#### 7. Add to Navigation (`src/components/DashboardLayout.tsx`)

```typescript
import { Notifications as NotificationsIcon } from '@mui/icons-material';

{
  id: 'notifications',
  label: 'Notifications',
  icon: <NotificationsIcon />,
  path: 'notifications',
  badge: unreadCount, // Optional badge
}
```

---

## 🔌 API Integration with RTK Query

### Understanding RTK Query

RTK Query provides:
- ✅ Automatic caching
- ✅ Loading states
- ✅ Error handling
- ✅ Cache invalidation
- ✅ Polling & refetching
- ✅ TypeScript support

### API Configuration (`src/store/services/api.ts`)

```typescript
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

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
  tagTypes: ['Assets', 'Vulnerabilities', 'Reports', 'Notes', 'Notifications'],
  endpoints: (builder) => ({
    // Endpoints defined here
  }),
});
```

### Query Endpoints (GET)

```typescript
// List query
getAssets: builder.query<Asset[], { search?: string; type?: string }>({
  query: ({ search, type }) => ({
    url: '/assets/',
    params: { search, type },
  }),
  providesTags: ['Assets'],
}),

// Detail query
getAssetById: builder.query<Asset, string>({
  query: (id) => `/assets/${id}/`,
  providesTags: (result, error, id) => [{ type: 'Assets', id }],
}),
```

### Mutation Endpoints (POST/PUT/DELETE)

```typescript
// Create
createAsset: builder.mutation<Asset, Partial<Asset>>({
  query: (body) => ({
    url: '/assets/',
    method: 'POST',
    body,
  }),
  invalidatesTags: ['Assets'],
}),

// Update
updateAsset: builder.mutation<Asset, { id: string; data: Partial<Asset> }>({
  query: ({ id, data }) => ({
    url: `/assets/${id}/`,
    method: 'PUT',
    body: data,
  }),
  invalidatesTags: (result, error, { id }) => [{ type: 'Assets', id }],
}),

// Delete
deleteAsset: builder.mutation<void, string>({
  query: (id) => ({
    url: `/assets/${id}/`,
    method: 'DELETE',
  }),
  invalidatesTags: ['Assets'],
}),
```

### Using Queries in Components

```typescript
import { useGetAssetsQuery } from '../../store/services/api';

const AssetList: React.FC = () => {
  const { data, isLoading, error, refetch } = useGetAssetsQuery({
    search: '',
    type: 'domain',
  });

  if (isLoading) return <LoadingState />;
  if (error) return <ErrorState error={error} />;

  return (
    <Box>
      <Button onClick={refetch}>Refresh</Button>
      {data?.map(asset => <AssetCard key={asset.id} asset={asset} />)}
    </Box>
  );
};
```

### Using Mutations in Components

```typescript
import { useCreateAssetMutation } from '../../store/services/api';

const CreateAssetForm: React.FC = () => {
  const [createAsset, { isLoading, error }] = useCreateAssetMutation();
  const [name, setName] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await createAsset({ name, type: 'domain' }).unwrap();
      alert('Asset created successfully!');
      setName('');
    } catch (err) {
      console.error('Failed to create asset:', err);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <TextField
        value={name}
        onChange={(e) => setName(e.target.value)}
        disabled={isLoading}
      />
      <Button type="submit" disabled={isLoading}>
        {isLoading ? 'Creating...' : 'Create'}
      </Button>
      {error && <Typography color="error">{error.message}</Typography>}
    </form>
  );
};
```

### Advanced RTK Query Features

#### Polling (Auto-refresh)

```typescript
const { data } = useGetAssetsQuery({}, {
  pollingInterval: 30000, // Refresh every 30 seconds
});
```

#### Conditional Fetching

```typescript
const { data } = useGetAssetByIdQuery(assetId, {
  skip: !assetId, // Don't fetch if no ID
});
```

#### Manual Refetch

```typescript
const { data, refetch } = useGetAssetsQuery();

<Button onClick={() => refetch()}>Refresh</Button>
```

#### Optimistic Updates

```typescript
const [updateAsset] = useUpdateAssetMutation();

const handleUpdate = async (id: string, newName: string) => {
  try {
    await updateAsset({ id, data: { name: newName } }).unwrap();
    // Success - cache automatically updated
  } catch (err) {
    // Error - cache rolled back
    console.error('Update failed:', err);
  }
};
```

---

## 🗂️ State Management with Redux

### When to Use Redux vs RTK Query

| Use Case | Solution | Example |
|----------|----------|---------|
| Server data (API) | RTK Query | Assets, vulnerabilities, reports |
| Client state (filters) | Redux Slices | Date range, severity filter |
| UI state | Redux Slices | Sidebar open/closed, modal state |
| Component-local | React useState | Form inputs, temporary UI state |

### Available Redux Slices

#### Filters Slice (`src/store/slices/filtersSlice.ts`)

**Purpose**: Global filter state shared across pages

```typescript
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface FiltersState {
  dateRange: number; // Days
  severity: string[];
  assetTypes: string[];
  searchQuery: string;
}

const initialState: FiltersState = {
  dateRange: 30,
  severity: [],
  assetTypes: [],
  searchQuery: '',
};

const filtersSlice = createSlice({
  name: 'filters',
  initialState,
  reducers: {
    setDateRange: (state, action: PayloadAction<number>) => {
      state.dateRange = action.payload;
    },
    setSeverity: (state, action: PayloadAction<string[]>) => {
      state.severity = action.payload;
    },
    setAssetTypes: (state, action: PayloadAction<string[]>) => {
      state.assetTypes = action.payload;
    },
    setSearchQuery: (state, action: PayloadAction<string>) => {
      state.searchQuery = action.payload;
    },
    resetFilters: () => initialState,
  },
});

export const { setDateRange, setSeverity, setAssetTypes, setSearchQuery, resetFilters } = filtersSlice.actions;
export default filtersSlice.reducer;
```

**Usage:**

```typescript
import { useAppDispatch, useAppSelector } from '../../store';
import { setDateRange, setSeverity } from '../../store/slices/filtersSlice';

const FilterBar: React.FC = () => {
  const dispatch = useAppDispatch();
  const { dateRange, severity } = useAppSelector(state => state.filters);

  return (
    <Box>
      <Select
        value={dateRange}
        onChange={(e) => dispatch(setDateRange(Number(e.target.value)))}
      >
        <MenuItem value={7}>Last 7 days</MenuItem>
        <MenuItem value={30}>Last 30 days</MenuItem>
        <MenuItem value={90}>Last 90 days</MenuItem>
      </Select>
    </Box>
  );
};
```

#### UI Slice (`src/store/slices/uiSlice.ts`)

**Purpose**: Application UI state

```typescript
interface UiState {
  sidebarOpen: boolean;
  currentModal: string | null;
  selectedAssets: string[];
  viewMode: 'grid' | 'list';
}

const initialState: UiState = {
  sidebarOpen: true,
  currentModal: null,
  selectedAssets: [],
  viewMode: 'grid',
};

const uiSlice = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    toggleSidebar: (state) => {
      state.sidebarOpen = !state.sidebarOpen;
    },
    openModal: (state, action: PayloadAction<string>) => {
      state.currentModal = action.payload;
    },
    closeModal: (state) => {
      state.currentModal = null;
    },
    toggleAssetSelection: (state, action: PayloadAction<string>) => {
      const index = state.selectedAssets.indexOf(action.payload);
      if (index >= 0) {
        state.selectedAssets.splice(index, 1);
      } else {
        state.selectedAssets.push(action.payload);
      }
    },
    setViewMode: (state, action: PayloadAction<'grid' | 'list'>) => {
      state.viewMode = action.payload;
    },
  },
});

export const { toggleSidebar, openModal, closeModal, toggleAssetSelection, setViewMode } = uiSlice.actions;
export default uiSlice.reducer;
```

**Usage:**

```typescript
const { sidebarOpen, selectedAssets } = useAppSelector(state => state.ui);
const dispatch = useAppDispatch();

<IconButton onClick={() => dispatch(toggleSidebar())}>
  <MenuIcon />
</IconButton>

{selectedAssets.length > 0 && (
  <Button onClick={() => dispatch(openModal('bulk-delete'))}>
    Delete Selected ({selectedAssets.length})
  </Button>
)}
```

---

## 🎨 Component Development

### Shared Component Library

Located in `src/shared/components/`, these components are reusable across features.

#### PageHeader Component

```typescript
// src/shared/components/PageHeader.tsx
import React from 'react';
import { Box, Typography } from '@mui/material';

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  actions?: React.ReactNode;
}

export const PageHeader: React.FC<PageHeaderProps> = ({ title, subtitle, actions }) => {
  return (
    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
      <Box>
        <Typography variant="h4" component="h1">
          {title}
        </Typography>
        {subtitle && (
          <Typography variant="body2" color="text.secondary">
            {subtitle}
          </Typography>
        )}
      </Box>
      {actions && <Box>{actions}</Box>}
    </Box>
  );
};
```

**Usage:**

```typescript
<PageHeader
  title="Assets"
  subtitle="Manage your discovered assets"
  actions={<Button variant="contained">Add Asset</Button>}
/>
```

#### StatCard Component

```typescript
// src/shared/components/StatCard.tsx
import React from 'react';
import { Card, CardContent, Typography, Box } from '@mui/material';
import { TrendingUp, TrendingDown } from '@mui/icons-material';

interface StatCardProps {
  title: string;
  value: string | number;
  change?: number;
  icon?: React.ReactNode;
}

export const StatCard: React.FC<StatCardProps> = ({ title, value, change, icon }) => {
  const isPositive = change && change > 0;

  return (
    <Card>
      <CardContent>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box>
            <Typography color="text.secondary" variant="body2">
              {title}
            </Typography>
            <Typography variant="h4" sx={{ mt: 1 }}>
              {value}
            </Typography>
            {change !== undefined && (
              <Box sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
                {isPositive ? <TrendingUp color="success" /> : <TrendingDown color="error" />}
                <Typography color={isPositive ? 'success.main' : 'error.main'} variant="body2">
                  {change > 0 ? '+' : ''}{change}%
                </Typography>
              </Box>
            )}
          </Box>
          {icon && <Box sx={{ color: 'primary.main' }}>{icon}</Box>}
        </Box>
      </CardContent>
    </Card>
  );
};
```

**Usage:**

```typescript
<StatCard
  title="Total Assets"
  value="1,234"
  change={12.5}
  icon={<DomainIcon fontSize="large" />}
/>
```

#### LoadingState Component

```typescript
// src/shared/components/LoadingState.tsx
import React from 'react';
import { Box, Skeleton } from '@mui/material';

interface LoadingStateProps {
  count?: number;
}

export const LoadingState: React.FC<LoadingStateProps> = ({ count = 3 }) => {
  return (
    <Box>
      {Array.from({ length: count }).map((_, index) => (
        <Skeleton key={index} variant="rectangular" height={80} sx={{ mb: 2 }} />
      ))}
    </Box>
  );
};
```

#### EmptyState Component

```typescript
// src/shared/components/EmptyState.tsx
import React from 'react';
import { Box, Typography, Button } from '@mui/material';
import { Inbox as InboxIcon } from '@mui/icons-material';

interface EmptyStateProps {
  title: string;
  message?: string;
  actionLabel?: string;
  onAction?: () => void;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  title,
  message,
  actionLabel,
  onAction,
}) => {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        py: 8,
      }}
    >
      <InboxIcon sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
      <Typography variant="h6" gutterBottom>
        {title}
      </Typography>
      {message && (
        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
          {message}
        </Typography>
      )}
      {actionLabel && onAction && (
        <Button variant="contained" onClick={onAction}>
          {actionLabel}
        </Button>
      )}
    </Box>
  );
};
```

### Creating Barrel Exports

```typescript
// src/shared/components/index.ts
export { PageHeader } from './PageHeader';
export { StatCard } from './StatCard';
export { LoadingState } from './LoadingState';
export { EmptyState } from './EmptyState';
export { SearchBar } from './SearchBar';
```

---

## 🎨 Styling & Theming

### Material-UI Theme Configuration

```typescript
// src/theme.ts
import { createTheme } from '@mui/material/styles';

export const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h4: {
      fontWeight: 600,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
        },
      },
    },
  },
});
```

### Using sx Prop (Recommended)

```typescript
<Box
  sx={{
    p: 2,                    // padding: 16px
    m: 1,                    // margin: 8px
    mt: 3,                   // margin-top: 24px
    bgcolor: 'primary.main', // background color
    color: 'white',
    borderRadius: 1,         // border-radius: 4px
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
  }}
>
  Content
</Box>
```

### Responsive Styling

```typescript
<Box
  sx={{
    width: {
      xs: '100%',     // 0-600px
      sm: '80%',      // 600-900px
      md: '60%',      // 900-1200px
      lg: '50%',      // 1200-1536px
      xl: '40%',      // 1536px+
    },
  }}
>
  Responsive content
</Box>
```

---

## 🧪 Testing

### Running Tests

```powershell
npm test              # Run tests in watch mode
npm test -- --coverage # Run with coverage report
```

### Component Testing Example

```typescript
// src/features/dashboard/Dashboard.test.tsx
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import { store } from '../../store';
import { Dashboard } from './Dashboard';

describe('Dashboard', () => {
  it('renders dashboard title', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Dashboard')).toBeInTheDocument();
  });

  it('displays stat cards', () => {
    render(
      <Provider store={store}>
        <Dashboard />
      </Provider>
    );

    expect(screen.getByText('Total Assets')).toBeInTheDocument();
    expect(screen.getByText('Vulnerabilities')).toBeInTheDocument();
  });
});
```

---

## ✅ Best Practices

### 1. Component Organization

```typescript
// ✅ Good: Single responsibility
const AssetList = () => { /* List only */ };
const AssetItem = () => { /* Item only */ };

// ❌ Bad: Too many responsibilities
const AssetsPage = () => { /* List, filter, create, edit, delete all in one */ };
```

### 2. Type Everything

```typescript
// ✅ Good: Explicit types
interface Asset {
  id: string;
  name: string;
  type: 'domain' | 'ip';
}

// ❌ Bad: Any type
const asset: any = data;
```

### 3. Handle All States

```typescript
// ✅ Good: All states handled
if (isLoading) return <LoadingState />;
if (error) return <ErrorState error={error} />;
if (!data?.length) return <EmptyState title="No data" />;
return <DataList data={data} />;

// ❌ Bad: No loading/error handling
return <DataList data={data} />;
```

### 4. Use Shared Components

```typescript
// ✅ Good: Reuse shared components
import { PageHeader, StatCard } from '../../shared/components';

// ❌ Bad: Duplicate code
const MyHeader = () => { /* Same as PageHeader */ };
```

### 5. Keep Files Small

- Components: < 200 lines
- If larger, split into smaller components
- Extract logic into custom hooks

---

## 🐛 Troubleshooting

### Port 3000 Already in Use

```powershell
# Find process using port 3000
netstat -ano | findstr :3000

# Kill the process
taskkill /PID <PID> /F
```

### Module Not Found

```powershell
# Delete node_modules and reinstall
Remove-Item -Recurse -Force node_modules
npm install
```

### API Calls Failing

**Check backend is running:**
```powershell
curl http://localhost:8000/api/docs/
```

**Check browser console:**
- Open DevTools (F12)
- Check Console tab for errors
- Check Network tab for failed requests

**Verify token:**
```javascript
console.log(localStorage.getItem('token'));
```

### Hot Reload Not Working

1. Save file (Ctrl+S)
2. Check console for compilation errors
3. Restart dev server: Ctrl+C → `npm start`

### Redux State Not Updating

**Use Redux DevTools:**
1. Install Redux DevTools extension
2. Open DevTools → Redux tab
3. See all actions and state changes

**Common issues:**
- Forgot to `invalidatesTags` in mutation
- Not exporting hook from api.ts
- Wrong selector in `useAppSelector`

---

## 📋 Checklist & Quick Reference

### Adding a New Feature Checklist

- [ ] Create feature directory in `src/features/[feature-name]/`
- [ ] Create main component file
- [ ] Create index.ts with exports
- [ ] Add API endpoints in `src/store/services/api.ts`
- [ ] Export API hooks
- [ ] Add route in `src/App.tsx`
- [ ] Add to sidebar navigation (if needed)
- [ ] Test the feature
- [ ] Add tests

### Quick Import Reference

```typescript
// Material-UI Components
import { Box, Button, Typography, TextField, Card, Grid } from '@mui/material';

// Material-UI Icons
import { Add, Delete, Edit, Download } from '@mui/icons-material';

// Shared Components
import { PageHeader, StatCard, LoadingState, EmptyState } from '../../shared/components';

// API Hooks
import { useGetAssetsQuery, useCreateAssetMutation } from '../../store/services/api';

// Redux
import { useAppDispatch, useAppSelector } from '../../store';
import { setDateRange } from '../../store/slices/filtersSlice';
```

### Common Patterns Cheat Sheet

```typescript
// Fetch data
const { data, isLoading, error } = useGetItemsQuery();

// Create/Update/Delete
const [create, { isLoading }] = useCreateItemMutation();
await create(data).unwrap();

// Redux dispatch
const dispatch = useAppDispatch();
dispatch(setDateRange(30));

// Redux select
const filters = useAppSelector(state => state.filters);

// Component state
const [value, setValue] = useState('');

// Form handling
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  await createItem({ value }).unwrap();
};
```

---

## 📚 Additional Resources

- **React Documentation**: [react.dev/learn](https://react.dev/learn)
- **Material-UI**: [mui.com/material-ui](https://mui.com/material-ui/getting-started/)
- **Redux Toolkit**: [redux-toolkit.js.org](https://redux-toolkit.js.org/)
- **RTK Query**: [redux-toolkit.js.org/rtk-query](https://redux-toolkit.js.org/rtk-query/overview)
- **TypeScript**: [typescriptlang.org/docs](https://www.typescriptlang.org/docs/)

---

## 🤝 Support

For questions or issues:
1. Check this guide thoroughly
2. Review existing feature code for examples
3. Check browser console for errors
4. Ask in #easm-frontend Slack channel
5. Review backend API documentation if API issues

---

**Happy Coding! 🚀**

*Last Updated: November 21, 2025*

