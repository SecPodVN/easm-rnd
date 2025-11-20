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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  ToggleButtonGroup,
  ToggleButton,
  Tooltip,
  ListItemIcon,
  ListItemText,
  Divider,
  Card,
  CardContent,
  Typography,
  Checkbox,
  FormControlLabel,
  Alert,
} from '@mui/material';
import {
  MoreVert as MoreVertIcon,
  FilterList as FilterIcon,
  Download as DownloadIcon,
  Refresh as RefreshIcon,
  Language as DomainIcon,
  Security as CertIcon,
  Hub as ASNIcon,
  Public as IPIcon,
  ContactMail as ContactIcon,
  Search as SearchIcon,
  PlayArrow as DiscoverIcon,
  Schedule as ScheduleIcon,
  Label as ClassifyIcon,
  Block as FalsePositiveIcon,
  List as ListViewIcon,
  Map as MapIcon,
  AccountTree as GraphIcon,
  Info as InfoIcon,
} from '@mui/icons-material';
import { PageHeader, SearchBar, EmptyState } from '../../shared/components';

interface Asset {
  id: string;
  type: 'domain' | 'cert' | 'asn' | 'ip' | 'contact';
  name: string;
  status: 'active' | 'inactive';
  riskLevel: 'critical' | 'high' | 'medium' | 'low';
  lastSeen: string;
  vulnerabilities: number;
  classification?: string;
  falsePositive?: boolean;
}

type ViewMode = 'list' | 'map' | 'graph';

const AssetInventory: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [assetType, setAssetType] = useState<string>('all');
  const [riskFilter, setRiskFilter] = useState<string>('all');
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [selectedAsset, setSelectedAsset] = useState<Asset | null>(null);
  const [currentTab, setCurrentTab] = useState(0);
  const [viewMode, setViewMode] = useState<ViewMode>('list');

  // Dialog states
  const [discoverDialogOpen, setDiscoverDialogOpen] = useState(false);
  const [classifyDialogOpen, setClassifyDialogOpen] = useState(false);
  const [scheduleDialogOpen, setScheduleDialogOpen] = useState(false);

  // Discover dialog state
  const [discoverType, setDiscoverType] = useState('full');
  const [runNow, setRunNow] = useState(true);

  // Classify dialog state
  const [classification, setClassification] = useState('');
  const [classificationNotes, setClassificationNotes] = useState('');

  // Schedule state
  const [scheduleFrequency, setScheduleFrequency] = useState('daily');
  const [scheduleTime, setScheduleTime] = useState('00:00');

  const mockAssets: Asset[] = [
    { id: '1', type: 'domain', name: 'example.com', status: 'active', riskLevel: 'high', lastSeen: '2025-11-19', vulnerabilities: 12, classification: 'Production' },
    { id: '2', type: 'cert', name: '*.example.com (SSL/TLS)', status: 'active', riskLevel: 'critical', lastSeen: '2025-11-19', vulnerabilities: 24 },
    { id: '3', type: 'asn', name: 'AS15169 (Google LLC)', status: 'active', riskLevel: 'medium', lastSeen: '2025-11-18', vulnerabilities: 3, classification: 'External' },
    { id: '4', type: 'ip', name: '192.168.1.100', status: 'active', riskLevel: 'low', lastSeen: '2025-11-19', vulnerabilities: 1 },
    { id: '5', type: 'contact', name: 'admin@example.com', status: 'active', riskLevel: 'low', lastSeen: '2025-11-19', vulnerabilities: 0, falsePositive: false },
  ];

  // Action Handlers
  const handleOpenDiscover = () => {
    setDiscoverDialogOpen(true);
    setAnchorEl(null);
  };

  const handleOpenSchedule = () => {
    setScheduleDialogOpen(true);
    setDiscoverDialogOpen(false);
  };

  const handleRunDiscover = () => {
    console.log('Running discovery:', { type: discoverType, runNow });
    setDiscoverDialogOpen(false);
  };

  const handleOpenClassify = (asset: Asset) => {
    setSelectedAsset(asset);
    setClassification(asset.classification || '');
    setClassificationNotes('');
    setClassifyDialogOpen(true);
    setAnchorEl(null);
  };

  const handleSaveClassification = () => {
    console.log('Saving classification:', { asset: selectedAsset?.id, classification, notes: classificationNotes });
    setClassifyDialogOpen(false);
  };

  const handleMarkFalsePositive = (asset: Asset) => {
    console.log('Marking as false positive:', asset.id);
    setAnchorEl(null);
  };

  const handleSaveSchedule = () => {
    console.log('Saving schedule:', { frequency: scheduleFrequency, time: scheduleTime });
    setScheduleDialogOpen(false);
  };

  const renderMapView = () => (
    <Card sx={{ minHeight: 400, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <CardContent>
        <MapIcon sx={{ fontSize: 80, color: 'text.secondary', mb: 2 }} />
        <Typography variant="h6" color="text.secondary" align="center">
          Map View
        </Typography>
        <Typography variant="body2" color="text.secondary" align="center">
          Geographic distribution of assets across your attack surface
        </Typography>
      </CardContent>
    </Card>
  );

  const renderGraphView = () => (
    <Card sx={{ minHeight: 400, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <CardContent>
        <GraphIcon sx={{ fontSize: 80, color: 'text.secondary', mb: 2 }} />
        <Typography variant="h6" color="text.secondary" align="center">
          Graph View
        </Typography>
        <Typography variant="body2" color="text.secondary" align="center">
          Asset relationships and dependencies visualization
        </Typography>
      </CardContent>
    </Card>
  );

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'domain': return <DomainIcon fontSize="small" />;
      case 'cert': return <CertIcon fontSize="small" />;
      case 'asn': return <ASNIcon fontSize="small" />;
      case 'ip': return <IPIcon fontSize="small" />;
      case 'contact': return <ContactIcon fontSize="small" />;
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
    cert: mockAssets.filter(a => a.type === 'cert').length,
    asn: mockAssets.filter(a => a.type === 'asn').length,
    ip: mockAssets.filter(a => a.type === 'ip').length,
    contact: mockAssets.filter(a => a.type === 'contact').length,
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
            <Button startIcon={<DiscoverIcon />} variant="contained" onClick={handleOpenDiscover}>
              Discover
            </Button>
            <Button startIcon={<RefreshIcon />} variant="outlined">
              Refresh
            </Button>
            <Button startIcon={<DownloadIcon />} variant="outlined">
              Export
            </Button>
          </>
        }
      />

      <Paper sx={{ mb: 3 }}>
        <Tabs
          value={currentTab}
          onChange={(_, newValue) => {
            setCurrentTab(newValue);
            const types = ['all', 'domain', 'cert', 'asn', 'ip', 'contact'];
            setAssetType(types[newValue]);
          }}
          sx={{ borderBottom: 1, borderColor: 'divider', px: 2 }}
        >
          <Tab label={`All Assets (${assetCounts.all})`} />
          <Tab label={`Domains (${assetCounts.domain})`} />
          <Tab label={`Certificates (${assetCounts.cert})`} />
          <Tab label={`ASNs (${assetCounts.asn})`} />
          <Tab label={`IP Addresses (${assetCounts.ip})`} />
          <Tab label={`Contacts (${assetCounts.contact})`} />
        </Tabs>
      </Paper>

      <Paper sx={{ p: 3 }}>
        <Box sx={{ mb: 3, display: 'flex', gap: 2, alignItems: 'center' }}>
          <Box sx={{ flex: 1 }}>
            <SearchBar
              placeholder="Search assets..."
              value={searchQuery}
              onChange={setSearchQuery}
              fullWidth
            />
          </Box>

          <ToggleButtonGroup
            value={viewMode}
            exclusive
            onChange={(_, value) => value && setViewMode(value)}
            size="small"
          >
            <ToggleButton value="list">
              <Tooltip title="List View"><ListViewIcon fontSize="small" /></Tooltip>
            </ToggleButton>
            <ToggleButton value="map">
              <Tooltip title="Map View"><MapIcon fontSize="small" /></Tooltip>
            </ToggleButton>
            <ToggleButton value="graph">
              <Tooltip title="Graph View"><GraphIcon fontSize="small" /></Tooltip>
            </ToggleButton>
          </ToggleButtonGroup>

          <FormControl sx={{ minWidth: 150 }} size="small">
            <InputLabel>Risk Level</InputLabel>
            <Select
              value={riskFilter}
              label="Risk Level"
              onChange={(e) => setRiskFilter(e.target.value)}
            >
              <MenuItem value="all">All Risks</MenuItem>
              <MenuItem value="critical">Critical</MenuItem>
              <MenuItem value="high">High</MenuItem>
              <MenuItem value="medium">Medium</MenuItem>
              <MenuItem value="low">Low</MenuItem>
            </Select>
          </FormControl>

          <Button startIcon={<FilterIcon />} variant="outlined" size="small">
            More Filters
          </Button>
        </Box>

        {viewMode === 'map' ? renderMapView() : viewMode === 'graph' ? renderGraphView() : (
          filteredAssets.length === 0 ? (
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
                    <TableCell>Classification</TableCell>
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
                        {asset.falsePositive && (
                          <Chip label="FP" size="small" color="default" sx={{ ml: 1, fontSize: '0.65rem' }} />
                        )}
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
                      <TableCell>
                        {asset.classification ? (
                          <Chip label={asset.classification} size="small" icon={<ClassifyIcon />} />
                        ) : (
                          <Typography variant="caption" color="text.secondary">Unclassified</Typography>
                        )}
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
          )
        )}
      </Paper>

      {/* Context Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={() => setAnchorEl(null)}
      >
        <MenuItem onClick={() => setAnchorEl(null)}>
          <ListItemIcon><InfoIcon fontSize="small" /></ListItemIcon>
          <ListItemText>View Details</ListItemText>
        </MenuItem>
        <MenuItem onClick={() => setAnchorEl(null)}>
          <ListItemIcon><SearchIcon fontSize="small" /></ListItemIcon>
          <ListItemText>Run Scan</ListItemText>
        </MenuItem>
        <MenuItem onClick={() => selectedAsset && handleOpenClassify(selectedAsset)}>
          <ListItemIcon><ClassifyIcon fontSize="small" /></ListItemIcon>
          <ListItemText>Classify (Manual)</ListItemText>
        </MenuItem>
        <Divider />
        <MenuItem onClick={() => selectedAsset && handleMarkFalsePositive(selectedAsset)}>
          <ListItemIcon><FalsePositiveIcon fontSize="small" /></ListItemIcon>
          <ListItemText>Mark as False Positive</ListItemText>
        </MenuItem>
        <MenuItem onClick={() => setAnchorEl(null)}>
          <ListItemIcon><DownloadIcon fontSize="small" /></ListItemIcon>
          <ListItemText>Export</ListItemText>
        </MenuItem>
      </Menu>

      {/* Discover Dialog */}
      <Dialog open={discoverDialogOpen} onClose={() => setDiscoverDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <DiscoverIcon />
            Discovery Configuration
          </Box>
        </DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
            <Alert severity="info">
              Run asset discovery to identify new domains, IPs, certificates, and other assets in your attack surface.
            </Alert>

            <FormControl fullWidth>
              <InputLabel>Discovery Type</InputLabel>
              <Select
                value={discoverType}
                label="Discovery Type"
                onChange={(e) => setDiscoverType(e.target.value)}
              >
                <MenuItem value="full">Full Discovery (All Seeds)</MenuItem>
                <MenuItem value="incremental">Incremental (New Assets Only)</MenuItem>
                <MenuItem value="targeted">Targeted (Specific Asset Types)</MenuItem>
              </Select>
            </FormControl>

            <FormControlLabel
              control={
                <Checkbox
                  checked={runNow}
                  onChange={(e) => setRunNow(e.target.checked)}
                />
              }
              label="Run on-demand (Execute immediately)"
            />

            {!runNow && (
              <Button
                variant="outlined"
                startIcon={<ScheduleIcon />}
                onClick={handleOpenSchedule}
                fullWidth
              >
                Set Schedule to Run
              </Button>
            )}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDiscoverDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleRunDiscover}>
            {runNow ? 'Run Now' : 'Save Configuration'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Schedule Dialog */}
      <Dialog open={scheduleDialogOpen} onClose={() => setScheduleDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <ScheduleIcon />
            Schedule Discovery
          </Box>
        </DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
            <FormControl fullWidth>
              <InputLabel>Frequency</InputLabel>
              <Select
                value={scheduleFrequency}
                label="Frequency"
                onChange={(e) => setScheduleFrequency(e.target.value)}
              >
                <MenuItem value="hourly">Hourly</MenuItem>
                <MenuItem value="daily">Daily</MenuItem>
                <MenuItem value="weekly">Weekly</MenuItem>
                <MenuItem value="monthly">Monthly</MenuItem>
              </Select>
            </FormControl>

            <TextField
              label="Time"
              type="time"
              fullWidth
              value={scheduleTime}
              onChange={(e) => setScheduleTime(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />

            <Alert severity="warning">
              Scheduled discovery will run automatically at the specified time. Jobs can be managed in the Job Management section.
            </Alert>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setScheduleDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSaveSchedule}>
            Save Schedule
          </Button>
        </DialogActions>
      </Dialog>

      {/* Classify Dialog */}
      <Dialog open={classifyDialogOpen} onClose={() => setClassifyDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <ClassifyIcon />
            Classify Asset
          </Box>
        </DialogTitle>
        <DialogContent>
          {selectedAsset && (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
              <Alert severity="info">
                <Typography variant="body2">
                  <strong>{selectedAsset.name}</strong> ({selectedAsset.type})
                </Typography>
              </Alert>

              <FormControl fullWidth>
                <InputLabel>Classification</InputLabel>
                <Select
                  value={classification}
                  label="Classification"
                  onChange={(e) => setClassification(e.target.value)}
                >
                  <MenuItem value="">Unclassified</MenuItem>
                  <MenuItem value="Production">Production</MenuItem>
                  <MenuItem value="Staging">Staging</MenuItem>
                  <MenuItem value="Development">Development</MenuItem>
                  <MenuItem value="External">External / Third Party</MenuItem>
                  <MenuItem value="Legacy">Legacy</MenuItem>
                  <MenuItem value="Decommissioned">Decommissioned</MenuItem>
                </Select>
              </FormControl>

              <TextField
                label="Notes"
                multiline
                rows={3}
                fullWidth
                value={classificationNotes}
                onChange={(e) => setClassificationNotes(e.target.value)}
                placeholder="Add any additional context or notes about this classification..."
              />
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setClassifyDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSaveClassification}>
            Save Classification
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AssetInventory;
