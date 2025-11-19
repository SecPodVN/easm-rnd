import React, { useState } from 'react';
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  List,
  Typography,
  Divider,
  IconButton,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Collapse,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Dashboard as DashboardIcon,
  Inventory as InventoryIcon,
  Security as SecurityIcon,
  Assessment as AssessmentIcon,
  BugReport as VulnIcon,
  Search as DiscoveryIcon,
  Description as ReportIcon,
  Settings as SettingsIcon,
  Notifications as NotificationIcon,
  ExpandLess,
  ExpandMore,
} from '@mui/icons-material';

const drawerWidth = 240;

interface DashboardLayoutProps {
  children: React.ReactNode;
  onNavigate?: (page: string) => void;
  currentPage?: string;
}

const DashboardLayout: React.FC<DashboardLayoutProps> = ({
  children,
  onNavigate,
  currentPage: externalCurrentPage
}) => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [openAssets, setOpenAssets] = useState(true);
  const [openSecurity, setOpenSecurity] = useState(false);
  const [openReports, setOpenReports] = useState(false);
  const [internalCurrentPage, setInternalCurrentPage] = useState('overview');

  const currentPage = externalCurrentPage || internalCurrentPage;

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleNavigation = (page: string) => {
    if (onNavigate) {
      onNavigate(page);
    } else {
      setInternalCurrentPage(page);
    }
  };

  const drawer = (
    <div>
      <Toolbar sx={{ bgcolor: '#17C825', color: 'white' }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <SecurityIcon />
          <Box>
            <Typography variant="subtitle1" sx={{ fontWeight: 600, lineHeight: 1.2 }}>
              EASM Platform
            </Typography>
            <Typography variant="caption" sx={{ opacity: 0.9 }}>
              SecPod Saner EASM
            </Typography>
          </Box>
        </Box>
      </Toolbar>

      {/* Main Dashboard */}
      <List sx={{ pt: 2 }}>
        <ListItem disablePadding>
          <ListItemButton
            selected={currentPage === 'overview'}
            onClick={() => handleNavigation('overview')}
          >
            <ListItemIcon>
              <DashboardIcon color={currentPage === 'overview' ? 'primary' : 'inherit'} />
            </ListItemIcon>
            <ListItemText primary="Overview" />
          </ListItemButton>
        </ListItem>
      </List>

      <Divider sx={{ my: 1 }} />

      {/* Discovery Section */}
      <List dense>
        <ListItemButton onClick={() => setOpenAssets(!openAssets)}>
          <ListItemText
            primary="Discovery & Assets"
            primaryTypographyProps={{
              variant: 'caption',
              sx: { fontWeight: 600, color: 'text.secondary', textTransform: 'uppercase' }
            }}
          />
          {openAssets ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
        </ListItemButton>
        <Collapse in={openAssets} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            <ListItemButton
              sx={{ pl: 3 }}
              selected={currentPage === 'discovery'}
              onClick={() => handleNavigation('discovery')}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <DiscoveryIcon />
              </ListItemIcon>
              <ListItemText
                primary="Discovery Seeds"
                primaryTypographyProps={{ variant: 'body2' }}
              />
            </ListItemButton>
            <ListItemButton
              sx={{ pl: 3 }}
              selected={currentPage === 'inventory'}
              onClick={() => handleNavigation('inventory')}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <InventoryIcon />
              </ListItemIcon>
              <ListItemText
                primary="Asset Inventory"
                primaryTypographyProps={{ variant: 'body2' }}
              />
            </ListItemButton>
          </List>
        </Collapse>
      </List>

      {/* Security Section */}
      <List dense>
        <ListItemButton onClick={() => setOpenSecurity(!openSecurity)}>
          <ListItemText
            primary="Security & Risk"
            primaryTypographyProps={{
              variant: 'caption',
              sx: { fontWeight: 600, color: 'text.secondary', textTransform: 'uppercase' }
            }}
          />
          {openSecurity ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
        </ListItemButton>
        <Collapse in={openSecurity} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            <ListItemButton
              sx={{ pl: 3 }}
              selected={currentPage === 'vulnerabilities'}
              onClick={() => handleNavigation('vulnerabilities')}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <VulnIcon />
              </ListItemIcon>
              <ListItemText
                primary="Vulnerabilities"
                primaryTypographyProps={{ variant: 'body2' }}
              />
            </ListItemButton>
            <ListItemButton sx={{ pl: 3 }}>
              <ListItemIcon sx={{ minWidth: 36 }}>
                <SecurityIcon />
              </ListItemIcon>
              <ListItemText
                primary="Risk Scoring"
                primaryTypographyProps={{ variant: 'body2' }}
              />
            </ListItemButton>
            <ListItemButton sx={{ pl: 3 }}>
              <ListItemIcon sx={{ minWidth: 36 }}>
                <NotificationIcon />
              </ListItemIcon>
              <ListItemText
                primary="Alerts & Monitoring"
                primaryTypographyProps={{ variant: 'body2' }}
              />
            </ListItemButton>
          </List>
        </Collapse>
      </List>

      {/* Reports & Compliance */}
      <List dense>
        <ListItemButton onClick={() => setOpenReports(!openReports)}>
          <ListItemText
            primary="Reports & Compliance"
            primaryTypographyProps={{
              variant: 'caption',
              sx: { fontWeight: 600, color: 'text.secondary', textTransform: 'uppercase' }
            }}
          />
          {openReports ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
        </ListItemButton>
        <Collapse in={openReports} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            <ListItemButton
              sx={{ pl: 3 }}
              selected={currentPage === 'reports'}
              onClick={() => handleNavigation('reports')}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <ReportIcon />
              </ListItemIcon>
              <ListItemText
                primary="Report Builder"
                primaryTypographyProps={{ variant: 'body2' }}
              />
            </ListItemButton>
            <ListItemButton sx={{ pl: 3 }}>
              <ListItemIcon sx={{ minWidth: 36 }}>
                <AssessmentIcon />
              </ListItemIcon>
              <ListItemText
                primary="Compliance"
                primaryTypographyProps={{ variant: 'body2' }}
              />
            </ListItemButton>
          </List>
        </Collapse>
      </List>

      <Divider sx={{ my: 1 }} />

      {/* Settings */}
      <List dense>
        <ListItem disablePadding>
          <ListItemButton
            selected={currentPage === 'settings'}
            onClick={() => handleNavigation('settings')}
          >
            <ListItemIcon>
              <SettingsIcon />
            </ListItemIcon>
            <ListItemText primary="Settings" />
          </ListItemButton>
        </ListItem>
      </List>
    </div>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar
        position="fixed"
        sx={{
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          ml: { sm: `${drawerWidth}px` },
          bgcolor: 'white',
          color: 'text.primary',
          boxShadow: '0 1px 3px rgba(0,0,0,0.12)',
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" noWrap component="div" sx={{ color: 'text.primary' }}>
            Dashboard (Preview)
          </Typography>
        </Toolbar>
      </AppBar>
      <Box
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true,
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          bgcolor: '#f5f5f5',
          minHeight: '100vh',
        }}
      >
        <Toolbar />
        {children}
      </Box>
    </Box>
  );
};

export default DashboardLayout;
