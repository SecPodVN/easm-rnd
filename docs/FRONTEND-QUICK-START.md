# Frontend Development Guide

**Date: November 24, 2025**

---

## 1. Run the Frontend

### Local Development (Fast)

```powershell
cd src/frontend/easm-user-portal
pnpm install --ignore-workspace
pnpm run dev
```

Opens `http://localhost:3000`. Edit files → see changes instantly with Vite HMR.

### Docker/Skaffold (Full Stack)

```powershell
# Run entire application stack (frontend + backend + databases)
.\skaffold.ps1
```

**Stack:** React 19 + TypeScript + Vite + Material-UI + Redux Toolkit + RTK Query + React Router v7 + pnpm

---

## 1.1. Package Management with pnpm

### ⚠️ Critical: Lockfile Consistency

**Always ensure `pnpm-lock.yaml` is consistent with `package.json`!**

#### After Installing/Updating Packages:

```powershell
cd src/frontend/easm-user-portal

# Install or update packages
pnpm add <package-name>
# or
pnpm remove <package-name>
# or
pnpm update <package-name>

# Always regenerate lockfile
pnpm install --ignore-workspace
```

#### Before Committing:

```powershell
# Verify lockfile consistency (CI/CD check)
pnpm install --frozen-lockfile --ignore-workspace
```

- ✅ **Success** → Lockfile matches package.json, safe to commit
- ❌ **Fails** → Run `pnpm install --ignore-workspace` to regenerate

#### Always Commit Both Files Together:

```powershell
git add src/frontend/easm-user-portal/package.json
git add src/frontend/easm-user-portal/pnpm-lock.yaml
git commit -m "chore(frontend): update dependencies"
```

#### Why This Matters:

- 🔒 **Deterministic builds** - Same versions across all environments
- 🚀 **CI/CD reliability** - Builds won't fail due to mismatched versions
- 🐛 **Bug prevention** - Avoid "works on my machine" issues
- ⚡ **Fast installs** - pnpm uses content-addressable storage (faster than npm)

#### Common Commands:

```powershell
# Install dependencies (local dev)
pnpm install --ignore-workspace

# Install with frozen lockfile (CI/CD)
pnpm install --frozen-lockfile --ignore-workspace

# Add new dependency
pnpm add <package>

# Add dev dependency
pnpm add -D <package>

# Remove dependency
pnpm remove <package>

# Update specific package
pnpm update <package>

# Update all packages
pnpm update

# List installed packages
pnpm list --depth=0

# Check for outdated packages
pnpm outdated
```

---

## 2. Application Structure

### 🏗️ Architecture Diagram

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

### 📁 Directory Structure

```
src/
├── features/                    # ✅ Add new features here
│   ├── dashboard/
│   ├── discovery/
│   ├── inventory/
│   ├── vulnerabilities/
│   ├── reports/
│   ├── jobs/
│   └── settings/
│
├── shared/components/           # ✅ Reusable UI components
│   ├── StatCard.tsx
│   ├── PageHeader.tsx
│   ├── SearchBar.tsx
│   ├── LoadingState.tsx
│   └── EmptyState.tsx
│
├── store/
│   ├── index.ts                 # Redux store config
│   ├── slices/                  # ✅ Client state (filters, UI)
│   │   ├── filtersSlice.ts
│   │   └── uiSlice.ts
│   └── services/
│       └── api.ts               # ✅ ALL API endpoints
│
├── routes/
│   └── index.tsx                # ✅ Route configuration
│
├── components/
│   └── DashboardLayout.tsx      # Main layout + sidebar
│
└── App.tsx                      # Router setup
```

**Data Flow:**

```
Component → RTK Query Hook → API → Backend → Cache → Component Updates
```

**Routing:**

```
URL → React Router → Route Match → Component Render
```

---

## 3. Adding Features

### 🆕 Example: Add "Notes" Feature

#### Step 1: Create Component (`src/features/notes/NotesList.tsx`)

```typescript
import { Box, Button } from "@mui/material";
import { PageHeader, LoadingState } from "../../shared/components";
import { useGetNotesQuery } from "../../store/services/api";

export const NotesList = () => {
  const { data, isLoading } = useGetNotesQuery();

  if (isLoading) return <LoadingState />;

  return (
    <Box sx={{ p: 3 }}>
      <PageHeader title="Notes" />
      {data?.map((note) => (
        <div key={note.id}>{note.title}</div>
      ))}
    </Box>
  );
};
```

#### Step 2: Add API Endpoint (`src/store/services/api.ts`)

```typescript
// Define type
interface Note {
  id: string;
  title: string;
  content: string;
}

// Add to endpoints
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
  invalidatesTags: ['Notes'],  // ✅ Auto-refresh after create
}),

// Export hooks
export const { useGetNotesQuery, useCreateNoteMutation } = easmApi;
```

#### Step 3: Add Route (`src/routes/index.tsx`)

```typescript
import { NotesList } from "../features/notes";

export const routes: RouteObject[] = [
  // ...existing routes
  {
    path: "/notes",
    element: <NotesList />,
  },
  // ...
];
```

#### Step 4: Add to Sidebar (`src/components/DashboardLayout.tsx`)

```typescript
import { useLocation, NavLink } from "react-router-dom";

const location = useLocation();
const isActive = (path: string) => location.pathname === path;

<ListItemButton component={NavLink} to="/notes" selected={isActive("/notes")}>
  <ListItemIcon>
    <NotesIcon />
  </ListItemIcon>
  <ListItemText primary="Notes" />
</ListItemButton>;
```

---

## 4. Testing Examples

### Using Browser DevTools

```javascript
// Test API call
const response = await fetch("http://localhost:3000/api/notes/");
const data = await response.json();
console.log(data);

// Check Redux state
console.log(store.getState());

// Check cached data
console.log(localStorage.getItem("token"));
```

### Using React DevTools

1. Install React DevTools extension
2. Open Components tab
3. Select component
4. View props, state, hooks

### Common Debug Patterns

```typescript
// Log hook data
const { data, isLoading, error } = useGetNotesQuery();
console.log("Notes:", { data, isLoading, error });

// Log Redux state
const filters = useAppSelector((state) => state.filters);
console.log("Filters:", filters);

// Log mutations
const [create, { isLoading, error }] = useCreateNoteMutation();
console.log("Create state:", { isLoading, error });
```

---

## 5. Common Patterns

### ✅ Fetch Data

```typescript
const { data, isLoading, error } = useGetItemsQuery({ search, filter });

if (isLoading) return <LoadingState />;
if (error) return <div>Error: {error.message}</div>;
if (!data?.length) return <EmptyState title="No items" />;

return data.map((item) => <div key={item.id}>{item.name}</div>);
```

### ✅ Create/Update

```typescript
const [create, { isLoading }] = useCreateItemMutation();

const handleSubmit = async (e) => {
  e.preventDefault();
  try {
    await create({ name: "Item" }).unwrap();
    alert("Created!");
  } catch (err) {
    alert("Error: " + err.data.message);
  }
};
```

### ✅ Form

```typescript
const [value, setValue] = useState("");

<form onSubmit={handleSubmit}>
  <TextField value={value} onChange={(e) => setValue(e.target.value)} />
  <Button type="submit" disabled={isLoading}>
    {isLoading ? "Saving..." : "Save"}
  </Button>
</form>;
```

### ✅ List with Search

```typescript
const [search, setSearch] = useState("");
const { data } = useGetItemsQuery({ search });

<>
  <SearchBar value={search} onChange={setSearch} />
  {data?.map((item) => (
    <ItemCard key={item.id} item={item} />
  ))}
</>;
```

### ✅ Polling (Auto-refresh)

```typescript
const { data } = useGetAssetsQuery(
  {},
  {
    pollingInterval: 30000, // Refresh every 30s
  }
);
```

### ✅ Conditional Fetch

```typescript
const { data } = useGetAssetByIdQuery(id, {
  skip: !id, // Don't fetch if no ID
});
```

---

## 6. Redux State Management

### When to Use Redux vs RTK Query

| Use Case                      | Solution     |
| ----------------------------- | ------------ |
| ✅ Server data (API)          | RTK Query    |
| ✅ Client state (filters, UI) | Redux Slices |

### Available Slices

#### 🟦 Filters Slice (`store/slices/filtersSlice.ts`)

```typescript
// Actions
dispatch(setDateRange(30)); // Last 30 days
dispatch(setSeverity(["high"])); // High severity only
dispatch(setAssetTypes(["domain"])); // Domains only

// Selector
const filters = useAppSelector((state) => state.filters);
```

#### 🟦 UI Slice (`store/slices/uiSlice.ts`)

```typescript
// Actions
dispatch(toggleSidebar()); // Show/hide sidebar
dispatch(openModal("delete-confirm")); // Open modal
dispatch(closeModal()); // Close modal
dispatch(toggleAssetSelection("asset-1")); // Select asset

// Selectors
const { sidebarOpen, selectedAssets } = useAppSelector((state) => state.ui);
```

### Example: Using Filters

**FilterBar.tsx** - Set filters

```typescript
const dispatch = useAppDispatch();

<DatePicker onChange={(days) => dispatch(setDateRange(days))} />;
```

**IssueList.tsx** - Use filters in API call

```typescript
const { dateRange, severity } = useAppSelector((state) => state.filters);
const { data } = useGetIssuesQuery({ dateRange, severity });
```

---

## 7. Shared Components

### 🎨 Component Library

```typescript
import { PageHeader, StatCard, SearchBar, LoadingState, EmptyState } from '../../shared/components';
import { Box, Button, Typography, TextField } from '@mui/material';

// Page header
<PageHeader
  title="My Page"
  subtitle="Description"
  actions={<Button>Export</Button>}
/>

// Stat card
<StatCard
  title="Domains"
  value="1,234"
  change={12.5}  // Shows +12.5%
  icon={<DomainIcon />}
/>

// Search
<SearchBar
  placeholder="Search..."
  value={query}
  onChange={setQuery}
/>

// Loading
{isLoading && <LoadingState count={3} />}

// Empty state
{!data?.length && <EmptyState title="No data" />}

// Material-UI
<Box sx={{ p: 2, m: 1 }}>        {/* padding, margin */}
  <Typography variant="h5">Title</Typography>
  <TextField label="Input" />
  <Button variant="contained">Click</Button>
</Box>
```

---

## 8. Benefits of This Structure

### 1. ✅ Type Safety

- TypeScript catches errors at compile time
- Auto-complete in IDE
- Fewer runtime errors

### 2. ✅ Automatic Caching

- RTK Query caches API responses
- Reduces unnecessary network calls
- Automatic background refetching

### 3. ✅ Predictable State

- Redux provides single source of truth
- Time-travel debugging
- Easy to track state changes

### 4. ✅ Code Reusability

- Shared components across features
- DRY principle
- Consistent UI/UX

### 5. ✅ Developer Experience

- Hot reload for instant feedback
- React DevTools integration
- Redux DevTools integration

---

## 9. Troubleshooting

### ⚠️ Port 3000 in use

```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### ⚠️ Module not found

```powershell
# Remove node_modules and reinstall
Remove-Item -Recurse node_modules
pnpm install --ignore-workspace

# Verify lockfile consistency
pnpm install --frozen-lockfile --ignore-workspace
```

### ⚠️ API not working

**Check backend:**

```powershell
# Backend should be running at port 8000
curl http://localhost:8000/api/docs/
```

**Debug steps:**

1. Check browser console for errors
2. Check Network tab in DevTools
3. Verify token: `console.log(localStorage.getItem('token'))`
4. Check Redux state: Use Redux DevTools
5. Check Vite proxy configuration in `vite.config.ts`

### ⚠️ Hot reload not working (Vite HMR)

1. Save file (Ctrl+S)
2. Check terminal for Vite compilation errors
3. Check browser console for HMR errors
4. Restart dev server: Ctrl+C → `pnpm run dev`
5. Clear browser cache if needed (Ctrl+Shift+R)

---

## Quick Reference

| What                 | Where                                              |
| -------------------- | -------------------------------------------------- |
| ✅ Add feature       | `src/features/my-feature/`                         |
| ✅ Add API endpoint  | `src/store/services/api.ts`                        |
| ✅ Add route         | `src/routes/index.tsx`                             |
| ✅ Add to sidebar    | `src/components/DashboardLayout.tsx` (use NavLink) |
| ✅ Shared components | `src/shared/components/`                           |
| ✅ Redux state       | `src/store/slices/`                                |

**Common imports:**

```typescript
import { Box, Button, Typography } from "@mui/material";
import { PageHeader, StatCard } from "../../shared/components";
import { useGetItemsQuery } from "../../store/services/api";
import { useAppDispatch, useAppSelector } from "../../store";
```

---

## Support

For questions or issues:

1. Check browser console for errors
2. Review this guide
3. Check existing feature code for examples
4. Ask in #easm-frontend Slack

if (isLoading) return <LoadingState />;

return (
<Box sx={{ p: 3 }}>
<PageHeader title="Notes" />
{data?.map(note => (

<div key={note.id}>{note.title}</div>
))}
</Box>
);
};

````

### Step 2: Add API Endpoint

In `src/store/services/api.ts`:

```typescript
// Define type
interface Note {
  id: string;
  title: string;
  content: string;
}

// Add to endpoints
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
  invalidatesTags: ['Notes'],  // Auto-refresh list after create
}),

// Export hooks
export const { useGetNotesQuery, useCreateNoteMutation } = easmApi;
````

### Step 3: Add Route

In `src/App.tsx`:

```typescript
case 'notes':
  return <NotesList />;
```

### Step 4: Add to Sidebar (Optional)

In `src/components/DashboardLayout.tsx`:

```typescript
{
  id: 'notes',
  label: 'Notes',
  icon: <NotesIcon />,
  path: 'notes'
}
```

---

## 4. Common Patterns

### Fetch Data

```typescript
const { data, isLoading, error } = useGetItemsQuery({ search, filter });

if (isLoading) return <LoadingState />;
if (error) return <div>Error</div>;
if (!data?.length) return <EmptyState title="No items" />;

return data.map((item) => <div key={item.id}>{item.name}</div>);
```

### Create/Update

```typescript
const [create, { isLoading }] = useCreateItemMutation();

const handleSubmit = async (e) => {
  e.preventDefault();
  try {
    await create({ name: "Item" }).unwrap();
    alert("Created!");
  } catch (err) {
    alert("Error: " + err.data.message);
  }
};
```

### Form

```typescript
const [value, setValue] = useState("");

<form onSubmit={handleSubmit}>
  <TextField value={value} onChange={(e) => setValue(e.target.value)} />
  <Button type="submit" disabled={isLoading}>
    Save
  </Button>
</form>;
```

### List with Search

```typescript
const [search, setSearch] = useState("");
const { data } = useGetItemsQuery({ search });

<>
  <SearchBar value={search} onChange={setSearch} />
  {data?.map((item) => (
    <ItemCard key={item.id} item={item} />
  ))}
</>;
```

---

## 5. Redux State Management

### When to Use Redux vs RTK Query

- **RTK Query**: Server data (API calls, caching, loading states)
- **Redux Slices**: Client state (filters, UI state, selections)

### Available Slices

**Filters Slice** (`store/slices/filtersSlice.ts`):

```typescript
// Actions
dispatch(setDateRange(30)); // Filter by last 30 days
dispatch(setSeverity(["high"])); // Filter by severity
dispatch(setAssetTypes(["domain"])); // Filter by asset type

// Selector
const filters = useAppSelector((state) => state.filters);
```

**UI Slice** (`store/slices/uiSlice.ts`):

```typescript
// Actions
dispatch(toggleSidebar()); // Show/hide sidebar
dispatch(openModal("delete-confirm")); // Open modal
dispatch(closeModal()); // Close modal
dispatch(toggleAssetSelection("asset-1")); // Select/deselect asset

// Selectors
const { sidebarOpen, selectedAssets } = useAppSelector((state) => state.ui);
```

### Example: Using Filters

**FilterBar.tsx** - Set filters

```typescript
const dispatch = useAppDispatch();

<DatePicker onChange={(days) => dispatch(setDateRange(days))} />;
```

**IssueList.tsx** - Use filters in API call

```typescript
const { dateRange, severity } = useAppSelector((state) => state.filters);
const { data } = useGetIssuesQuery({ dateRange, severity });
```

---

## 7. Shared Components

### 🎨 Component Library

```typescript
import { PageHeader, StatCard, SearchBar, LoadingState, EmptyState } from '../../shared/components';
import { Box, Button, Typography, TextField } from '@mui/material';

// Page header
<PageHeader
  title="My Page"
  subtitle="Description"
  actions={<Button>Export</Button>}
/>

// Stat card
<StatCard
  title="Domains"
  value="1,234"
  change={12.5}  // Shows +12.5%
  icon={<DomainIcon />}
/>

// Search
<SearchBar
  placeholder="Search..."
  value={query}
  onChange={setQuery}
/>

// Loading
{isLoading && <LoadingState count={3} />}

// Empty state
{!data?.length && <EmptyState title="No data" />}

// Material-UI
<Box sx={{ p: 2, m: 1 }}>        {/* padding, margin */}
  <Typography variant="h5">Title</Typography>
  <TextField label="Input" />
  <Button variant="contained">Click</Button>
</Box>
```

---

## 8. Benefits of This Structure

### 1. ✅ Type Safety

- TypeScript catches errors at compile time
- Auto-complete in IDE
- Fewer runtime errors

### 2. ✅ Automatic Caching

- RTK Query caches API responses
- Reduces unnecessary network calls
- Automatic background refetching

### 3. ✅ Predictable State

- Redux provides single source of truth
- Time-travel debugging
- Easy to track state changes

### 4. ✅ Code Reusability

- Shared components across features
- DRY principle
- Consistent UI/UX

### 5. ✅ Developer Experience

- Hot reload for instant feedback
- React DevTools integration
- Redux DevTools integration

---

## 9. Troubleshooting

**Port 3000 in use:**

```powershell
# Vite will automatically try the next available port (3001, 3002, etc.)
# Or manually kill the process:
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

**Module not found:**

```powershell
cd src/frontend/easm-user-portal

# Clean reinstall
Remove-Item -Recurse node_modules
pnpm install --ignore-workspace

# Verify lockfile consistency
pnpm install --frozen-lockfile --ignore-workspace
```

**Lockfile out of sync:**

```powershell
# Error: "Lockfile is out of date"
pnpm install --ignore-workspace

# Commit both files
git add package.json pnpm-lock.yaml
```

### ⚠️ API not working

**Check backend:**

```powershell
# Backend should be running at port 8000
curl http://localhost:8000/api/docs/
```

**Debug steps:**

1. Check browser console for errors
2. Check Network tab in DevTools → Look for `/api/` requests
3. Verify Vite proxy in `vite.config.ts` (should proxy `/api` to `http://localhost:8000`)
4. Verify token: `console.log(localStorage.getItem('token'))`
5. Check Redux state: Use Redux DevTools extension

### ⚠️ Hot reload not working (Vite HMR)

1. Save file (Ctrl+S)
2. Check Vite terminal output for compilation errors
3. Check browser console for HMR connection errors
4. Restart dev server: Ctrl+C → `pnpm run dev`
5. Hard refresh browser: Ctrl+Shift+R
6. Clear Vite cache: Remove `.vite` folder and restart

**Build fails:**

```powershell
# Check TypeScript errors
pnpm run build

# If errors about unused variables, they're just warnings
# Check tsconfig.json: noUnusedLocals and noUnusedParameters are set to false
```

---

## Quick Reference

| What              | Where                                              |
| ----------------- | -------------------------------------------------- |
| Add feature       | `src/features/my-feature/`                         |
| Add API endpoint  | `src/store/services/api.ts`                        |
| Add route         | `src/routes/index.tsx`                             |
| Add to sidebar    | `src/components/DashboardLayout.tsx` (use NavLink) |
| Shared components | `src/shared/components/`                           |
| Redux state       | `src/store/slices/`                                |

**Common imports:**

```typescript
import { Box, Button, Typography } from "@mui/material";
import { PageHeader, StatCard } from "../../shared/components";
import { useGetItemsQuery } from "../../store/services/api";
import { useAppDispatch, useAppSelector } from "../../store";
import { useNavigate, useLocation, NavLink } from "react-router-dom";
```

**React Router patterns:**

```typescript
// Navigate programmatically
const navigate = useNavigate();
navigate("/dashboard");

// Check current route
const location = useLocation();
const isActive = location.pathname === "/dashboard";

// Link component
<NavLink to="/dashboard">Dashboard</NavLink>;
```

**For detailed routing info, see:** `docs/REACT-ROUTER-MIGRATION.md`
