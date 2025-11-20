import React, { useState } from 'react';
import {
  Box,
  Paper,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Chip,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from '@mui/material';
import {
  Add as AddIcon,
  Delete as DeleteIcon,
  Edit as EditIcon,
  PlayArrow as PlayIcon,
} from '@mui/icons-material';
import { PageHeader, SearchBar, EmptyState } from '../../shared/components';

interface Seed {
  id: string;
  type: 'domain' | 'ip' | 'asn' | 'cidr' | 'contact';
  value: string;
  status: 'active' | 'paused';
  lastScan?: string;
  assetsFound?: number;
}

const SeedManagement: React.FC = () => {
  const [seeds, setSeeds] = useState<Seed[]>([
    { id: '1', type: 'domain', value: 'example.com', status: 'active', lastScan: '2025-11-19', assetsFound: 47 },
    { id: '2', type: 'ip', value: '192.168.1.0/24', status: 'active', lastScan: '2025-11-19', assetsFound: 12 },
    { id: '3', type: 'asn', value: 'AS15169', status: 'active', lastScan: '2025-11-18', assetsFound: 234 },
  ]);
  const [searchQuery, setSearchQuery] = useState('');
  const [openDialog, setOpenDialog] = useState(false);
  const [newSeed, setNewSeed] = useState({ type: 'domain', value: '' });

  const handleAddSeed = () => {
    if (newSeed.value.trim()) {
      const seed: Seed = {
        id: Date.now().toString(),
        type: newSeed.type as Seed['type'],
        value: newSeed.value.trim(),
        status: 'active',
      };
      setSeeds([...seeds, seed]);
      setNewSeed({ type: 'domain', value: '' });
      setOpenDialog(false);
    }
  };

  const handleDeleteSeed = (id: string) => {
    setSeeds(seeds.filter(s => s.id !== id));
  };

  const filteredSeeds = seeds.filter(seed =>
    seed.value.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <Box>
      <PageHeader
        title="Discovery Seeds"
        subtitle="Manage discovery seeds to identify and monitor your attack surface"
        breadcrumbs={[
          { label: 'Discovery', href: '#' },
          { label: 'Seeds' },
        ]}
        actions={
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => setOpenDialog(true)}
          >
            Add Seed
          </Button>
        }
      />

      <Paper sx={{ p: 3 }}>
        <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <SearchBar
            placeholder="Search seeds..."
            value={searchQuery}
            onChange={setSearchQuery}
          />

          <Box sx={{ display: 'flex', gap: 1 }}>
            <Chip label={`${seeds.length} Seeds`} color="primary" variant="outlined" />
            <Chip label={`${seeds.filter(s => s.status === 'active').length} Active`} color="success" size="small" />
          </Box>
        </Box>

        {filteredSeeds.length === 0 ? (
          <EmptyState
            title="No seeds found"
            description="Add discovery seeds like domains, IP ranges, or ASNs to start discovering your attack surface"
            actionLabel="Add Your First Seed"
            onAction={() => setOpenDialog(true)}
          />
        ) : (
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Type</TableCell>
                  <TableCell>Value</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Last Scan</TableCell>
                  <TableCell>Assets Found</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredSeeds.map((seed) => (
                  <TableRow key={seed.id} hover>
                    <TableCell>
                      <Chip
                        label={seed.type.toUpperCase()}
                        size="small"
                        sx={{ minWidth: 70 }}
                      />
                    </TableCell>
                    <TableCell sx={{ fontFamily: 'monospace' }}>{seed.value}</TableCell>
                    <TableCell>
                      <Chip
                        label={seed.status}
                        color={seed.status === 'active' ? 'success' : 'default'}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>{seed.lastScan || 'Never'}</TableCell>
                    <TableCell>{seed.assetsFound || 0}</TableCell>
                    <TableCell align="right">
                      <IconButton size="small" color="primary">
                        <PlayIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small">
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => handleDeleteSeed(seed.id)}
                      >
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Paper>

      {/* Add Seed Dialog */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Add Discovery Seed</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
            <FormControl fullWidth>
              <InputLabel>Seed Type</InputLabel>
              <Select
                value={newSeed.type}
                label="Seed Type"
                onChange={(e) => setNewSeed({ ...newSeed, type: e.target.value })}
              >
                <MenuItem value="domain">Domain</MenuItem>
                <MenuItem value="ip">IP/CIDR</MenuItem>
                <MenuItem value="asn">ASN</MenuItem>
                <MenuItem value="contact">Contact/Email</MenuItem>
              </Select>
            </FormControl>

            <TextField
              fullWidth
              label="Value"
              placeholder={
                newSeed.type === 'domain' ? 'example.com' :
                newSeed.type === 'ip' ? '192.168.1.0/24' :
                newSeed.type === 'asn' ? 'AS12345' :
                'admin@example.com'
              }
              value={newSeed.value}
              onChange={(e) => setNewSeed({ ...newSeed, value: e.target.value })}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cancel</Button>
          <Button onClick={handleAddSeed} variant="contained">Add Seed</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default SeedManagement;
