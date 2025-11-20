import React, { useState } from 'react';
import { Box, Typography, Paper, Select, MenuItem, FormControl, SelectChangeEvent } from '@mui/material';
import {
  Language as DomainIcon,
  Security as CertIcon,
  Hub as ASNIcon,
  Public as IPIcon,
  ContactMail as ContactIcon,
  CalendarToday as CalendarIcon,
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
  const [dateRange, setDateRange] = useState<string>('30');

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

  const handleDateRangeChange = (event: SelectChangeEvent<string>) => {
    setDateRange(event.target.value);
  };

  // Mock data - this would come from your API
  const assetData: AssetData[] = [
    { icon: <DomainIcon />, title: 'Domains', value: '4.7K', lastDays: parseInt(dateRange), change: 16 },
    { icon: <CertIcon />, title: 'SSL/TLS Certificates', value: '6.6K', lastDays: parseInt(dateRange), change: 546 },
    { icon: <ASNIcon />, title: 'ASNs', value: '15', lastDays: parseInt(dateRange), change: 0 },
    { icon: <IPIcon />, title: 'IP Addresses', value: '119.9K', lastDays: parseInt(dateRange), change: 103 },
    { icon: <ContactIcon />, title: 'Contacts', value: '152', lastDays: parseInt(dateRange), change: 7 },
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
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
            <Typography variant="body2" sx={{ fontWeight: 500, color: 'text.secondary' }}>
              Time Range:
            </Typography>
            <FormControl size="small" sx={{ minWidth: 120 }}>
              <Select
                value={dateRange}
                onChange={handleDateRangeChange}
                sx={{
                  fontSize: '0.875rem',
                  '& .MuiOutlinedInput-notchedOutline': {
                    borderColor: '#e0e0e0',
                  },
                  '&:hover .MuiOutlinedInput-notchedOutline': {
                    borderColor: '#0078d4',
                  },
                }}
              >
                <MenuItem value="7">Last 7 Days</MenuItem>
                <MenuItem value="14">Last 14 Days</MenuItem>
                <MenuItem value="30">Last 30 Days</MenuItem>
                <MenuItem value="60">Last 60 Days</MenuItem>
                <MenuItem value="90">Last 90 Days</MenuItem>
              </Select>
            </FormControl>
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
