import React from 'react';
import { Card, CardContent, Typography, Box, Chip } from '@mui/material';
import { TrendingUp, TrendingDown } from '@mui/icons-material';

const StatCard = ({ icon, title, value, lastDays, change, variant = 'default' }) => {
  const isPositive = change >= 0;

  return (
    <Card
      sx={{
        width: 200,
        height: 200,
        display: 'flex',
        flexDirection: 'column',
        '&:hover': { boxShadow: 3 },
        transition: 'box-shadow 0.3s',
      }}
    >
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 1.5, gap: 1 }}>
          <Box
            sx={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: 32,
              height: 32,
              bgcolor: variant === 'default' ? '#0078d4' : variant === 'warning' ? '#ff8c00' : '#107c10',
              color: 'white',
              borderRadius: 1,
              fontSize: '1.2rem',
            }}
          >
            {icon}
          </Box>
        </Box>

        <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.75rem', mb: 1, minHeight: 32 }}>
          {title}
        </Typography>

        <Typography variant="h5" sx={{ fontWeight: 600, mb: 1.5 }}>
          {value}
        </Typography>

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
          <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.7rem' }}>
            Last {lastDays} Days
          </Typography>
          <Chip
            icon={isPositive ? <TrendingUp fontSize="small" /> : <TrendingDown fontSize="small" />}
            label={`${isPositive ? '+' : ''}${change}`}
            size="small"
            sx={{
              height: 18,
              fontSize: '0.65rem',
              bgcolor: isPositive ? '#e7f5e7' : '#fee',
              color: isPositive ? '#107c10' : '#d13438',
              alignSelf: 'flex-start',
              '& .MuiChip-icon': {
                fontSize: '0.75rem',
              },
            }}
          />
        </Box>
      </CardContent>
    </Card>
  );
};

export default StatCard;
