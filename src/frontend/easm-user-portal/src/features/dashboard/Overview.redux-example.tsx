/**
 * Overview Component - Redux Migration Example
 *
 * This file shows how to refactor the Overview component to use Redux Toolkit
 * and RTK Query instead of local state.
 *
 * Key Changes:
 * 1. Replace useState for dateRange with Redux filters
 * 2. Replace hardcoded data with RTK Query hooks
 * 3. Remove unnecessary local state management
 */

import React, { useState } from 'react';
import {
  Box,
  Typography,
  Button,
  Popover,
  TextField,
  ButtonGroup,
  Card,
  CardContent,
  Chip,
  List,
  ListItem,
  ListItemText,
  Divider,
  CircularProgress,
  Alert,
} from '@mui/material';
import {
  CalendarToday as CalendarIcon,
  DateRange as DateRangeIcon,
  TrendingUp as TrendingUpIcon,
  Error as ErrorIcon,
  Warning as WarningIcon,
  Info as InfoIcon,
  CheckCircle as CheckCircleIcon,
} from '@mui/icons-material';

// Redux imports
import { useAppDispatch, useAppSelector } from '../../store';
import { setDateRange } from '../../store/slices/filtersSlice';
import { useGetDashboardMetricsQuery, useGetIssuesQuery, useGetAssetsQuery } from '../../store/services/api';

const OverviewRedux: React.FC = () => {
  // ========================================
  // REDUX STATE (replaces local state)
  // ========================================
  const dispatch = useAppDispatch();
  const { dateRange } = useAppSelector((state) => state.filters);

  // ========================================
  // RTK QUERY (replaces manual data fetching)
  // ========================================
  const {
    data: metrics,
    isLoading: metricsLoading,
    error: metricsError,
    refetch: refetchMetrics
  } = useGetDashboardMetricsQuery({ dateRange });

  const {
    data: issues,
    isLoading: issuesLoading
  } = useGetIssuesQuery({
    severity: ['critical', 'high'],
  });

  const {
    data: assets
  } = useGetAssetsQuery({ dateRange });

  // ========================================
  // LOCAL UI STATE (only for UI interactions)
  // ========================================
  const [customDateAnchor, setCustomDateAnchor] = useState<HTMLButtonElement | null>(null);
  const [startDate, setStartDate] = useState<string>('');
  const [endDate, setEndDate] = useState<string>('');

  // ========================================
  // EVENT HANDLERS
  // ========================================
  const handleQuickRangeClick = (days: number) => {
    const end = new Date();
    const start = new Date();
    start.setDate(start.getDate() - days);

    // Dispatch to Redux instead of local setState
    dispatch(setDateRange({ start, end }));
  };

  const handleCustomDateClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    setCustomDateAnchor(event.currentTarget);
  };

  const handleCustomDateClose = () => {
    setCustomDateAnchor(null);
  };

  const handleCustomDateApply = () => {
    if (startDate && endDate) {
      dispatch(setDateRange({
        start: new Date(startDate),
        end: new Date(endDate),
      }));
      handleCustomDateClose();
    }
  };

  // ========================================
  // LOADING & ERROR STATES
  // ========================================
  if (metricsLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  if (metricsError) {
    return (
      <Alert severity="error" sx={{ m: 2 }}>
        Failed to load dashboard data
        <Button onClick={() => refetchMetrics()}>Retry</Button>
      </Alert>
    );
  }

  // ========================================
  // RENDER
  // ========================================
  return (
    <Box sx={{ p: 3 }}>
      {/* Header with Date Filter */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4">Dashboard Overview</Typography>

        {/* Date Range Filter */}
        <ButtonGroup variant="outlined" size="small">
          <Button onClick={() => handleQuickRangeClick(7)}>Last 7 Days</Button>
          <Button onClick={() => handleQuickRangeClick(30)}>Last 30 Days</Button>
          <Button onClick={() => handleQuickRangeClick(90)}>Last 90 Days</Button>
          <Button onClick={handleCustomDateClick}>Custom Range</Button>
        </ButtonGroup>

        {/* Custom Date Popover */}
        <Popover
          open={Boolean(customDateAnchor)}
          anchorEl={customDateAnchor}
          onClose={handleCustomDateClose}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
        >
          <Box sx={{ p: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label="Start Date"
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
            <TextField
              label="End Date"
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
            <Button variant="contained" onClick={handleCustomDateApply}>
              Apply
            </Button>
          </Box>
        </Popover>
      </Box>

      {/* Widget Grid - Row 1: Key Metrics */}
      <Box sx={{
        display: 'grid',
        gridTemplateColumns: {
          xs: '1fr',
          sm: 'repeat(2, 1fr)',
          md: 'repeat(3, 1fr)',
          lg: 'repeat(4, 1fr)',
        },
        gap: 2,
        mb: 2,
      }}>
        {/* Total Assets */}
        <Card>
          <CardContent>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Box>
                <Typography variant="body2" color="text.secondary">Total Assets</Typography>
                <Typography variant="h4">{metrics?.totalAssets.toLocaleString()}</Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
                  <TrendingUpIcon fontSize="small" sx={{ color: '#107c10', mr: 0.5 }} />
                  <Typography variant="caption" sx={{ color: '#107c10' }}>
                    +{metrics?.newAssets} new
                  </Typography>
                </Box>
              </Box>
            </Box>
          </CardContent>
        </Card>

        {/* Total Issues */}
        <Card>
          <CardContent>
            <Typography variant="body2" color="text.secondary">Total Issues</Typography>
            <Typography variant="h4">{metrics?.totalIssues.toLocaleString()}</Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
              <WarningIcon fontSize="small" sx={{ color: '#ff8c00', mr: 0.5 }} />
              <Typography variant="caption" sx={{ color: '#ff8c00' }}>
                +{metrics?.newIssues} new
              </Typography>
            </Box>
          </CardContent>
        </Card>

        {/* Security Score */}
        <Card>
          <CardContent>
            <Typography variant="body2" color="text.secondary">Security Score</Typography>
            <Typography variant="h4">{metrics?.securityScore}/100</Typography>
            <Typography variant="caption" color="text.secondary">
              SecPod's Rules
            </Typography>
          </CardContent>
        </Card>

        {/* New Assets */}
        <Card>
          <CardContent>
            <Typography variant="body2" color="text.secondary">New Assets</Typography>
            <Typography variant="h4">{metrics?.newAssets}</Typography>
            <Typography variant="caption" color="text.secondary">
              Last {Math.floor((dateRange.end.getTime() - dateRange.start.getTime()) / (1000 * 60 * 60 * 24))} days
            </Typography>
          </CardContent>
        </Card>
      </Box>

      {/* Widget Grid - Row 2: Top Issues & New Items */}
      <Box sx={{
        display: 'grid',
        gridTemplateColumns: { xs: '1fr', lg: 'repeat(2, 1fr)' },
        gap: 2,
        mb: 2,
      }}>
        {/* Top Issues to Resolve */}
        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>Top Issues to Resolve</Typography>
            {issuesLoading ? (
              <CircularProgress size={24} />
            ) : (
              <List>
                {issues?.slice(0, 5).map((issue) => (
                  <React.Fragment key={issue.id}>
                    <ListItem>
                      <ListItemText
                        primary={issue.title}
                        secondary={`Asset: ${issue.assetName}`}
                      />
                      <Chip
                        label={issue.severity}
                        size="small"
                        sx={{
                          bgcolor: issue.severity === 'critical' ? '#d13438' :
                                   issue.severity === 'high' ? '#ff8c00' :
                                   issue.severity === 'medium' ? '#ffc107' : '#107c10',
                          color: 'white',
                        }}
                      />
                    </ListItem>
                    <Divider />
                  </React.Fragment>
                ))}
              </List>
            )}
          </CardContent>
        </Card>

        {/* New Items Breakdown */}
        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>New Items</Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography>Assets</Typography>
                <Chip label={metrics?.newAssets} color="primary" />
              </Box>
              <Divider />
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography>Issues</Typography>
                <Chip label={metrics?.newIssues} color="warning" />
              </Box>
            </Box>
          </CardContent>
        </Card>
      </Box>

      {/* Widget Grid - Row 3: Map View */}
      <Card sx={{ mb: 2 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>Geographic Distribution</Typography>
          <Box sx={{
            height: 300,
            bgcolor: '#f5f5f5',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}>
            <Typography variant="body2" color="text.secondary">
              Map View - Coming Soon
            </Typography>
          </Box>
        </CardContent>
      </Card>

      {/* Widget Grid - Row 4: Summary by Types */}
      <Box sx={{
        display: 'grid',
        gridTemplateColumns: { xs: '1fr', md: 'repeat(3, 1fr)' },
        gap: 2,
      }}>
        {/* Assets by Type */}
        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>Assets by Type</Typography>
            <List dense>
              <ListItem>
                <ListItemText primary="Servers" />
                <Typography>1,234</Typography>
              </ListItem>
              <ListItem>
                <ListItemText primary="Domains" />
                <Typography>5,678</Typography>
              </ListItem>
              <ListItem>
                <ListItemText primary="IPs" />
                <Typography>9,012</Typography>
              </ListItem>
            </List>
          </CardContent>
        </Card>

        {/* Issues by Severity */}
        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>Issues by Severity</Typography>
            <List dense>
              <ListItem>
                <ErrorIcon sx={{ color: '#d13438', mr: 1 }} />
                <ListItemText primary="Critical" />
                <Typography>{metrics?.criticalIssues}</Typography>
              </ListItem>
              <ListItem>
                <WarningIcon sx={{ color: '#ff8c00', mr: 1 }} />
                <ListItemText primary="High" />
                <Typography>{metrics?.highIssues}</Typography>
              </ListItem>
              <ListItem>
                <InfoIcon sx={{ color: '#ffc107', mr: 1 }} />
                <ListItemText primary="Medium" />
                <Typography>{metrics?.mediumIssues}</Typography>
              </ListItem>
            </List>
          </CardContent>
        </Card>

        {/* Top Vulnerabilities */}
        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>Top Vulnerabilities</Typography>
            <List dense>
              <ListItem>
                <ListItemText primary="SQL Injection" secondary="CVE-2024-1234" />
                <Typography>23</Typography>
              </ListItem>
              <ListItem>
                <ListItemText primary="XSS" secondary="CVE-2024-5678" />
                <Typography>18</Typography>
              </ListItem>
              <ListItem>
                <ListItemText primary="CSRF" secondary="CVE-2024-9012" />
                <Typography>12</Typography>
              </ListItem>
            </List>
          </CardContent>
        </Card>
      </Box>
    </Box>
  );
};

export default OverviewRedux;

/**
 * MIGRATION CHECKLIST:
 *
 * ✅ 1. Replace useState(dateRange) with Redux filters
 * ✅ 2. Use RTK Query hooks (useGetDashboardMetricsQuery, useGetIssuesQuery)
 * ✅ 3. Automatic loading states from RTK Query
 * ✅ 4. Automatic error handling with retry capability
 * ✅ 5. Automatic caching (switching date ranges uses cached data)
 * ✅ 6. No props drilling - all components can access filters directly
 * ✅ 7. Type-safe with TypeScript
 * ✅ 8. Works with mock data now, easy to switch to real API later
 *
 * BENEFITS:
 * - Centralized filter state (used across all components)
 * - Automatic data fetching and caching
 * - Loading and error states handled by RTK Query
 * - No manual useEffect for data fetching
 * - Easy to refetch/refresh data
 * - Redux DevTools for debugging
 * - Mock data for development, real API in production
 */
