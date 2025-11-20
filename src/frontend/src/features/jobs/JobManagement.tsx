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
  Button,
  Menu,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Select,
  FormControl,
  InputLabel,
  LinearProgress,
  Typography,
  Tooltip,
  ListItemIcon,
  ListItemText,
  Divider,
} from '@mui/material';
import {
  MoreVert as MoreVertIcon,
  Stop as StopIcon,
  SkipNext as SkipIcon,
  Schedule as ScheduleIcon,
  PlayArrow as PlayIcon,
  Refresh as RefreshIcon,
  Delete as DeleteIcon,
  Info as InfoIcon,
  Edit as EditIcon,
} from '@mui/icons-material';
import { PageHeader, SearchBar } from '../../shared/components';

interface Job {
  id: string;
  name: string;
  type: 'discovery' | 'scan' | 'vulnerability-assessment';
  status: 'running' | 'scheduled' | 'completed' | 'failed' | 'paused';
  progress?: number;
  schedule?: string;
  nextRun?: string;
  lastRun?: string;
  duration?: string;
}

const JobManagement: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [selectedJob, setSelectedJob] = useState<Job | null>(null);
  const [scheduleDialogOpen, setScheduleDialogOpen] = useState(false);
  const [scheduleFrequency, setScheduleFrequency] = useState('daily');
  const [scheduleTime, setScheduleTime] = useState('00:00');

  const mockJobs: Job[] = [
    {
      id: '1',
      name: 'Full Asset Discovery',
      type: 'discovery',
      status: 'running',
      progress: 65,
      schedule: 'Daily at 00:00',
      nextRun: '2025-11-21 00:00',
      lastRun: '2025-11-20 00:00',
      duration: '2h 15m',
    },
    {
      id: '2',
      name: 'Vulnerability Scan - Production',
      type: 'vulnerability-assessment',
      status: 'scheduled',
      schedule: 'Weekly on Monday',
      nextRun: '2025-11-25 02:00',
      lastRun: '2025-11-18 02:00',
      duration: '45m',
    },
    {
      id: '3',
      name: 'Certificate Expiration Check',
      type: 'scan',
      status: 'completed',
      schedule: 'Daily at 06:00',
      nextRun: '2025-11-21 06:00',
      lastRun: '2025-11-20 06:00',
      duration: '12m',
    },
    {
      id: '4',
      name: 'Port Scan - External IPs',
      type: 'scan',
      status: 'paused',
      schedule: 'Every 6 hours',
      nextRun: 'Paused',
      lastRun: '2025-11-19 18:00',
      duration: '1h 30m',
    },
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'running': return 'info';
      case 'scheduled': return 'warning';
      case 'completed': return 'success';
      case 'failed': return 'error';
      case 'paused': return 'default';
      default: return 'default';
    }
  };

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'discovery': return 'primary';
      case 'scan': return 'secondary';
      case 'vulnerability-assessment': return 'error';
      default: return 'default';
    }
  };

  const handleStopJob = (job: Job) => {
    console.log('Stopping job:', job.id);
    setAnchorEl(null);
  };

  const handleSkipJob = (job: Job) => {
    console.log('Skipping job:', job.id);
    setAnchorEl(null);
  };

  const handleOpenSchedule = (job: Job) => {
    setSelectedJob(job);
    setScheduleDialogOpen(true);
    setAnchorEl(null);
  };

  const handleSaveSchedule = () => {
    console.log('Saving schedule:', { job: selectedJob?.id, frequency: scheduleFrequency, time: scheduleTime });
    setScheduleDialogOpen(false);
  };

  const handleDeleteJob = (job: Job) => {
    console.log('Deleting job:', job.id);
    setAnchorEl(null);
  };

  const filteredJobs = mockJobs.filter(job =>
    job.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    job.type.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <Box>
      <PageHeader
        title="Job Management"
        subtitle="Monitor and manage discovery, scanning, and assessment jobs"
        breadcrumbs={[
          { label: 'Jobs' },
        ]}
        actions={
          <Button startIcon={<RefreshIcon />} variant="outlined">
            Refresh
          </Button>
        }
      />

      {/* Summary Cards */}
      <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 2, mb: 3 }}>
        <Paper sx={{ p: 2 }}>
          <Typography variant="body2" color="text.secondary">Running</Typography>
          <Typography variant="h4" sx={{ fontWeight: 600 }}>
            {mockJobs.filter(j => j.status === 'running').length}
          </Typography>
        </Paper>
        <Paper sx={{ p: 2 }}>
          <Typography variant="body2" color="text.secondary">Scheduled</Typography>
          <Typography variant="h4" sx={{ fontWeight: 600 }}>
            {mockJobs.filter(j => j.status === 'scheduled').length}
          </Typography>
        </Paper>
        <Paper sx={{ p: 2 }}>
          <Typography variant="body2" color="text.secondary">Completed</Typography>
          <Typography variant="h4" sx={{ fontWeight: 600 }}>
            {mockJobs.filter(j => j.status === 'completed').length}
          </Typography>
        </Paper>
        <Paper sx={{ p: 2 }}>
          <Typography variant="body2" color="text.secondary">Failed</Typography>
          <Typography variant="h4" sx={{ fontWeight: 600 }}>
            {mockJobs.filter(j => j.status === 'failed').length}
          </Typography>
        </Paper>
      </Box>

      <Paper sx={{ p: 3 }}>
        <Box sx={{ mb: 3 }}>
          <SearchBar
            placeholder="Search jobs by name or type..."
            value={searchQuery}
            onChange={setSearchQuery}
            fullWidth
          />
        </Box>

        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Job Name</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Progress</TableCell>
                <TableCell>Schedule</TableCell>
                <TableCell>Next Run</TableCell>
                <TableCell>Last Run</TableCell>
                <TableCell>Duration</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredJobs.map((job) => (
                <TableRow key={job.id} hover>
                  <TableCell sx={{ fontWeight: 500 }}>{job.name}</TableCell>
                  <TableCell>
                    <Chip
                      label={job.type.replace('-', ' ')}
                      size="small"
                      color={getTypeColor(job.type) as any}
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={job.status.toUpperCase()}
                      size="small"
                      color={getStatusColor(job.status) as any}
                    />
                  </TableCell>
                  <TableCell sx={{ minWidth: 150 }}>
                    {job.progress !== undefined ? (
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <LinearProgress
                          variant="determinate"
                          value={job.progress}
                          sx={{ flex: 1, height: 6, borderRadius: 3 }}
                        />
                        <Typography variant="caption">{job.progress}%</Typography>
                      </Box>
                    ) : (
                      <Typography variant="caption" color="text.secondary">N/A</Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" sx={{ fontSize: '0.875rem' }}>
                      {job.schedule || 'One-time'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" sx={{ fontSize: '0.875rem' }}>
                      {job.nextRun || 'N/A'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" sx={{ fontSize: '0.875rem' }}>
                      {job.lastRun || 'Never'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" sx={{ fontSize: '0.875rem' }}>
                      {job.duration || 'N/A'}
                    </Typography>
                  </TableCell>
                  <TableCell align="right">
                    <IconButton
                      size="small"
                      onClick={(e) => {
                        setSelectedJob(job);
                        setAnchorEl(e.currentTarget);
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
        {selectedJob?.status === 'running' && (
          <MenuItem onClick={() => selectedJob && handleStopJob(selectedJob)}>
            <ListItemIcon><StopIcon fontSize="small" /></ListItemIcon>
            <ListItemText>Stop Job</ListItemText>
          </MenuItem>
        )}
        {selectedJob?.status === 'scheduled' && (
          <MenuItem onClick={() => selectedJob && handleSkipJob(selectedJob)}>
            <ListItemIcon><SkipIcon fontSize="small" /></ListItemIcon>
            <ListItemText>Skip Next Run</ListItemText>
          </MenuItem>
        )}
        {selectedJob?.status === 'paused' && (
          <MenuItem onClick={() => setAnchorEl(null)}>
            <ListItemIcon><PlayIcon fontSize="small" /></ListItemIcon>
            <ListItemText>Resume</ListItemText>
          </MenuItem>
        )}
        <MenuItem onClick={() => selectedJob && handleOpenSchedule(selectedJob)}>
          <ListItemIcon><EditIcon fontSize="small" /></ListItemIcon>
          <ListItemText>Change Schedule</ListItemText>
        </MenuItem>
        <Divider />
        <MenuItem onClick={() => selectedJob && handleDeleteJob(selectedJob)}>
          <ListItemIcon><DeleteIcon fontSize="small" color="error" /></ListItemIcon>
          <ListItemText>Delete Job</ListItemText>
        </MenuItem>
      </Menu>

      {/* Schedule Dialog */}
      <Dialog open={scheduleDialogOpen} onClose={() => setScheduleDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <ScheduleIcon />
            Change Schedule
          </Box>
        </DialogTitle>
        <DialogContent>
          {selectedJob && (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
              <Typography variant="body2" color="text.secondary">
                Job: <strong>{selectedJob.name}</strong>
              </Typography>

              <FormControl fullWidth>
                <InputLabel>Frequency</InputLabel>
                <Select
                  value={scheduleFrequency}
                  label="Frequency"
                  onChange={(e) => setScheduleFrequency(e.target.value)}
                >
                  <MenuItem value="hourly">Hourly</MenuItem>
                  <MenuItem value="every-6-hours">Every 6 Hours</MenuItem>
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
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setScheduleDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSaveSchedule}>
            Save Schedule
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default JobManagement;
