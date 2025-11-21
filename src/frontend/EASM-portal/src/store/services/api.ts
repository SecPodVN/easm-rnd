import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

// Types for EASM entities
export interface Asset {
  id: string;
  name: string;
  type: string;
  ip?: string;
  domain?: string;
  status: 'active' | 'inactive' | 'scanning';
  discoveredAt: string;
  lastScanned?: string;
  riskScore: number;
  vulnerabilities: number;
  tags: string[];
}

export interface Issue {
  id: string;
  title: string;
  description: string;
  severity: 'critical' | 'high' | 'medium' | 'low' | 'info';
  status: 'open' | 'in-progress' | 'resolved' | 'ignored';
  assetId: string;
  assetName: string;
  cve?: string;
  cvss?: number;
  discoveredAt: string;
  resolvedAt?: string;
  affectedAssets: number;
}

export interface Scan {
  id: string;
  name: string;
  type: 'full' | 'quick' | 'targeted';
  status: 'running' | 'completed' | 'failed' | 'cancelled';
  startedAt: string;
  completedAt?: string;
  assetsScanned: number;
  issuesFound: number;
  progress: number;
}

export interface DashboardMetrics {
  totalAssets: number;
  totalIssues: number;
  securityScore: number;
  newAssets: number;
  newIssues: number;
  criticalIssues: number;
  highIssues: number;
  mediumIssues: number;
  lowIssues: number;
  infoIssues: number;
}

// Mock data for development (remove when backend is ready)
const mockAssets: Asset[] = [
  {
    id: '1',
    name: 'web-server-01',
    type: 'Server',
    ip: '192.168.1.10',
    domain: 'example.com',
    status: 'active',
    discoveredAt: '2024-11-01T10:00:00Z',
    lastScanned: '2024-11-20T08:30:00Z',
    riskScore: 75,
    vulnerabilities: 12,
    tags: ['production', 'web'],
  },
  {
    id: '2',
    name: 'db-server-01',
    type: 'Database',
    ip: '192.168.1.20',
    status: 'active',
    discoveredAt: '2024-10-15T14:20:00Z',
    lastScanned: '2024-11-19T22:15:00Z',
    riskScore: 85,
    vulnerabilities: 8,
    tags: ['production', 'database'],
  },
];

const mockIssues: Issue[] = [
  {
    id: '1',
    title: 'SQL Injection Vulnerability',
    description: 'Potential SQL injection in login form',
    severity: 'critical',
    status: 'open',
    assetId: '2',
    assetName: 'db-server-01',
    cve: 'CVE-2024-1234',
    cvss: 9.8,
    discoveredAt: '2024-11-20T08:30:00Z',
    affectedAssets: 1,
  },
  {
    id: '2',
    title: 'Outdated SSL/TLS Configuration',
    description: 'Server supports deprecated TLS 1.0',
    severity: 'high',
    status: 'in-progress',
    assetId: '1',
    assetName: 'web-server-01',
    cvss: 7.5,
    discoveredAt: '2024-11-18T15:20:00Z',
    affectedAssets: 3,
  },
];

const mockMetrics: DashboardMetrics = {
  totalAssets: 131542,
  totalIssues: 8234,
  securityScore: 78,
  newAssets: 145,
  newIssues: 42,
  criticalIssues: 23,
  highIssues: 156,
  mediumIssues: 1234,
  lowIssues: 5678,
  infoIssues: 1143,
};

// RTK Query API definition
export const easmApi = createApi({
  reducerPath: 'easmApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api',
    // Add auth headers when needed
    prepareHeaders: (headers) => {
      const token = localStorage.getItem('token');
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  tagTypes: ['Assets', 'Issues', 'Scans', 'Metrics'],
  endpoints: (builder) => ({
    // Assets endpoints
    getAssets: builder.query<Asset[], { dateRange?: any; types?: string[]; search?: string }>({
      // Mock implementation - replace with real endpoint when backend is ready
      queryFn: async () => {
        await new Promise((resolve) => setTimeout(resolve, 500)); // Simulate network delay
        return { data: mockAssets };
      },
      providesTags: ['Assets'],
      // When backend is ready, uncomment this:
      // query: ({ dateRange, types, search }) => ({
      //   url: '/assets',
      //   params: { dateRange, types, search },
      // }),
    }),

    getAssetById: builder.query<Asset, string>({
      queryFn: async (id) => {
        await new Promise((resolve) => setTimeout(resolve, 300));
        const asset = mockAssets.find((a) => a.id === id);
        return asset ? { data: asset } : { error: { status: 404, data: 'Not found' } };
      },
      providesTags: (result, error, id) => [{ type: 'Assets', id }],
    }),

    // Issues endpoints
    getIssues: builder.query<Issue[], { severity?: string[]; status?: string[]; search?: string }>({
      queryFn: async () => {
        await new Promise((resolve) => setTimeout(resolve, 500));
        return { data: mockIssues };
      },
      providesTags: ['Issues'],
    }),

    getIssueById: builder.query<Issue, string>({
      queryFn: async (id) => {
        await new Promise((resolve) => setTimeout(resolve, 300));
        const issue = mockIssues.find((i) => i.id === id);
        return issue ? { data: issue } : { error: { status: 404, data: 'Not found' } };
      },
      providesTags: (result, error, id) => [{ type: 'Issues', id }],
    }),

    // Dashboard metrics
    getDashboardMetrics: builder.query<DashboardMetrics, { dateRange?: any }>({
      queryFn: async () => {
        await new Promise((resolve) => setTimeout(resolve, 400));
        return { data: mockMetrics };
      },
      providesTags: ['Metrics'],
    }),

    // Scans endpoints
    getScans: builder.query<Scan[], void>({
      queryFn: async () => {
        await new Promise((resolve) => setTimeout(resolve, 500));
        return { data: [] };
      },
      providesTags: ['Scans'],
    }),

    startScan: builder.mutation<Scan, { name: string; type: string; targets?: string[] }>({
      queryFn: async (params) => {
        await new Promise((resolve) => setTimeout(resolve, 1000));
        return {
          data: {
            id: Date.now().toString(),
            name: params.name,
            type: params.type as any,
            status: 'running',
            startedAt: new Date().toISOString(),
            assetsScanned: 0,
            issuesFound: 0,
            progress: 0,
          },
        };
      },
      invalidatesTags: ['Scans'],
    }),
  }),
});

// Export hooks for usage in components
export const {
  useGetAssetsQuery,
  useGetAssetByIdQuery,
  useGetIssuesQuery,
  useGetIssueByIdQuery,
  useGetDashboardMetricsQuery,
  useGetScansQuery,
  useStartScanMutation,
} = easmApi;
