import React, { useState } from 'react';
import {
  Box,
  Paper,
  Tabs,
  Tab,
  TextField,
  Button,
  Typography,
  Switch,
  FormControlLabel,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Divider,
  Alert,
} from '@mui/material';
import {
  Settings as SettingsIcon,
  Security as SecurityIcon,
  Notifications as NotificationsIcon,
  Extension as IntegrationIcon,
  People as UsersIcon,
  Save as SaveIcon,
} from '@mui/icons-material';
import { PageHeader } from '../../shared/components';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`settings-tabpanel-${index}`}
      aria-labelledby={`settings-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ p: 3 }}>{children}</Box>}
    </div>
  );
}

const Settings: React.FC = () => {
  const [currentTab, setCurrentTab] = useState(0);

  // General Settings
  const [organizationName, setOrganizationName] = useState('SecPod');
  const [timezone, setTimezone] = useState('UTC');
  const [language, setLanguage] = useState('en');

  // Security Settings
  const [sessionTimeout, setSessionTimeout] = useState('30');
  const [twoFactorAuth, setTwoFactorAuth] = useState(true);
  const [passwordExpiry, setPasswordExpiry] = useState('90');

  // Notification Settings
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [slackNotifications, setSlackNotifications] = useState(false);
  const [criticalAlerts, setCriticalAlerts] = useState(true);

  // Scanner Integration
  const [cvemEnabled, setCvemEnabled] = useState(true);
  const [cvemApiKey, setCvemApiKey] = useState('sk_test_***************');
  const [cvemUrl, setCvemUrl] = useState('https://cvem.secpod.com/api');

  const handleSave = () => {
    console.log('Saving settings...');
  };

  return (
    <Box>
      <PageHeader
        title="Settings"
        subtitle="Configure your EASM platform settings and integrations"
        breadcrumbs={[
          { label: 'Settings' },
        ]}
      />

      <Paper>
        <Tabs
          value={currentTab}
          onChange={(_, newValue) => setCurrentTab(newValue)}
          sx={{ borderBottom: 1, borderColor: 'divider', px: 2 }}
        >
          <Tab icon={<SettingsIcon />} label="General" iconPosition="start" />
          <Tab icon={<SecurityIcon />} label="Security" iconPosition="start" />
          <Tab icon={<NotificationsIcon />} label="Notifications" iconPosition="start" />
          <Tab icon={<IntegrationIcon />} label="Integrations" iconPosition="start" />
          <Tab icon={<UsersIcon />} label="Users & Teams" iconPosition="start" />
        </Tabs>

        {/* General Settings */}
        <TabPanel value={currentTab} index={0}>
          <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>General Settings</Typography>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, maxWidth: 600 }}>
            <TextField
              label="Organization Name"
              fullWidth
              value={organizationName}
              onChange={(e) => setOrganizationName(e.target.value)}
            />

            <FormControl fullWidth>
              <InputLabel>Timezone</InputLabel>
              <Select
                value={timezone}
                label="Timezone"
                onChange={(e) => setTimezone(e.target.value)}
              >
                <MenuItem value="UTC">UTC</MenuItem>
                <MenuItem value="America/New_York">America/New York (EST)</MenuItem>
                <MenuItem value="America/Los_Angeles">America/Los Angeles (PST)</MenuItem>
                <MenuItem value="Europe/London">Europe/London (GMT)</MenuItem>
                <MenuItem value="Asia/Tokyo">Asia/Tokyo (JST)</MenuItem>
              </Select>
            </FormControl>

            <FormControl fullWidth>
              <InputLabel>Language</InputLabel>
              <Select
                value={language}
                label="Language"
                onChange={(e) => setLanguage(e.target.value)}
              >
                <MenuItem value="en">English</MenuItem>
                <MenuItem value="es">Spanish</MenuItem>
                <MenuItem value="fr">French</MenuItem>
                <MenuItem value="de">German</MenuItem>
                <MenuItem value="ja">Japanese</MenuItem>
              </Select>
            </FormControl>

            <Button variant="contained" startIcon={<SaveIcon />} onClick={handleSave}>
              Save General Settings
            </Button>
          </Box>
        </TabPanel>

        {/* Security Settings */}
        <TabPanel value={currentTab} index={1}>
          <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>Security Settings</Typography>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, maxWidth: 600 }}>
            <TextField
              label="Session Timeout (minutes)"
              type="number"
              fullWidth
              value={sessionTimeout}
              onChange={(e) => setSessionTimeout(e.target.value)}
              helperText="Users will be automatically logged out after this period of inactivity"
            />

            <TextField
              label="Password Expiry (days)"
              type="number"
              fullWidth
              value={passwordExpiry}
              onChange={(e) => setPasswordExpiry(e.target.value)}
              helperText="Users will be required to change passwords after this period"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={twoFactorAuth}
                  onChange={(e) => setTwoFactorAuth(e.target.checked)}
                />
              }
              label="Require Two-Factor Authentication (2FA)"
            />

            <Alert severity="info">
              Strong security settings help protect your attack surface data. We recommend keeping 2FA enabled.
            </Alert>

            <Button variant="contained" startIcon={<SaveIcon />} onClick={handleSave}>
              Save Security Settings
            </Button>
          </Box>
        </TabPanel>

        {/* Notification Settings */}
        <TabPanel value={currentTab} index={2}>
          <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>Notification Settings</Typography>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, maxWidth: 600 }}>
            <Typography variant="subtitle2" color="text.secondary">
              Configure how you want to receive alerts and notifications
            </Typography>

            <Divider sx={{ my: 1 }} />

            <FormControlLabel
              control={
                <Switch
                  checked={emailNotifications}
                  onChange={(e) => setEmailNotifications(e.target.checked)}
                />
              }
              label="Email Notifications"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={slackNotifications}
                  onChange={(e) => setSlackNotifications(e.target.checked)}
                />
              }
              label="Slack Notifications"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={criticalAlerts}
                  onChange={(e) => setCriticalAlerts(e.target.checked)}
                />
              }
              label="Critical Vulnerability Alerts (Immediate)"
            />

            <Divider sx={{ my: 1 }} />

            <Typography variant="subtitle2" sx={{ mt: 2 }}>Alert Thresholds</Typography>

            <FormControl fullWidth>
              <InputLabel>New Critical Vulnerabilities</InputLabel>
              <Select defaultValue="immediate" label="New Critical Vulnerabilities">
                <MenuItem value="immediate">Immediate</MenuItem>
                <MenuItem value="hourly">Hourly Digest</MenuItem>
                <MenuItem value="daily">Daily Digest</MenuItem>
              </Select>
            </FormControl>

            <FormControl fullWidth>
              <InputLabel>New Assets Discovered</InputLabel>
              <Select defaultValue="daily" label="New Assets Discovered">
                <MenuItem value="immediate">Immediate</MenuItem>
                <MenuItem value="daily">Daily Digest</MenuItem>
                <MenuItem value="weekly">Weekly Digest</MenuItem>
              </Select>
            </FormControl>

            <Button variant="contained" startIcon={<SaveIcon />} onClick={handleSave} sx={{ mt: 2 }}>
              Save Notification Settings
            </Button>
          </Box>
        </TabPanel>

        {/* Integration Settings */}
        <TabPanel value={currentTab} index={3}>
          <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>Scanner Integrations</Typography>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, maxWidth: 600 }}>
            <Alert severity="info">
              Connect external vulnerability scanners and security tools to enhance your EASM capabilities
            </Alert>

            <Divider />

            <Typography variant="subtitle1" sx={{ fontWeight: 600 }}>CVEM Scanner Integration</Typography>

            <FormControlLabel
              control={
                <Switch
                  checked={cvemEnabled}
                  onChange={(e) => setCvemEnabled(e.target.checked)}
                />
              }
              label="Enable CVEM Integration"
            />

            {cvemEnabled && (
              <>
                <TextField
                  label="CVEM API URL"
                  fullWidth
                  value={cvemUrl}
                  onChange={(e) => setCvemUrl(e.target.value)}
                  placeholder="https://cvem.secpod.com/api"
                />

                <TextField
                  label="API Key"
                  fullWidth
                  type="password"
                  value={cvemApiKey}
                  onChange={(e) => setCvemApiKey(e.target.value)}
                  placeholder="Enter your CVEM API key"
                />

                <Button variant="outlined">Test Connection</Button>
              </>
            )}

            <Divider />

            <Typography variant="subtitle1" sx={{ fontWeight: 600 }}>Other Integrations</Typography>

            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <FormControlLabel
                control={<Switch />}
                label="Jira Integration (Issue Tracking)"
              />
              <FormControlLabel
                control={<Switch />}
                label="Splunk Integration (SIEM)"
              />
              <FormControlLabel
                control={<Switch />}
                label="ServiceNow Integration (ITSM)"
              />
            </Box>

            <Button variant="contained" startIcon={<SaveIcon />} onClick={handleSave} sx={{ mt: 2 }}>
              Save Integration Settings
            </Button>
          </Box>
        </TabPanel>

        {/* Users & Teams */}
        <TabPanel value={currentTab} index={4}>
          <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>Users & Teams</Typography>

          <Box sx={{ maxWidth: 600 }}>
            <Alert severity="info" sx={{ mb: 3 }}>
              User and team management functionality coming soon. Contact your administrator to manage access.
            </Alert>

            <Typography variant="body2" color="text.secondary">
              Features include:
            </Typography>
            <ul>
              <li><Typography variant="body2">Add and remove users</Typography></li>
              <li><Typography variant="body2">Create teams and assign roles</Typography></li>
              <li><Typography variant="body2">Configure role-based access control (RBAC)</Typography></li>
              <li><Typography variant="body2">Manage API keys and tokens</Typography></li>
            </ul>
          </Box>
        </TabPanel>
      </Paper>
    </Box>
  );
};

export default Settings;
