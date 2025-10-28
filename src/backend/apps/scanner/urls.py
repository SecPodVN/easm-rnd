"""URL configuration for scanner app."""
from django.urls import path
from . import views

app_name = 'scanner'

urlpatterns = [
    # Health check
    path('healthStatus', views.health_check, name='health-check'),

    # Resources
    path('uploadResources', views.upload_resources, name='upload-resources'),
    path('listResources', views.list_resources, name='list-resources'),
    path('deleteResources', views.delete_resources, name='delete-resources'),

    # Rules
    path('uploadRules', views.upload_rules, name='upload-rules'),
    path('deleteRules', views.delete_rules, name='delete-rules'),

    # Findings
    path('findings', views.list_findings, name='list-findings'),

    # Scanning
    path('scanResources', views.scan_resources, name='scan-resources'),

    # Analytics
    path('getSeverityStatus', views.get_severity_status, name='severity-status'),
    path('getIssuesBasedOnResourceTypes', views.get_issues_by_resource_type, name='issues-by-resource-type'),
    path('getIssuesBasedOnRegions', views.get_issues_by_region, name='issues-by-region'),
]
