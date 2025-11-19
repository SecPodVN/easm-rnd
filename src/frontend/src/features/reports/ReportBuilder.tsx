import React, { useState } from 'react';
import {
  Box,
  Paper,
  Button,
  Card,
  CardContent,
  CardActions,
  Typography,
  Chip,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Stack,
} from '@mui/material';
import {
  Description as ReportIcon,
  Download as DownloadIcon,
  Schedule as ScheduleIcon,
  Assessment as AssessmentIcon,
  Security as SecurityIcon,
  Policy as ComplianceIcon,
} from '@mui/icons-material';
import { PageHeader } from '../../shared/components';

interface Report {
  id: string;
  title: string;
  description: string;
  type: 'executive' | 'technical' | 'compliance';
  icon: React.ReactNode;
  lastGenerated?: string;
}

const ReportBuilder: React.FC = () => {
  const [reportType, setReportType] = useState('executive');
  const [dateRange, setDateRange] = useState('last-30-days');

  const availableReports: Report[] = [
    {
      id: '1',
      title: 'Executive Summary',
      description: 'High-level overview of attack surface and key risk metrics',
      type: 'executive',
      icon: <AssessmentIcon sx={{ fontSize: 40, color: '#0078d4' }} />,
      lastGenerated: '2025-11-15',
    },
    {
      id: '2',
      title: 'Technical Deep Dive',
      description: 'Detailed vulnerability findings with remediation steps',
      type: 'technical',
      icon: <SecurityIcon sx={{ fontSize: 40, color: '#107c10' }} />,
      lastGenerated: '2025-11-18',
    },
    {
      id: '3',
      title: 'PCI-DSS Compliance',
      description: 'PCI-DSS mapping and compliance status report',
      type: 'compliance',
      icon: <ComplianceIcon sx={{ fontSize: 40, color: '#ff8c00' }} />,
      lastGenerated: '2025-11-10',
    },
    {
      id: '4',
      title: 'ISO 27001 Compliance',
      description: 'ISO 27001 controls mapping and gap analysis',
      type: 'compliance',
      icon: <ComplianceIcon sx={{ fontSize: 40, color: '#ff8c00' }} />,
    },
    {
      id: '5',
      title: 'Asset Inventory Report',
      description: 'Complete listing of all discovered assets',
      type: 'technical',
      icon: <ReportIcon sx={{ fontSize: 40, color: '#5c2d91' }} />,
      lastGenerated: '2025-11-19',
    },
    {
      id: '6',
      title: 'Risk Trend Analysis',
      description: 'Historical risk trends and exposure changes',
      type: 'executive',
      icon: <AssessmentIcon sx={{ fontSize: 40, color: '#0078d4' }} />,
      lastGenerated: '2025-11-12',
    },
  ];

  const filteredReports = availableReports;

  return (
    <Box>
      <PageHeader
        title="Reports"
        subtitle="Generate comprehensive reports for stakeholders and compliance"
        breadcrumbs={[
          { label: 'Reports' },
        ]}
      />

      {/* Report Builder */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
          Quick Report Builder
        </Typography>

        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2}>
          <FormControl fullWidth>
            <InputLabel>Report Type</InputLabel>
            <Select
              value={reportType}
              label="Report Type"
              onChange={(e) => setReportType(e.target.value)}
            >
              <MenuItem value="executive">Executive Summary</MenuItem>
              <MenuItem value="technical">Technical Report</MenuItem>
              <MenuItem value="compliance">Compliance Report</MenuItem>
              <MenuItem value="custom">Custom Report</MenuItem>
            </Select>
          </FormControl>

          <FormControl fullWidth>
            <InputLabel>Date Range</InputLabel>
            <Select
              value={dateRange}
              label="Date Range"
              onChange={(e) => setDateRange(e.target.value)}
            >
              <MenuItem value="last-7-days">Last 7 Days</MenuItem>
              <MenuItem value="last-30-days">Last 30 Days</MenuItem>
              <MenuItem value="last-90-days">Last 90 Days</MenuItem>
              <MenuItem value="custom">Custom Range</MenuItem>
            </Select>
          </FormControl>

          <Button
            fullWidth
            variant="contained"
            startIcon={<DownloadIcon />}
            sx={{ height: 56 }}
          >
            Generate Report
          </Button>
        </Stack>
      </Paper>

      {/* Available Report Templates */}
      <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
        Report Templates
      </Typography>

      <Box sx={{
        display: 'grid',
        gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)', lg: 'repeat(3, 1fr)' },
        gap: 3
      }}>
        {filteredReports.map((report) => (
          <Card key={report.id} sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
            <CardContent sx={{ flex: 1 }}>
              <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2 }}>
                <Box>{report.icon}</Box>
                <Box sx={{ flex: 1 }}>
                  <Typography variant="h6" sx={{ fontWeight: 600, mb: 0.5 }}>
                    {report.title}
                  </Typography>
                  <Chip
                    label={report.type}
                    size="small"
                    sx={{ mb: 1 }}
                  />
                </Box>
              </Box>

              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                {report.description}
              </Typography>

              {report.lastGenerated && (
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                  <ScheduleIcon fontSize="small" color="action" />
                  <Typography variant="caption" color="text.secondary">
                    Last generated: {report.lastGenerated}
                  </Typography>
                </Box>
              )}
            </CardContent>

            <CardActions sx={{ p: 2, pt: 0 }}>
              <Button size="small" startIcon={<DownloadIcon />}>
                Generate
              </Button>
              <Button size="small">Configure</Button>
              <Button size="small">Schedule</Button>
            </CardActions>
          </Card>
        ))}
      </Box>

      {/* Scheduled Reports */}
      <Paper sx={{ p: 3, mt: 3 }}>
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>
          Scheduled Reports
        </Typography>

        <Typography variant="body2" color="text.secondary" align="center" sx={{ py: 4 }}>
          No scheduled reports configured. Click "Schedule" on any report template to set up automated delivery.
        </Typography>
      </Paper>
    </Box>
  );
};

export default ReportBuilder;
