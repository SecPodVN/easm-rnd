import React, { useState } from 'react';
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  Menu,
  MenuItem,
  Select,
  FormControl,
  InputLabel,
  Button,
  Tabs,
  Tab,
} from '@mui/material';
import {
  MoreVert as MoreVertIcon,
  FilterList as FilterIcon,
  Download as DownloadIcon,
  Refresh as RefreshIcon,
  Language as DomainIcon,
  DnsOutlined as HostIcon,
  Public as IPIcon,
  Security as SSLIcon,
} from '@mui/icons-material';
import { PageHeader, SearchBar, EmptyState } from '../../shared/components';

interface Asset {
  id: string;
  type: 'domain' | 'host' | 'ip' | 'ssl';
  name: string;
  status: 'active' | 'inactive';
  riskLevel: 'critical' | 'high' | 'medium' | 'low';
  lastSeen: string;
  vulnerabilities: number;
}

const AssetInventory: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [assetType, setAssetType] = useState<string>('all');
  const [riskFilter, setRiskFilter] = useState<string>('all');
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [selectedAsset, setSelectedAsset] = useState<Asset | null>(null);
  const [currentTab, setCurrentTab] = useState(0);

  const mockAssets: Asset[] = [
    { id: '1', type: 'domain', name: 'example.com', status: 'active', riskLevel: 'high', lastSeen: '2025-11-19', vulnerabilities: 12 },
    { id: '2', type: 'host', name: 'api.example.com', status: 'active', riskLevel: 'critical', lastSeen: '2025-11-19', vulnerabilities: 24 },
    { id: '3', type: 'ip', name: '192.168.1.100', status: 'active', riskLevel: 'medium', lastSeen: '2025-11-18', vulnerabilities: 3 },
    { id: '4', type: 'ssl', name: '*.example.com', status: 'active', riskLevel: 'low', lastSeen: '2025-11-19', vulnerabilities: 1 },
  ];

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'domain': return <DomainIcon fontSize="small" />;
      case 'host': return <HostIcon fontSize="small" />;
      case 'ip': return <IPIcon fontSize="small" />;
      case 'ssl': return <SSLIcon fontSize="small" />;
      default: return null;
    }
  };

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case 'critical': return 'error';
      case 'high': return 'warning';
      case 'medium': return 'info';
      case 'low': return 'success';
      default: return 'default';
    }
  };

  const filteredAssets = mockAssets.filter(asset => {
    const matchesSearch = asset.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = assetType === 'all' || asset.type === assetType;
    const matchesRisk = riskFilter === 'all' || asset.riskLevel === riskFilter;
    return matchesSearch && matchesType && matchesRisk;
  });

  const assetCounts = {
    all: mockAssets.length,
    domain: mockAssets.filter(a => a.type === 'domain').length,
    host: mockAssets.filter(a => a.type === 'host').length,
    ip: mockAssets.filter(a => a.type === 'ip').length,
    ssl: mockAssets.filter(a => a.type === 'ssl').length,
  };

  return (
    <Box>
      <PageHeader
        title="Asset Inventory"
        subtitle="Comprehensive view of all discovered assets across your attack surface"
        breadcrumbs={[
          { label: 'Inventory' },
        ]}
        actions={
          <>
            <Button startIcon={<RefreshIcon />} variant="outlined">
              Refresh
            </Button>
            <Button startIcon={<DownloadIcon />} variant="outlined">
              Export
            </Button>
          </>
        }
      />

      <Paper sx={{ mb: 2 }}>
        <Tabs
          value={currentTab}
          onChange={(_, newValue) => {
            setCurrentTab(newValue);
            const types = ['all', 'domain', 'host', 'ip', 'ssl'];
            setAssetType(types[newValue]);
          }}
          sx={{ borderBottom: 1, borderColor: 'divider', px: 2 }}
        >
          <Tab label={`All Assets (${assetCounts.all})`} />
          <Tab label={`Domains (${assetCounts.domain})`} />
          <Tab label={`Hosts (${assetCounts.host})`} />
          <Tab label={`IP Addresses (${assetCounts.ip})`} />
          <Tab label={`SSL Certificates (${assetCounts.ssl})`} />
        </Tabs>
      </Paper>

      <Paper sx={{ p: 3 }}>
        <Box sx={{ mb: 3, display: 'flex', gap: 2, alignItems: 'center' }}>
          <SearchBar
            placeholder="Search assets..."
            value={searchQuery}
            onChange={setSearchQuery}
            fullWidth
          />

          <FormControl sx={{ minWidth: 150 }}>
            <InputLabel>Risk Level</InputLabel>
            <Select
              value={riskFilter}
              label="Risk Level"
              onChange={(e) => setRiskFilter(e.target.value)}
              size="small"
            >
              <MenuItem value="all">All Risks</MenuItem>
              <MenuItem value="critical">Critical</MenuItem>
              <MenuItem value="high">High</MenuItem>
              <MenuItem value="medium">Medium</MenuItem>
              <MenuItem value="low">Low</MenuItem>
            </Select>
          </FormControl>

          <Button startIcon={<FilterIcon />} variant="outlined">
            More Filters
          </Button>
        </Box>

        {filteredAssets.length === 0 ? (
          <EmptyState
            title="No assets found"
            description="No assets match your current filters. Try adjusting your search criteria."
          />
        ) : (
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Type</TableCell>
                  <TableCell>Asset Name</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Risk Level</TableCell>
                  <TableCell>Vulnerabilities</TableCell>
                  <TableCell>Last Seen</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredAssets.map((asset) => (
                  <TableRow key={asset.id} hover>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        {getTypeIcon(asset.type)}
                        <Chip label={asset.type} size="small" variant="outlined" />
                      </Box>
                    </TableCell>
                    <TableCell sx={{ fontFamily: 'monospace', fontWeight: 500 }}>
                      {asset.name}
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={asset.status}
                        size="small"
                        color={asset.status === 'active' ? 'success' : 'default'}
                      />
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={asset.riskLevel.toUpperCase()}
                        size="small"
                        color={getRiskColor(asset.riskLevel) as any}
                      />
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={asset.vulnerabilities}
                        size="small"
                        color={asset.vulnerabilities > 10 ? 'error' : 'default'}
                      />
                    </TableCell>
                    <TableCell>{asset.lastSeen}</TableCell>
                    <TableCell align="right">
                      <IconButton
                        size="small"
                        onClick={(e) => {
                          setAnchorEl(e.currentTarget);
                          setSelectedAsset(asset);
                        }}
                      >
                        <MoreVertIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Paper>

      {/* Context Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={() => setAnchorEl(null)}
      >
        <MenuItem onClick={() => setAnchorEl(null)}>View Details</MenuItem>
        <MenuItem onClick={() => setAnchorEl(null)}>Run Scan</MenuItem>
        <MenuItem onClick={() => setAnchorEl(null)}>Export</MenuItem>
        <MenuItem onClick={() => setAnchorEl(null)}>Mark as Safe</MenuItem>
      </Menu>
    </Box>
  );
};

export default AssetInventory;
