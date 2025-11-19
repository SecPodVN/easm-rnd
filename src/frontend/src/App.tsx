import React, { useState } from 'react';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import DashboardLayout from './components/DashboardLayout';
import { Overview } from './features/dashboard';
import { SeedManagement } from './features/discovery';
import { AssetInventory } from './features/inventory';
import { VulnerabilityManagement } from './features/vulnerabilities';
import { ReportBuilder } from './features/reports';
import theme from './theme';

function App() {
  const [currentPage, setCurrentPage] = useState('overview');

  const renderPage = () => {
    switch (currentPage) {
      case 'overview':
        return <Overview />;
      case 'discovery':
        return <SeedManagement />;
      case 'inventory':
        return <AssetInventory />;
      case 'vulnerabilities':
        return <VulnerabilityManagement />;
      case 'reports':
        return <ReportBuilder />;
      default:
        return <Overview />;
    }
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <DashboardLayout onNavigate={setCurrentPage} currentPage={currentPage}>
        {renderPage()}
      </DashboardLayout>
    </ThemeProvider>
  );
}

export default App;
