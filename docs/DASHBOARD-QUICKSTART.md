# EASM Dashboard - Quick Start Guide

## 🎯 What You Have Now

A fully functional External Attack Surface Management (EASM) dashboard inspired by Microsoft Defender EASM, complete with:

### ✨ Features Implemented

#### 1. **Professional Layout**
- Azure-branded header bar
- Collapsible sidebar navigation
- Responsive design (desktop, tablet, mobile)
- Microsoft Defender EASM styling

#### 2. **Asset Management Dashboard**
Display 8 key asset types with metrics:
- 📌 **Domains**: 4.7K assets
- 🌐 **Hosts**: 26.9K assets
- 📄 **Pages**: 256.2K assets
- 🔒 **SSL Certificates**: 6.6K assets
- 🔗 **ASNs**: 15 assets
- 🚫 **IP Blocks**: 260 assets
- 🌍 **IP Addresses**: 119.9K assets
- 👥 **Contacts**: 152 assets

Each card shows:
- Current count
- 30-day trend (up/down indicator)
- Change amount with color coding

#### 3. **Security Insights**
Three priority levels with detailed observations:
- 🔴 **High Priority**: 68 critical findings
- 🟠 **Medium Priority**: 5K important issues
- 🟡 **Low Priority**: 13K maintenance items

Each insight card includes:
- Priority badge with count
- Top 5 observations
- Links to detailed views
- Insight count summaries

## 🚀 Running the Dashboard

### Start Development Server
```bash
cd src/frontend
npm start
```

The dashboard will automatically open at:
**http://localhost:3000**

### Build for Production
```bash
cd src/frontend
npm run build
```

## 📂 Project Structure

```
src/frontend/
├── src/
│   ├── components/
│   │   ├── DashboardLayout.js    # Main layout with sidebar
│   │   ├── Overview.js            # Dashboard main view
│   │   ├── StatCard.js            # Asset metric cards
│   │   ├── InsightCard.js         # Security insight cards
│   │   └── index.js               # Component exports
│   ├── theme.js                   # MUI theme (Azure colors)
│   ├── App.js                     # Main app component
│   └── index.js                   # React entry point
├── public/
│   └── index.html
├── package.json
└── DASHBOARD-README.md
```

## 🎨 Visual Components

### Sidebar Navigation
```
📊 Overview (Current)
├─ 📁 General
│  ├─ Inventory
│  └─ Inventory changes (Preview)
├─ 📈 Dashboards
│  ├─ Attack surface summary
│  ├─ Security posture
│  ├─ GDPR compliance
│  └─ OWASP Top 10
└─ ⚙️ Manage
   ├─ Discovery
   ├─ Labels
   ├─ Billable assets
   ├─ Data connections
   └─ Task manager
```

### Main Dashboard View
```
┌─────────────────────────────────────────────┐
│ Essentials                      View Cost ▾  │
│ Last updated: 9/27/2023                      │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Assets                                       │
├──────────┬──────────┬──────────┬───────────┤
│ Domains  │  Hosts   │  Pages   │    SSL    │
│  4.7K    │  26.9K   │ 256.2K   │   6.6K    │
│  ↑ 16    │  ↓ 2.8K  │ ↑ 13.2K  │  ↑ 546    │
├──────────┼──────────┼──────────┼───────────┤
│  ASNs    │ IP Blocks│ IP Addrs │ Contacts  │
│   15     │   260    │ 119.9K   │   152     │
│   → 0    │   ↑ 3    │  ↑ 103   │   ↑ 7     │
└──────────┴──────────┴──────────┴───────────┘

┌─────────────────────────────────────────────┐
│ Attack Surface Insights                      │
├───────────────┬───────────────┬─────────────┤
│ ⭕ High (68)  │ 🟠 Medium (5K)│🟡 Low (13K) │
│               │               │             │
│ Top CVEs:     │ Expired SSL   │ Deprecated  │
│ - CVE-2023... │ - Hosts: 2K   │ - OpenSSL   │
│ - CVE-2023... │ - Cisco: 1K   │ - jQuery    │
│ - CVE-2023... │ - NetScaler   │ - Domains   │
│               │               │             │
│ 8/121 insights│26/144 insights│9/16 insights│
└───────────────┴───────────────┴─────────────┘
```

## 🔧 Customization Quick Reference

### Change Primary Color
**File**: `src/theme.js`
```javascript
palette: {
  primary: {
    main: '#YourColorHere', // Change Azure blue
  },
}
```

### Update Asset Data
**File**: `src/components/Overview.js`
```javascript
const assetData = [
  {
    icon: <DomainIcon />,
    title: 'Domains',
    value: '4.7K',      // ← Update this
    lastDays: 30,
    change: 16          // ← And this
  },
  // ... more assets
];
```

### Modify Sidebar Menu
**File**: `src/components/DashboardLayout.js`
```javascript
const menuItems = {
  general: [
    { text: 'New Item', icon: <Icon />, active: false },
    // ... more items
  ],
};
```

## 🔗 Backend Integration

### Step 1: Create API Service
Create `src/services/api.js`:
```javascript
const API_BASE = 'http://localhost:8000/api';

export const fetchAssets = async () => {
  const response = await fetch(`${API_BASE}/assets`);
  return response.json();
};

export const fetchInsights = async () => {
  const response = await fetch(`${API_BASE}/insights`);
  return response.json();
};
```

### Step 2: Update Overview Component
```javascript
import { useEffect, useState } from 'react';
import { fetchAssets, fetchInsights } from '../services/api';

const Overview = () => {
  const [assetData, setAssetData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      try {
        const assets = await fetchAssets();
        setAssetData(assets);
      } catch (error) {
        console.error('Error loading data:', error);
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, []);

  if (loading) return <div>Loading...</div>;

  // ... rest of component
};
```

### Step 3: Expected API Response Format
```json
{
  "assets": [
    {
      "type": "domains",
      "icon": "Language",
      "title": "Domains",
      "value": "4.7K",
      "lastDays": 30,
      "change": 16
    }
  ],
  "insights": [
    {
      "priority": "high",
      "value": 68,
      "color": "#d13438",
      "observations": [
        {
          "name": "CVE-2023-21709...",
          "count": 16
        }
      ]
    }
  ]
}
```

## 📊 Mock Data Currently Used

The dashboard currently uses **mock data** for demonstration:
- Asset counts are hardcoded in `Overview.js`
- Insights are sample CVE and security findings
- All data is static (no live updates)

**To use real data**: Follow the Backend Integration steps above.

## 🎯 Key Features to Note

### ✅ Responsive Design
- Desktop: Full sidebar always visible
- Tablet: Sidebar can be toggled
- Mobile: Hamburger menu with drawer

### ✅ Material-UI Components
All components use MUI for:
- Consistent styling
- Accessibility (ARIA labels)
- Theme customization
- Responsive behavior

### ✅ Performance
- Lazy loading ready
- Optimized re-renders
- Efficient component structure
- Small bundle size

### ✅ Extensible
- Modular component design
- Reusable StatCard and InsightCard
- Easy to add new sections
- Theme-based styling

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Kill process on port 3000 (Windows)
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Module Not Found
```bash
cd src/frontend
npm install
```

### Build Errors
```bash
cd src/frontend
npm run build
# Check console for specific errors
```

## 📱 Browser Support

- ✅ Chrome (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Edge (latest)
- ⚠️ IE11 (not supported)

## 🎨 Color Palette

```
Primary (Azure Blue): #0078d4
High Priority (Red):  #d13438
Medium Priority (Orange): #ff8c00
Low Priority (Yellow): #ffc107
Success (Green): #107c10
Background: #f5f5f5
```

## 📚 Learn More

- [Material-UI Docs](https://mui.com/)
- [React Docs](https://react.dev/)
- [Recharts Docs](https://recharts.org/)
- [Microsoft Defender EASM](https://learn.microsoft.com/en-us/azure/external-attack-surface-management/)

## ✅ Checklist: Dashboard is Ready!

- [x] Layout with sidebar navigation
- [x] 8 asset type cards with metrics
- [x] 3 priority insight cards
- [x] Responsive design
- [x] Azure theme styling
- [x] Mock data for testing
- [x] Component documentation
- [ ] Backend API integration (next step)
- [ ] User authentication (future)
- [ ] Real-time updates (future)

---

**🎉 Your EASM Dashboard is ready to use!**

Start the server with `npm start` and open http://localhost:3000
