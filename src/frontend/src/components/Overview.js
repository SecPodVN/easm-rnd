import React from 'react';
import { Box, Typography, Paper } from '@mui/material';
import {
  Language as DomainIcon,
  DnsOutlined as HostIcon,
  Description as PageIcon,
  Security as SSLIcon,
  Hub as ASNIcon,
  Block as IPBlockIcon,
  Public as IPAddressIcon,
  Contacts as ContactIcon,
} from '@mui/icons-material';
import StatCard from './StatCard';
import InsightCard from './InsightCard';

const Overview = () => {
  // Mock data - this would come from your API
  const assetData = [
    { icon: <DomainIcon />, title: 'Domains', value: '4.7K', lastDays: 30, change: 16 },
    { icon: <HostIcon />, title: 'Hosts', value: '26.9K', lastDays: 30, change: -2.8 },
    { icon: <PageIcon />, title: 'Pages', value: '256.2K', lastDays: 30, change: 13.2 },
    { icon: <SSLIcon />, title: 'SSL certificates', value: '6.6K', lastDays: 30, change: 546 },
    { icon: <ASNIcon />, title: 'ASNs', value: '15', lastDays: 30, change: 0 },
    { icon: <IPBlockIcon />, title: 'IP blocks', value: '260', lastDays: 30, change: 3 },
    { icon: <IPAddressIcon />, title: 'IP addresses', value: '119.9K', lastDays: 30, change: 103 },
    { icon: <ContactIcon />, title: 'Contacts', value: '152', lastDays: 30, change: 7 },
  ];

  const insightsData = [
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
      {/* Header */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h5" sx={{ fontWeight: 600, mb: 1 }}>
          Essentials
        </Typography>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="body2" color="text.secondary">
            100/27/2025, 10:02:24 AM CDT
          </Typography>
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
        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
          10/27/2025, 10:02:24 AM CDT
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
        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
          10/26/2025, 5:39:41 AM CDT
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
