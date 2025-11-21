import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
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
} from '@mui/material';
import {
  Language as DomainIcon,
  Security as CertIcon,
  Hub as ASNIcon,
  Public as IPIcon,
  ContactMail as ContactIcon,
  CalendarToday as CalendarIcon,
  DateRange as DateRangeIcon,
  TrendingUp as TrendingUpIcon,
  Error as ErrorIcon,
  Warning as WarningIcon,
  Info as InfoIcon,
  CheckCircle as CheckCircleIcon,
} from '@mui/icons-material';
import { StatCard, InsightCard } from '../../shared/components';

interface AssetData {
  icon: React.ReactNode;
  title: string;
  value: string;
  lastDays: number;
  change: number;
}

interface Insight {
  name: string;
  count: string;
}

interface InsightData {
  title: string;
  value: string;
  color: string;
  description: string;
  insightsCount: string;
  insights: Insight[];
}

const Overview: React.FC = () => {
  // Date filter state
  const [dateRange, setDateRange] = useState<number>(30);
  const [customDateAnchor, setCustomDateAnchor] = useState<HTMLButtonElement | null>(null);
  const [startDate, setStartDate] = useState<string>('');
  const [endDate, setEndDate] = useState<string>('');
  const [isCustomRange, setIsCustomRange] = useState<boolean>(false);

  // Get current date and format it
  const currentDate = new Date();
  const formattedCurrentDate = currentDate.toLocaleString('en-US', {
    month: '2-digit',
    day: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
    timeZoneName: 'short'
  });

  // Hardcoded last scan time (for now)
  const lastScanDate = new Date(currentDate.getTime() - 2 * 60 * 60 * 1000); // 2 hours ago
  const formattedLastScan = lastScanDate.toLocaleString('en-US', {
    month: '2-digit',
    day: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
    timeZoneName: 'short'
  });

  const handleQuickRangeClick = (days: number) => {
    setDateRange(days);
    setIsCustomRange(false);
    setStartDate('');
    setEndDate('');
  };

  const handleCustomDateClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    setCustomDateAnchor(event.currentTarget);
  };

  const handleCustomDateClose = () => {
    setCustomDateAnchor(null);
  };

  const handleApplyCustomRange = () => {
    if (startDate && endDate) {
      const start = new Date(startDate);
      const end = new Date(endDate);
      const diffTime = Math.abs(end.getTime() - start.getTime());
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      setDateRange(diffDays);
      setIsCustomRange(true);
      handleCustomDateClose();
    }
  };

  const customDateOpen = Boolean(customDateAnchor);

  const getDateRangeLabel = () => {
    if (isCustomRange && startDate && endDate) {
      return `${new Date(startDate).toLocaleDateString()} - ${new Date(endDate).toLocaleDateString()}`;
    }
    return `Last ${dateRange} Days`;
  };

  // Mock data - this would come from your API
  const assetData: AssetData[] = [
    { icon: <DomainIcon />, title: 'Domains', value: '4.7K', lastDays: dateRange, change: 16 },
    { icon: <CertIcon />, title: 'SSL/TLS Certificates', value: '6.6K', lastDays: dateRange, change: 546 },
    { icon: <ASNIcon />, title: 'ASNs', value: '15', lastDays: dateRange, change: 0 },
    { icon: <IPIcon />, title: 'IP Addresses', value: '119.9K', lastDays: dateRange, change: 103 },
    { icon: <ContactIcon />, title: 'Contacts', value: '152', lastDays: dateRange, change: 7 },
  ];

  const insightsData: InsightData[] = [
    {
      title: 'High',
      value: '68',
      color: '#d13438',
      description: 'High priority observations',
      insightsCount: '8 of 121 insights',
      insights: [
        { name: 'CVE-2023-21709 - Microsoft Exchange Server Elevation of Privilege', count: '16' },
        { name: 'CVE-2023-28310 & CVE-2023-32031 - Microsoft Exchange Server A...', count: '16' },
        { name: 'CVE-2023-21529 - Microsoft Exchange Server Authenticated Remote...', count: '8' },
        { name: 'CVE-2022-41082 & CVE-2022-41040 - Microsoft Exchange Server A...', count: '8' },
        { name: 'CVE-2020-9490 - Push Diary Crash on Specifically Crafted HTTP/2 H...', count: '8' },
      ],
    },
    {
      title: 'Medium',
      value: '5K',
      color: '#ff8c00',
      description: 'Medium priority observations',
      insightsCount: '26 of 144 insights',
      insights: [
        { name: 'Hosts with Expired SSL Certificates', count: '2K' },
        { name: '[Potential] CVE-2020-3452 Cisco Adaptive Security Appliance and F...', count: '1K' },
        { name: '[Potential] CVE-2022-20699 Cisco ASA VPN Unauthenticated R...', count: '283' },
        { name: '[Potential] CVE-2023-27518 Citrix NetScaler ADC and Gateway Un...', count: '282' },
        { name: '[Potential] CVE-2023-3519 - Citrix NetScaler ADC and Gateway Un...', count: '282' },
      ],
    },
    {
      title: 'Low',
      value: '13K',
      color: '#ffc107',
      description: 'Low priority observations',
      insightsCount: '9 of 16 insights',
      insights: [
        { name: 'Deprecated Tech - OpenSSL', count: '6K' },
        { name: 'Deprecated Tech - jQuery', count: '3K' },
        { name: 'Expired SSL Certificates', count: '3K' },
        { name: 'Expired Domains', count: '57' },
        { name: 'Deprecated Tech - Nginx', count: '36' },
      ],
    },
  ];

  return (
    <Box>
      {/* Header with Date Info and Filter */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h5" sx={{ fontWeight: 600, mb: 2 }}>
          Essentials
        </Typography>

        {/* Current Date and Last Scan */}
        <Box sx={{ display: 'flex', gap: 3, mb: 2, alignItems: 'center' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <CalendarIcon sx={{ fontSize: 18, color: 'text.secondary' }} />
            <Typography variant="body2" color="text.secondary">
              Current: {formattedCurrentDate}
            </Typography>
          </Box>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <CalendarIcon sx={{ fontSize: 18, color: 'text.secondary' }} />
            <Typography variant="body2" color="text.secondary">
              Last Scan: {formattedLastScan}
            </Typography>
          </Box>
        </Box>

        {/* Actions and Date Filter */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
          <Box sx={{ display: 'flex', gap: 1, alignItems: 'center', flexWrap: 'wrap' }}>
            <Typography variant="body2" sx={{ fontWeight: 500, color: 'text.secondary', mr: 1 }}>
              Time Range:
            </Typography>

            {/* Quick Date Range Buttons */}
            <ButtonGroup variant="outlined" size="small">
              <Button
                onClick={() => handleQuickRangeClick(7)}
                variant={dateRange === 7 && !isCustomRange ? 'contained' : 'outlined'}
                sx={{
                  textTransform: 'none',
                  fontSize: '0.813rem',
                  minWidth: '60px',
                }}
              >
                7d
              </Button>
              <Button
                onClick={() => handleQuickRangeClick(14)}
                variant={dateRange === 14 && !isCustomRange ? 'contained' : 'outlined'}
                sx={{
                  textTransform: 'none',
                  fontSize: '0.813rem',
                  minWidth: '60px',
                }}
              >
                14d
              </Button>
              <Button
                onClick={() => handleQuickRangeClick(30)}
                variant={dateRange === 30 && !isCustomRange ? 'contained' : 'outlined'}
                sx={{
                  textTransform: 'none',
                  fontSize: '0.813rem',
                  minWidth: '60px',
                }}
              >
                30d
              </Button>
              <Button
                onClick={() => handleQuickRangeClick(60)}
                variant={dateRange === 60 && !isCustomRange ? 'contained' : 'outlined'}
                sx={{
                  textTransform: 'none',
                  fontSize: '0.813rem',
                  minWidth: '60px',
                }}
              >
                60d
              </Button>
            </ButtonGroup>

            {/* Custom Date Range Button */}
            <Button
              onClick={handleCustomDateClick}
              variant={isCustomRange ? 'contained' : 'outlined'}
              size="small"
              startIcon={<DateRangeIcon />}
              sx={{
                textTransform: 'none',
                fontSize: '0.813rem',
                ml: 1,
              }}
            >
              Custom
            </Button>

            {/* Custom Date Range Popover */}
            <Popover
              open={customDateOpen}
              anchorEl={customDateAnchor}
              onClose={handleCustomDateClose}
              anchorOrigin={{
                vertical: 'bottom',
                horizontal: 'left',
              }}
              transformOrigin={{
                vertical: 'top',
                horizontal: 'left',
              }}
            >
              <Box sx={{ p: 2, minWidth: 300 }}>
                <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 600 }}>
                  Select Custom Date Range
                </Typography>
                <TextField
                  label="Start Date"
                  type="date"
                  value={startDate}
                  onChange={(e) => setStartDate(e.target.value)}
                  fullWidth
                  size="small"
                  InputLabelProps={{ shrink: true }}
                  sx={{ mb: 2 }}
                />
                <TextField
                  label="End Date"
                  type="date"
                  value={endDate}
                  onChange={(e) => setEndDate(e.target.value)}
                  fullWidth
                  size="small"
                  InputLabelProps={{ shrink: true }}
                  sx={{ mb: 2 }}
                />
                <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end' }}>
                  <Button
                    onClick={handleCustomDateClose}
                    size="small"
                    sx={{ textTransform: 'none' }}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={handleApplyCustomRange}
                    variant="contained"
                    size="small"
                    disabled={!startDate || !endDate}
                    sx={{ textTransform: 'none' }}
                  >
                    Apply
                  </Button>
                </Box>
              </Box>
            </Popover>

            {/* Display current range */}
            {isCustomRange && (
              <Typography variant="caption" sx={{ color: 'text.secondary', ml: 1 }}>
                ({getDateRangeLabel()})
              </Typography>
            )}
          </Box>

          <Box sx={{ display: 'flex', gap: 2 }}>
            <Typography
              variant="body2"
              sx={{
                color: '#0078d4',
                cursor: 'pointer',
                '&:hover': { textDecoration: 'underline' },
              }}
            >
              View Cost
            </Typography>
            <Typography
              variant="body2"
              sx={{
                color: '#0078d4',
                cursor: 'pointer',
                '&:hover': { textDecoration: 'underline' },
              }}
            >
              JSON View
            </Typography>
          </Box>
        </Box>
      </Box>

      {/* Assets Section */}
      <Box
        sx={{
          display: 'grid',
          gridTemplateColumns: {
            xs: '1fr',
            sm: 'repeat(2, 1fr)',
            md: 'repeat(3, 1fr)',
            lg: 'repeat(4, 1fr)',
          },
          gap: 2,
          mb: 3,
        }}
      >
        {/* Total Assets Widget */}
        <Card>
          <CardContent>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Total Assets
            </Typography>
            <Typography variant="h3" sx={{ fontWeight: 600, color: '#0078d4', mb: 1 }}>
              131.5K
            </Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <TrendingUpIcon sx={{ fontSize: 16, color: '#107c10' }} />
              <Typography variant="caption" sx={{ color: '#107c10' }}>
                +1,243 ({dateRange}d)
              </Typography>
            </Box>
          </CardContent>
        </Card>

        {/* Total Issues Widget */}
        <Card>
          <CardContent>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Total Issues
            </Typography>
            <Typography variant="h3" sx={{ fontWeight: 600, color: '#d13438', mb: 1 }}>
              18.1K
            </Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <TrendingUpIcon sx={{ fontSize: 16, color: '#d13438' }} />
              <Typography variant="caption" sx={{ color: '#d13438' }}>
                +356 ({dateRange}d)
              </Typography>
            </Box>
          </CardContent>
        </Card>

        {/* Scoring Widget */}
        <Card>
          <CardContent>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Security Score
            </Typography>
            <Typography variant="h3" sx={{ fontWeight: 600, color: '#ff8c00', mb: 1 }}>
              72/100
            </Typography>
            <Typography variant="caption" color="text.secondary">
              SecPod's Rules
            </Typography>
          </CardContent>
        </Card>

        {/* New Assets Widget */}
        <Card>
          <CardContent>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              New Assets
            </Typography>
            <Typography variant="h3" sx={{ fontWeight: 600, color: '#0078d4', mb: 1 }}>
              243
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Last {dateRange} days
            </Typography>
          </CardContent>
        </Card>
      </Box>

      {/* Top Issues and New Items Row */}
      <Box
        sx={{
          display: 'grid',
          gridTemplateColumns: { xs: '1fr', lg: 'repeat(2, 1fr)' },
          gap: 2,
          mb: 3,
        }}
      >
        {/* Top N Issues Widget */}
        <Card sx={{ height: '100%' }}>
          <CardContent>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
              Top Issues to Resolve
            </Typography>
            <List dense>
              <ListItem sx={{ px: 0 }}>
                <ErrorIcon sx={{ color: '#d13438', mr: 1, fontSize: 20 }} />
                <ListItemText
                  primary="CVE-2023-21709 - Microsoft Exchange Server"
                  secondary="16 assets affected"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Chip label="High" size="small" sx={{ bgcolor: '#d13438', color: 'white' }} />
              </ListItem>
              <Divider />
              <ListItem sx={{ px: 0 }}>
                <ErrorIcon sx={{ color: '#d13438', mr: 1, fontSize: 20 }} />
                <ListItemText
                  primary="CVE-2023-28310 & CVE-2023-32031 - Exchange"
                  secondary="16 assets affected"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Chip label="High" size="small" sx={{ bgcolor: '#d13438', color: 'white' }} />
              </ListItem>
              <Divider />
              <ListItem sx={{ px: 0 }}>
                <WarningIcon sx={{ color: '#ff8c00', mr: 1, fontSize: 20 }} />
                <ListItemText
                  primary="Hosts with Expired SSL Certificates"
                  secondary="2.1K assets affected"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Chip label="Medium" size="small" sx={{ bgcolor: '#ff8c00', color: 'white' }} />
              </ListItem>
              <Divider />
              <ListItem sx={{ px: 0 }}>
                <InfoIcon sx={{ color: '#ffc107', mr: 1, fontSize: 20 }} />
                <ListItemText
                  primary="Deprecated Tech - OpenSSL"
                  secondary="6.2K assets affected"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Chip label="Low" size="small" sx={{ bgcolor: '#ffc107', color: 'white' }} />
              </ListItem>
            </List>
          </CardContent>
        </Card>

        {/* New Items Panel */}
        <Card sx={{ height: '100%' }}>
          <CardContent>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
              New Items (Last {dateRange}d)
            </Typography>
            <Box
              sx={{
                display: 'grid',
                gridTemplateColumns: 'repeat(2, 1fr)',
                gap: 2,
              }}
            >
              {/* New Assets breakdown */}
              <Box>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Assets
                </Typography>
                <Box sx={{ mb: 1 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Domains</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>+16</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">IPs</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>+103</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2">Certificates</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>+546</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Typography variant="body2">Contacts</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600 }}>+7</Typography>
                  </Box>
                </Box>
              </Box>

              {/* New Issues breakdown */}
              <Box>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Issues
                </Typography>
                <Box sx={{ mb: 1 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2" sx={{ color: '#d13438' }}>High</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600, color: '#d13438' }}>+12</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2" sx={{ color: '#ff8c00' }}>Medium</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600, color: '#ff8c00' }}>+89</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="body2" sx={{ color: '#ffc107' }}>Low</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600, color: '#ffc107' }}>+255</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Typography variant="body2" sx={{ color: '#107c10' }}>Info</Typography>
                    <Typography variant="body2" sx={{ fontWeight: 600, color: '#107c10' }}>+87</Typography>
                  </Box>
                </Box>
              </Box>
            </Box>
          </CardContent>
        </Card>
      </Box>

      {/* Map View Widget */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
            Geographic Distribution
          </Typography>
          <Box
            sx={{
              height: 300,
              bgcolor: '#f5f5f5',
              borderRadius: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Typography variant="body2" color="text.secondary">
              Map visualization will be displayed here
            </Typography>
          </Box>
        </CardContent>
      </Card>

      {/* Summary by Types */}
      <Box
        sx={{
          display: 'grid',
          gridTemplateColumns: { xs: '1fr', md: 'repeat(3, 1fr)' },
          gap: 2,
        }}
      >
        {/* Assets Summary */}
        <Card>
          <CardContent>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
              Assets by Type
            </Typography>
            <List dense>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <DomainIcon sx={{ fontSize: 18, mr: 1, color: 'text.secondary' }} />
                <ListItemText
                  primary="Domains"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>4.7K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <IPIcon sx={{ fontSize: 18, mr: 1, color: 'text.secondary' }} />
                <ListItemText
                  primary="IP Addresses"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>119.9K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <CertIcon sx={{ fontSize: 18, mr: 1, color: 'text.secondary' }} />
                <ListItemText
                  primary="Certificates"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>6.6K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <ASNIcon sx={{ fontSize: 18, mr: 1, color: 'text.secondary' }} />
                <ListItemText
                  primary="ASNs"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>15</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <ContactIcon sx={{ fontSize: 18, mr: 1, color: 'text.secondary' }} />
                <ListItemText
                  primary="Contacts"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>152</Typography>
              </ListItem>
            </List>
          </CardContent>
        </Card>

        {/* Issues Summary */}
        <Card>
          <CardContent>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
              Issues by Severity
            </Typography>
            <List dense>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <ErrorIcon sx={{ fontSize: 18, mr: 1, color: '#d13438' }} />
                <ListItemText
                  primary="High"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600, color: '#d13438' }}>68</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <WarningIcon sx={{ fontSize: 18, mr: 1, color: '#ff8c00' }} />
                <ListItemText
                  primary="Medium"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600, color: '#ff8c00' }}>5.1K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <InfoIcon sx={{ fontSize: 18, mr: 1, color: '#ffc107' }} />
                <ListItemText
                  primary="Low"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600, color: '#ffc107' }}>13K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <CheckCircleIcon sx={{ fontSize: 18, mr: 1, color: '#107c10' }} />
                <ListItemText
                  primary="Info"
                  primaryTypographyProps={{ variant: 'body2' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600, color: '#107c10' }}>2.3K</Typography>
              </ListItem>
            </List>
          </CardContent>
        </Card>

        {/* Vulnerability Summary */}
        <Card>
          <CardContent>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
              Top Vulnerabilities
            </Typography>
            <List dense>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <ListItemText
                  primary="CVE-2023-*"
                  secondary="Current year vulnerabilities"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>1.2K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <ListItemText
                  primary="CVE-2022-*"
                  secondary="Last year vulnerabilities"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>3.4K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <ListItemText
                  primary="Expired Certs"
                  secondary="Certificate issues"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>5.1K</Typography>
              </ListItem>
              <ListItem sx={{ px: 0, py: 0.5 }}>
                <ListItemText
                  primary="Deprecated Tech"
                  secondary="Old software versions"
                  primaryTypographyProps={{ variant: 'body2' }}
                  secondaryTypographyProps={{ variant: 'caption' }}
                />
                <Typography variant="body2" sx={{ fontWeight: 600 }}>9.3K</Typography>
              </ListItem>
            </List>
          </CardContent>
        </Card>
      </Box>
    </Box>
  );
};

export default Overview;
