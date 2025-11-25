import { RouteObject, Navigate } from "react-router-dom";
import { Overview } from "../features/dashboard";
import { SeedManagement } from "../features/discovery";
import { AssetInventory } from "../features/inventory";
import { VulnerabilityManagement } from "../features/vulnerabilities";
import { ReportBuilder } from "../features/reports";
import { JobManagement } from "../features/jobs";
import { Settings } from "../features/settings";
import { Box, Typography, Button, Paper } from "@mui/material";
import { Home as HomeIcon, ArrowBack } from "@mui/icons-material";
import { Link } from "react-router-dom";

// 404 Not Found Component
const NotFound = () => {
  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "60vh",
        p: 3,
      }}
    >
      <Paper
        elevation={0}
        sx={{
          p: 6,
          textAlign: "center",
          maxWidth: 500,
          bgcolor: "background.paper",
          borderRadius: 2,
        }}
      >
        <Typography
          variant="h1"
          sx={{
            fontSize: "6rem",
            fontWeight: 700,
            color: "primary.main",
            mb: 2,
          }}
        >
          404
        </Typography>
        <Typography variant="h5" gutterBottom>
          Page Not Found
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
          The page you're looking for doesn't exist or has been moved.
        </Typography>
        <Box sx={{ display: "flex", gap: 2, justifyContent: "center" }}>
          <Button component={Link} to="/" variant="contained" startIcon={<HomeIcon />} size="large">
            Go to Dashboard
          </Button>
          <Button
            onClick={() => window.history.back()}
            variant="outlined"
            startIcon={<ArrowBack />}
            size="large"
          >
            Go Back
          </Button>
        </Box>
      </Paper>
    </Box>
  );
};

// Route configuration
export const routes: RouteObject[] = [
  {
    path: "/",
    element: <Navigate to="/dashboard" replace />,
  },
  {
    path: "/dashboard",
    element: <Overview />,
  },
  {
    path: "/discovery/seeds",
    element: <SeedManagement />,
  },
  {
    path: "/assets",
    element: <AssetInventory />,
  },
  {
    path: "/vulnerabilities",
    element: <VulnerabilityManagement />,
  },
  {
    path: "/reports",
    element: <ReportBuilder />,
  },
  {
    path: "/jobs",
    element: <JobManagement />,
  },
  {
    path: "/settings",
    element: <Settings />,
  },
  {
    path: "*",
    element: <NotFound />,
  },
];

export default routes;
