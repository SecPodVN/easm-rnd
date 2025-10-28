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
  TrendingUp as TrendingUpIcon,
  Label as LabelIcon,
  Storage as StorageIcon,
  Link as LinkIcon,
  Task as TaskIcon,
  ExpandLess,
  ExpandMore,
} from '@mui/icons-material';

const drawerWidth = 240;

const DashboardLayout = ({ children }) => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [openGeneral, setOpenGeneral] = useState(true);
  const [openDashboards, setOpenDashboards] = useState(true);
  const [openManage, setOpenManage] = useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const menuItems = {
    general: [
      { text: 'Inventory', icon: <InventoryIcon />, active: false },
      { text: 'Inventory changes (Preview)', icon: <InventoryIcon />, active: false },
    ],
    dashboards: [
      { text: 'Attack surface summary', icon: <SecurityIcon />, active: false },
      { text: 'Security posture', icon: <SecurityIcon />, active: false },
      { text: 'GDPR compliance', icon: <AssessmentIcon />, active: false },
      { text: 'OWASP Top 10', icon: <TrendingUpIcon />, active: false },
    ],
    manage: [
      { text: 'Discovery', icon: <TrendingUpIcon />, active: false },
      { text: 'Labels', icon: <LabelIcon />, active: false },
      { text: 'Billable assets', icon: <StorageIcon />, active: false },
      { text: 'Data connections', icon: <LinkIcon />, active: false },
      { text: 'Task manager', icon: <TaskIcon />, active: false },
    ],
  };

  const drawer = (
    <div>
      <Toolbar sx={{ bgcolor: '#17C825', color: 'white' }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <SecurityIcon />
          <Box>
            <Typography variant="subtitle1" sx={{ fontWeight: 600, lineHeight: 1.2 }}>
              EASM Resource
            </Typography>
            <Typography variant="caption" sx={{ opacity: 0.9 }}>
              SecPod Saner EASM
            </Typography>
          </Box>
        </Box>
      </Toolbar>

      <List sx={{ pt: 2 }}>
        <ListItem disablePadding>
          <ListItemButton selected>
            <ListItemIcon>
              <DashboardIcon color="primary" />
            </ListItemIcon>
            <ListItemText primary="Overview" />
          </ListItemButton>
        </ListItem>
      </List>

      <Divider sx={{ my: 1 }} />

      {/* General Section */}
      <List dense>
        <ListItemButton onClick={() => setOpenGeneral(!openGeneral)}>
          <ListItemText
            primary="General"
            primaryTypographyProps={{
              variant: 'caption',
              sx: { fontWeight: 600, color: 'text.secondary', textTransform: 'uppercase' }
            }}
          />
          {openGeneral ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
        </ListItemButton>
        <Collapse in={openGeneral} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            {menuItems.general.map((item) => (
              <ListItemButton key={item.text} sx={{ pl: 3 }}>
                <ListItemIcon sx={{ minWidth: 36 }}>
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={item.text}
                  primaryTypographyProps={{ variant: 'body2' }}
                />
              </ListItemButton>
            ))}
          </List>
        </Collapse>
      </List>

      {/* Dashboards Section */}
      <List dense>
        <ListItemButton onClick={() => setOpenDashboards(!openDashboards)}>
          <ListItemText
            primary="Dashboards"
            primaryTypographyProps={{
              variant: 'caption',
              sx: { fontWeight: 600, color: 'text.secondary', textTransform: 'uppercase' }
            }}
          />
          {openDashboards ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
        </ListItemButton>
        <Collapse in={openDashboards} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            {menuItems.dashboards.map((item) => (
              <ListItemButton key={item.text} sx={{ pl: 3 }}>
                <ListItemIcon sx={{ minWidth: 36 }}>
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={item.text}
                  primaryTypographyProps={{ variant: 'body2' }}
                />
              </ListItemButton>
            ))}
          </List>
        </Collapse>
      </List>

      {/* Manage Section */}
      <List dense>
        <ListItemButton onClick={() => setOpenManage(!openManage)}>
          <ListItemText
            primary="Manage"
            primaryTypographyProps={{
              variant: 'caption',
              sx: { fontWeight: 600, color: 'text.secondary', textTransform: 'uppercase' }
            }}
          />
          {openManage ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
        </ListItemButton>
        <Collapse in={openManage} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            {menuItems.manage.map((item) => (
              <ListItemButton key={item.text} sx={{ pl: 3 }}>
                <ListItemIcon sx={{ minWidth: 36 }}>
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={item.text}
                  primaryTypographyProps={{ variant: 'body2' }}
                />
              </ListItemButton>
            ))}
          </List>
        </Collapse>
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
