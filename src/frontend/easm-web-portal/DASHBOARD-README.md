# EASM Dashboard

External Attack Surface Management (EASM) Dashboard inspired by Microsoft Defender EASM.

## Features

### 🎨 UI Components
- **Dashboard Layout** - Sidebar navigation with collapsible sections
- **Asset Summary Cards** - Display 8 key asset types:
  - Domains
  - Hosts
  - Pages
  - SSL Certificates
  - ASNs (Autonomous System Numbers)
  - IP Blocks
  - IP Addresses
  - Contacts

### 🔍 Attack Surface Insights
- **High Priority Observations** - Critical security findings (68 observations)
- **Medium Priority Observations** - Important security concerns (5K observations)
- **Low Priority Observations** - Maintenance and deprecated tech (13K observations)

### 📊 Data Visualization
- Metric cards with trend indicators
- Priority-coded observation cards
- Top observations lists with counts
- Time-stamped data views

## Technologies Used

- **React 19** - Frontend framework
- **Material-UI (MUI)** - Component library
- **Emotion** - CSS-in-JS styling
- **Recharts** - Data visualization (ready for future charts)

## Project Structure

```
src/
├── components/
│   ├── DashboardLayout.js    # Main layout with sidebar
│   ├── Overview.js            # Main dashboard view
│   ├── StatCard.js            # Asset metric cards
│   └── InsightCard.js         # Security insight cards
├── theme.js                   # MUI theme configuration
└── App.js                     # Main app component
```

## Getting Started

### Installation
```bash
cd src/frontend
npm install
```

### Development
```bash
npm start
```

The app will open at [http://localhost:3000](http://localhost:3000)

### Build for Production
```bash
npm run build
```

## Customization

### Adding New Asset Types
Edit `Overview.js` and add to the `assetData` array:
```javascript
{ icon: <YourIcon />, title: 'Asset Name', value: '123', lastDays: 30, change: 5 }
```

### Modifying Insights
Update the `insightsData` array in `Overview.js` with your data source.

### Theme Customization
Edit `theme.js` to change colors, fonts, and component styles.

## API Integration

To connect to your backend API:

1. Create an API service file in `src/services/api.js`
2. Replace mock data in `Overview.js` with API calls
3. Add loading states and error handling

Example:
```javascript
import { useEffect, useState } from 'react';

const Overview = () => {
  const [assetData, setAssetData] = useState([]);

  useEffect(() => {
    fetch('/api/assets')
      .then(res => res.json())
      .then(data => setAssetData(data));
  }, []);

  // ... rest of component
};
```

## Future Enhancements

- [ ] Connect to backend API
- [ ] Add real-time data updates
- [ ] Implement detailed asset views
- [ ] Add filtering and search
- [ ] Export functionality
- [ ] Custom dashboards
- [ ] User authentication
- [ ] Role-based access control

## Design Inspiration

This dashboard is inspired by Microsoft Defender EASM, featuring:
- Azure-style blue theme
- Clean, professional layout
- Hierarchical navigation
- Priority-coded security findings
- Comprehensive asset tracking

## License

Part of the EASM-RND project.
