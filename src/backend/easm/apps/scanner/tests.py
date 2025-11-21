"""Tests for scanner app."""
from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status


class ScannerHealthCheckTestCase(APITestCase):
    """Test cases for scanner health check."""

    def test_health_check(self):
        """Test health check endpoint."""
        response = self.client.get('/api/scanner/healthStatus')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'healthy')
        self.assertEqual(response.data['service'], 'scanner')


class ResourceAPITestCase(APITestCase):
    """Test cases for Resource API endpoints."""

    def test_upload_resources(self):
        """Test uploading resources."""
        data = {
            'resources': [
                {
                    'name': 'test-resource-1',
                    'resource_type': 'ec2',
                    'region': 'us-east-1',
                    'tags': {'env': 'dev'}
                },
                {
                    'name': 'test-resource-2',
                    'resource_type': 's3',
                    'region': 'us-west-2'
                }
            ]
        }
        response = self.client.post('/api/scanner/uploadResources', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('count', response.data)

    def test_list_resources(self):
        """Test listing resources."""
        data = {
            'page_number': 1,
            'page_size': 10,
            'sort_by': 'name',
            'sort_order': 'asc'
        }
        response = self.client.post('/api/scanner/listResources', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('data', response.data)
        self.assertIn('total', response.data)


class RuleAPITestCase(APITestCase):
    """Test cases for Rule API endpoints."""

    def test_upload_rules(self):
        """Test uploading rules."""
        data = {
            'rules': [
                {
                    'name': 'test-rule-1',
                    'field': 'status',
                    'op': 'eq',
                    'value': 'running',
                    'severity': 'HIGH'
                }
            ]
        }
        response = self.client.post('/api/scanner/uploadRules', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('count', response.data)


class FindingAPITestCase(APITestCase):
    """Test cases for Finding API endpoints."""

    def test_list_findings(self):
        """Test listing findings."""
        response = self.client.get('/api/scanner/findings')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)

    def test_get_severity_status(self):
        """Test severity status endpoint."""
        response = self.client.get('/api/scanner/getSeverityStatus')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('CRITICAL', response.data)
        self.assertIn('HIGH', response.data)
        self.assertIn('MEDIUM', response.data)
        self.assertIn('LOW', response.data)
        self.assertIn('INFO', response.data)
