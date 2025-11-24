# React Router Migration Guide

**Date: November 24, 2025**

---

## 🎯 Overview

This document outlines the migration from state-based navigation to **React Router v7** for proper routing with URL support, browser navigation, and deep linking.

---

## 📦 Updated Dependencies

### Core Changes

```json
{
  "@reduxjs/toolkit": "^2.5.0", // Updated from 2.0.1
  "@testing-library/jest-dom": "^6.6.3", // Updated from 6.9.1
  "@testing-library/user-event": "^14.5.2", // Updated from 13.5.0
  "@types/jest": "^29.5.14", // Updated from 29.5.12
  "@types/node": "^22.10.2", // Updated from 20.11.19
  "react-redux": "^9.2.0", // Updated from 9.0.4
  "react-router-dom": "^7.1.1", // ✨ NEW - React Router v7
  "typescript": "^5.7.2", // Updated from 4.9.5
  "web-vitals": "^4.2.4" // Updated from 2.1.4
}
```

All dependencies are now compatible with **React 19.2.0**.

---

## 🔄 Migration Changes

### 1. **Route Configuration** (`src/routes/index.tsx`)

Created centralized route configuration:

```typescript
export const routes: RouteObject[] = [
  { path: "/", element: <Navigate to="/dashboard" replace /> },
  { path: "/dashboard", element: <Overview /> },
  { path: "/discovery/seeds", element: <SeedManagement /> },
  { path: "/assets", element: <AssetInventory /> },
  { path: "/vulnerabilities", element: <VulnerabilityManagement /> },
  { path: "/reports", element: <ReportBuilder /> },
  { path: "/jobs", element: <JobManagement /> },
  { path: "/settings", element: <Settings /> },
  { path: "*", element: <NotFound /> }, // 404 page
];
```

### 2. **App.tsx** - Router Integration

**Before (State-based):**

```typescript
const [currentPage, setCurrentPage] = useState("overview");

const renderPage = () => {
  switch (currentPage) {
    case "overview":
      return <Overview />;
    // ...more cases
  }
};

return (
  <DashboardLayout onNavigate={setCurrentPage} currentPage={currentPage}>
    {renderPage()}
  </DashboardLayout>
);
```

**After (React Router):**

```typescript
const AppRoutes: React.FC = () => {
  const routing = useRoutes(routes);
  return routing;
};

return (
  <Provider store={store}>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <BrowserRouter>
        <DashboardLayout>
          <AppRoutes />
        </DashboardLayout>
      </BrowserRouter>
    </ThemeProvider>
  </Provider>
);
```

### 3. **DashboardLayout.tsx** - Navigation Links

**Before (onClick handlers):**

```typescript
<ListItemButton
  selected={currentPage === 'overview'}
  onClick={() => handleNavigation('overview')}
>
```

**After (NavLink components):**

```typescript
<ListItemButton
  component={NavLink}
  to="/dashboard"
  selected={isActive('/dashboard')}
>
```

**Key Changes:**

- Added `useLocation()` hook to track current route
- Removed `onNavigate` and `currentPage` props
- Replaced all `onClick` handlers with `NavLink` components
- Added `isActive()` helper function:
  ```typescript
  const location = useLocation();
  const isActive = (path: string) => location.pathname === path;
  ```

### 4. **Jobs Feature** - Proper Component

Created `src/features/jobs/JobManagement.tsx` to replace inline JSX:

```typescript
export const JobManagement: React.FC = () => {
  return (
    <Box sx={{ p: 3 }}>
      <PageHeader title="Job Management" />
      <Paper>
        <JobIcon sx={{ fontSize: 64 }} />
        <Typography variant="h5">Coming Soon</Typography>
      </Paper>
    </Box>
  );
};
```

---

## 🚀 New Features

### 1. **URL-Based Navigation**

- Each page now has its own URL
- Users can bookmark specific pages
- Shareable links work correctly

**Routes:**

```
/                    → Redirects to /dashboard
/dashboard           → Overview
/discovery/seeds     → Seed Configuration
/assets              → Asset Inventory
/vulnerabilities     → Vulnerability Management
/reports             → Report Builder
/jobs                → Job Management
/settings            → Settings
/*                   → 404 Not Found
```

### 2. **Browser Navigation**

- Browser back/forward buttons work correctly
- URL bar reflects current page
- Refresh maintains current page

### 3. **404 Page**

Custom not found page with:

- Clear error message
- "Go to Dashboard" button
- "Go Back" button

### 4. **Deep Linking**

Users can directly access any page via URL:

```
http://localhost:3000/vulnerabilities
http://localhost:3000/assets
```

---

## 🧪 Testing the Migration

### Start Development Server

```bash
cd src/frontend/easm-web-portal
npm start
```

### Test Checklist

- [ ] Navigate through all menu items
- [ ] Browser back/forward buttons work
- [ ] Refresh page maintains current view
- [ ] Direct URL access works (e.g., `/vulnerabilities`)
- [ ] 404 page shows for invalid URLs
- [ ] Active menu item is highlighted
- [ ] Sidebar collapse/expand works
- [ ] Mobile drawer navigation works

---

## 📝 Code Patterns

### Navigate Programmatically

```typescript
import { useNavigate } from "react-router-dom";

const MyComponent = () => {
  const navigate = useNavigate();

  const handleClick = () => {
    navigate("/dashboard");
  };
};
```

### Check Current Route

```typescript
import { useLocation } from "react-router-dom";

const MyComponent = () => {
  const location = useLocation();
  const isActive = location.pathname === "/dashboard";
};
```

### Link with Styling

```typescript
import { NavLink } from "react-router-dom";

<NavLink
  to="/dashboard"
  style={({ isActive }) => ({
    color: isActive ? "blue" : "black",
  })}
>
  Dashboard
</NavLink>;
```

### Protected Routes (Future)

```typescript
const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const isAuthenticated = useAuth();
  return isAuthenticated ? children : <Navigate to="/login" />;
};

// In routes
{
  path: '/dashboard',
  element: <ProtectedRoute><Overview /></ProtectedRoute>
}
```

---

## ⚠️ Breaking Changes

### For Developers

1. **No more `onNavigate` prop**

   - Use `useNavigate()` hook instead

2. **No more `currentPage` state**

   - Use `useLocation()` hook instead

3. **URL structure changed**
   - `seed-config` → `/discovery/seeds`
   - `asset-list` → `/assets`

### Migration Steps for New Features

When adding new pages:

1. **Create component** in `src/features/`
2. **Add route** to `src/routes/index.tsx`
3. **Add navigation link** to `src/components/DashboardLayout.tsx` using `NavLink`

**Example:**

```typescript
// 1. Add to routes/index.tsx
{
  path: '/compliance',
  element: <CompliancePage />
}

// 2. Add to DashboardLayout.tsx
<ListItemButton
  component={NavLink}
  to="/compliance"
  selected={isActive('/compliance')}
>
  <ListItemIcon><AssessmentIcon /></ListItemIcon>
  <ListItemText primary="Compliance" />
</ListItemButton>
```

---

## 🔧 Troubleshooting

### Issue: "Cannot find module 'react-router-dom'"

**Solution:** Install dependencies

```bash
npm install
```

### Issue: Page doesn't load on refresh

**Solution:** Configure server to redirect all requests to `index.html`

For **nginx** (production):

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

For **development server**: Already configured in `react-scripts`

### Issue: Active state not working

**Solution:** Ensure you're using exact paths

```typescript
const isActive = location.pathname === "/dashboard"; // ✓ Exact match
const isActive = location.pathname.includes("/dash"); // ✗ May match multiple
```

---

## 📚 Resources

- [React Router v7 Docs](https://reactrouter.com/)
- [Migration from v6 to v7](https://reactrouter.com/upgrading/v6)
- [TypeScript Support](https://reactrouter.com/start/library/installation#typescript)

---

## ✅ Verification

Run these commands to verify everything works:

```bash
# Install dependencies
npm install

# Start dev server
npm start

# Build for production
npm run build

# Run tests
npm test
```

---

## 🎉 Benefits

✅ **SEO-friendly** - Each page has unique URL
✅ **Better UX** - Browser navigation works
✅ **Shareable** - Users can share links to specific pages
✅ **Deep linking** - Direct access to any page
✅ **Type-safe** - Full TypeScript support
✅ **Future-proof** - Ready for authentication, lazy loading, etc.

---

## Next Steps

1. ✅ React Router migration - **COMPLETE**
2. 🔄 Connect to Django backend API
3. 🔐 Add authentication/login flow
4. 📱 Add lazy loading for better performance
5. 🎨 Add route transitions/animations

---

**Migration completed successfully! 🚀**
