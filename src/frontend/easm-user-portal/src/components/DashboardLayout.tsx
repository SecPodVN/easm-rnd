import { useState } from "react";
import { useLocation, NavLink } from "react-router-dom";
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
} from "@mui/material";
import {
  Menu as MenuIcon,
  Dashboard as DashboardIcon,
  Inventory as InventoryIcon,
  Assessment as AssessmentIcon,
  BugReport as VulnIcon,
  Tune as ConfigIcon,
  Description as ReportIcon,
  Settings as SettingsIcon,
  Notifications as NotificationIcon,
  WorkOutline as JobIcon,
  ListAlt as ListIcon,
  HelpOutline as HelpIcon,
  ExpandLess,
  ExpandMore,
  PriorityHigh as PriorityIcon,
  ChevronLeft as ChevronLeftIcon,
  ChevronRight as ChevronRightIcon,
} from "@mui/icons-material";

const drawerWidth = 240;
const collapsedDrawerWidth = 72;

interface DashboardLayoutProps {
  children: React.ReactNode;
}

const DashboardLayout = ({ children }: DashboardLayoutProps) => {
  const location = useLocation();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const [openAssets, setOpenAssets] = useState(true);
  const [openSecurity, setOpenSecurity] = useState(false);
  const [openJobs, setOpenJobs] = useState(false);
  const [openReports, setOpenReports] = useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  // Helper function to check if a path is active
  const isActive = (path: string) => location.pathname === path;

  const drawer = (
    <div>
      <Toolbar
        sx={{
          bgcolor: "#1976d2",
          color: "white",
          py: 2,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            flex: 1,
            justifyContent: collapsed ? "center" : "center",
          }}
        >
          {collapsed ? (
            <Box
              component="img"
              src="/SecPod-Icon.svg"
              alt="SecPod"
              sx={{ height: 32, width: 32, objectFit: "contain" }}
            />
          ) : (
            <Box
              component="img"
              src="/SecPod-Logo-Full-Light-Background.png"
              alt="SecPod Logo"
              sx={{ height: 40, width: "auto", maxWidth: "90%", objectFit: "contain" }}
            />
          )}
        </Box>
        <IconButton
          onClick={() => setCollapsed(!collapsed)}
          sx={{
            color: "white",
            position: "absolute",
            right: 8,
            "&:hover": { bgcolor: "rgba(255, 255, 255, 0.1)" },
          }}
          size="small"
        >
          {collapsed ? <ChevronRightIcon /> : <ChevronLeftIcon />}
        </IconButton>
      </Toolbar>

      {/* Main Dashboard */}
      <List sx={{ pt: 2 }}>
        <ListItem disablePadding>
          <ListItemButton
            component={NavLink}
            to="/dashboard"
            selected={isActive("/dashboard")}
            sx={{ justifyContent: collapsed ? "center" : "flex-start" }}
          >
            <ListItemIcon sx={{ minWidth: collapsed ? "unset" : 36, justifyContent: "center" }}>
              <DashboardIcon color={isActive("/dashboard") ? "primary" : "inherit"} />
            </ListItemIcon>
            {!collapsed && <ListItemText primary="Overview" />}
          </ListItemButton>
        </ListItem>
      </List>

      <Divider sx={{ my: 1 }} />

      {/* Assets Section */}
      <List dense>
        <ListItemButton
          onClick={() => setOpenAssets(!openAssets)}
          sx={{ justifyContent: collapsed ? "center" : "flex-start" }}
        >
          {collapsed ? (
            <ListItemIcon sx={{ minWidth: "unset", justifyContent: "center" }}>
              <InventoryIcon fontSize="small" />
            </ListItemIcon>
          ) : (
            <>
              <ListItemText
                primary="ASSETS"
                primaryTypographyProps={{
                  variant: "caption",
                  sx: { fontWeight: 600, color: "text.secondary", textTransform: "uppercase" },
                }}
              />
              {openAssets ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
            </>
          )}
        </ListItemButton>
        <Collapse in={openAssets && !collapsed} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            <ListItemButton
              component={NavLink}
              to="/discovery/seeds"
              sx={{ pl: 3 }}
              selected={isActive("/discovery/seeds")}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <ConfigIcon />
              </ListItemIcon>
              <ListItemText
                primary="Seed Configuration"
                primaryTypographyProps={{ variant: "body2" }}
              />
            </ListItemButton>
            <ListItemButton
              component={NavLink}
              to="/assets"
              sx={{ pl: 3 }}
              selected={isActive("/assets")}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <InventoryIcon />
              </ListItemIcon>
              <ListItemText primary="Asset List" primaryTypographyProps={{ variant: "body2" }} />
            </ListItemButton>
          </List>
        </Collapse>
      </List>

      {/* Security & Risk Section */}
      <List dense>
        <ListItemButton
          onClick={() => setOpenSecurity(!openSecurity)}
          sx={{ justifyContent: collapsed ? "center" : "flex-start" }}
        >
          {collapsed ? (
            <ListItemIcon sx={{ minWidth: "unset", justifyContent: "center" }}>
              <VulnIcon fontSize="small" />
            </ListItemIcon>
          ) : (
            <>
              <ListItemText
                primary="SECURITY & RISK"
                primaryTypographyProps={{
                  variant: "caption",
                  sx: { fontWeight: 600, color: "text.secondary", textTransform: "uppercase" },
                }}
              />
              {openSecurity ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
            </>
          )}
        </ListItemButton>
        <Collapse in={openSecurity && !collapsed} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            <ListItemButton
              component={NavLink}
              to="/vulnerabilities"
              sx={{ pl: 3 }}
              selected={isActive("/vulnerabilities")}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <VulnIcon />
              </ListItemIcon>
              <ListItemText
                primary="Vulnerabilities"
                primaryTypographyProps={{ variant: "body2" }}
              />
            </ListItemButton>
            <ListItemButton sx={{ pl: 3 }}>
              <ListItemIcon sx={{ minWidth: 36 }}>
                <PriorityIcon />
              </ListItemIcon>
              <ListItemText
                primary="Risk Prioritization"
                primaryTypographyProps={{ variant: "body2" }}
              />
            </ListItemButton>
            <ListItemButton sx={{ pl: 3 }}>
              <ListItemIcon sx={{ minWidth: 36 }}>
                <NotificationIcon />
              </ListItemIcon>
              <ListItemText
                primary="Alerts & Monitoring"
                primaryTypographyProps={{ variant: "body2" }}
              />
            </ListItemButton>
          </List>
        </Collapse>
      </List>

      {/* Job Management Section */}
      <List dense>
        <ListItemButton
          onClick={() => setOpenJobs(!openJobs)}
          sx={{ justifyContent: collapsed ? "center" : "flex-start" }}
        >
          {collapsed ? (
            <ListItemIcon sx={{ minWidth: "unset", justifyContent: "center" }}>
              <JobIcon fontSize="small" />
            </ListItemIcon>
          ) : (
            <>
              <ListItemText
                primary="JOB MANAGEMENT"
                primaryTypographyProps={{
                  variant: "caption",
                  sx: { fontWeight: 600, color: "text.secondary", textTransform: "uppercase" },
                }}
              />
              {openJobs ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
            </>
          )}
        </ListItemButton>
        <Collapse in={openJobs && !collapsed} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            <ListItemButton
              component={NavLink}
              to="/jobs"
              sx={{ pl: 3 }}
              selected={isActive("/jobs")}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <ListIcon />
              </ListItemIcon>
              <ListItemText
                primary="List & Actions"
                primaryTypographyProps={{ variant: "body2" }}
              />
            </ListItemButton>
          </List>
        </Collapse>
      </List>

      {/* Reports & Compliance */}
      <List dense>
        <ListItemButton
          onClick={() => setOpenReports(!openReports)}
          sx={{ justifyContent: collapsed ? "center" : "flex-start" }}
        >
          {collapsed ? (
            <ListItemIcon sx={{ minWidth: "unset", justifyContent: "center" }}>
              <ReportIcon fontSize="small" />
            </ListItemIcon>
          ) : (
            <>
              <ListItemText
                primary="REPORTS & COMPLIANCE"
                primaryTypographyProps={{
                  variant: "caption",
                  sx: { fontWeight: 600, color: "text.secondary", textTransform: "uppercase" },
                }}
              />
              {openReports ? <ExpandLess fontSize="small" /> : <ExpandMore fontSize="small" />}
            </>
          )}
        </ListItemButton>
        <Collapse in={openReports && !collapsed} timeout="auto" unmountOnExit>
          <List component="div" disablePadding dense>
            <ListItemButton
              component={NavLink}
              to="/reports"
              sx={{ pl: 3 }}
              selected={isActive("/reports")}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>
                <ReportIcon />
              </ListItemIcon>
              <ListItemText
                primary="Report Builder"
                primaryTypographyProps={{ variant: "body2" }}
              />
            </ListItemButton>
            <ListItemButton sx={{ pl: 3 }}>
              <ListItemIcon sx={{ minWidth: 36 }}>
                <AssessmentIcon />
              </ListItemIcon>
              <ListItemText primary="Compliance" primaryTypographyProps={{ variant: "body2" }} />
            </ListItemButton>
          </List>
        </Collapse>
      </List>

      <Divider sx={{ my: 1 }} />

      {/* Settings */}
      <List dense>
        <ListItem disablePadding>
          <ListItemButton
            component={NavLink}
            to="/settings"
            selected={isActive("/settings")}
            sx={{ justifyContent: collapsed ? "center" : "flex-start" }}
          >
            <ListItemIcon sx={{ minWidth: collapsed ? "unset" : 36, justifyContent: "center" }}>
              <SettingsIcon />
            </ListItemIcon>
            {!collapsed && <ListItemText primary="Settings" />}
          </ListItemButton>
        </ListItem>
      </List>

      {/* Help & Support - Fixed at bottom */}
      <Box
        sx={{
          position: "absolute",
          bottom: 0,
          width: "100%",
          borderTop: 1,
          borderColor: "divider",
          bgcolor: "background.paper",
        }}
      >
        <List dense>
          <ListItem disablePadding>
            <ListItemButton sx={{ justifyContent: collapsed ? "center" : "flex-start" }}>
              <ListItemIcon sx={{ minWidth: collapsed ? "unset" : 36, justifyContent: "center" }}>
                <HelpIcon />
              </ListItemIcon>
              {!collapsed && <ListItemText primary="Help & Support" />}
            </ListItemButton>
          </ListItem>
        </List>
      </Box>
    </div>
  );

  return (
    <Box sx={{ display: "flex" }}>
      <AppBar
        position="fixed"
        elevation={0}
        sx={{
          width: { sm: `calc(100% - ${collapsed ? collapsedDrawerWidth : drawerWidth}px)` },
          ml: { sm: `${collapsed ? collapsedDrawerWidth : drawerWidth}px` },
          bgcolor: "background.paper",
          color: "text.primary",
          borderBottom: "1px solid",
          borderColor: "divider",
          transition: "width 0.2s, margin-left 0.2s",
        }}
      >
        <Toolbar sx={{ minHeight: 64 }}>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: "none" } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography
            variant="h6"
            noWrap
            component="div"
            sx={{ color: "text.primary", fontWeight: 600 }}
          >
            EASM Platform
          </Typography>
        </Toolbar>
      </AppBar>
      <Box
        component="nav"
        sx={{
          width: { sm: collapsed ? collapsedDrawerWidth : drawerWidth },
          flexShrink: { sm: 0 },
          transition: "width 0.2s",
        }}
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true,
          }}
          sx={{
            display: { xs: "block", sm: "none" },
            "& .MuiDrawer-paper": { boxSizing: "border-box", width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: "none", sm: "block" },
            "& .MuiDrawer-paper": {
              boxSizing: "border-box",
              width: collapsed ? collapsedDrawerWidth : drawerWidth,
              transition: "width 0.2s",
              overflowX: "hidden",
            },
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
          width: { sm: `calc(100% - ${collapsed ? collapsedDrawerWidth : drawerWidth}px)` },
          bgcolor: "background.default",
          minHeight: "100vh",
          transition: "width 0.2s",
        }}
      >
        <Toolbar />
        {children}
      </Box>
    </Box>
  );
};

export default DashboardLayout;
