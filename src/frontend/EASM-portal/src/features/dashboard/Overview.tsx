import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Button,
  Popover,
  TextField,
  ButtonGroup
} from '@mui/material';
import {
  Language as DomainIcon,
  Security as CertIcon,
  Hub as ASNIcon,
  Public as IPIcon,
  ContactMail as ContactIcon,
  CalendarToday as CalendarIcon,
  DateRange as DateRangeIcon,
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
      <Paper sx={{ p: 2, mb: 3 }}>
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
          Assets
        </Typography>

        <Box
          sx={{
            display: 'flex',
            gap: 2,
            overflowX: 'auto',
            pb: 2,
            '&::-webkit-scrollbar': {
              height: 8,
            },
            '&::-webkit-scrollbar-track': {
              backgroundColor: '#f1f1f1',
              borderRadius: 4,
            },
            '&::-webkit-scrollbar-thumb': {
              backgroundColor: '#888',
              borderRadius: 4,
              '&:hover': {
                backgroundColor: '#555',
              },
            },
          }}
        >
          {assetData.map((asset, index) => (
            <Box key={index} sx={{ flexShrink: 0 }}>
              <StatCard {...asset} />
            </Box>
          ))}
        </Box>
      </Paper>

      {/* Attack Surface Insights Section */}
      <Paper sx={{ p: 2 }}>
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
          Attack surface insights
        </Typography>

        <Box
          sx={{
            display: 'flex',
            gap: 3,
            overflowX: 'auto',
            pb: 2,
            '&::-webkit-scrollbar': {
              height: 8,
            },
            '&::-webkit-scrollbar-track': {
              backgroundColor: '#f1f1f1',
              borderRadius: 4,
            },
            '&::-webkit-scrollbar-thumb': {
              backgroundColor: '#888',
              borderRadius: 4,
              '&:hover': {
                backgroundColor: '#555',
              },
            },
          }}
        >
          {insightsData.map((insight, index) => (
            <Box key={index} sx={{ flexShrink: 0 }}>
              <InsightCard {...insight} />
            </Box>
          ))}
        </Box>
      </Paper>
    </Box>
  );
};

export default Overview;
