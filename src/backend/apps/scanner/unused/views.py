"""Views for scanner app with MongoDB CRUD operations using ViewSets."""
from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse

from .models import Resource, Rule, Finding
from .serializers import (
    ResourceSerializer, ResourceUploadSerializer, ResourceListSerializer,
    RuleSerializer, RuleUploadSerializer, FindingSerializer,
    DeleteSerializer, SeverityStatusSerializer,
    ResourceTypeIssueSerializer, RegionIssueSerializer
)
from .engine import ScanEngine


# Keep health check as a simple function-based view
@extend_schema(
    tags=['Scanner - Health'],
    summary='Health check endpoint',
    description='Returns a simple health check message to verify the scanner service is running.',
    responses={200: OpenApiResponse(description='Service is healthy')}
)
@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """Health check endpoint."""
    return Response({
        'status': 'healthy',
        'service': 'scanner',
        'message': 'Scanner service is running'
    })


class ResourceViewSet(viewsets.ViewSet):
    """
    ViewSet for Resource CRUD operations with MongoDB.

    Provides:
    - upload: POST /api/scanner/resources/upload/
    - list: POST /api/scanner/resources/list/
    - delete: POST /api/scanner/resources/delete/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        tags=['Scanner - Resources'],
        summary='Upload resources in bulk',
        description='Bulk inserts an array of resource objects into the MongoDB resources collection.',
        request=ResourceUploadSerializer,
        responses={
            201: OpenApiResponse(description='Resources uploaded successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def upload(self, request):
        """Bulk upload resources."""
        serializer = ResourceUploadSerializer(data=request.data)
        if serializer.is_valid():
            resources = serializer.validated_data['resources']
            count = Resource.bulk_create(resources)
            return Response({
                'message': 'Resources uploaded successfully',
                'count': count
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Scanner - Resources'],
        summary='List resources with filtering and pagination',
        description='Returns a paginated list of resources matching the filter, with search and sort capabilities.',
        request=ResourceListSerializer,
        responses={
            200: OpenApiResponse(description='Resources retrieved successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'], url_path='list')
    def list_resources(self, request):
        """List resources with filtering, pagination, search, and sorting."""
        serializer = ResourceListSerializer(data=request.data)
        if serializer.is_valid():
            filter_dict = serializer.validated_data.get('filter', {})
            page_number = serializer.validated_data.get('page_number', 1)
            page_size = serializer.validated_data.get('page_size', 10)
            sort_by = serializer.validated_data.get('sort_by', 'name')
            sort_order = serializer.validated_data.get('sort_order', 'asc')
            search_str = serializer.validated_data.get('search_str', None)

            skip = (page_number - 1) * page_size

            result = Resource.find_all(
                filter_dict=filter_dict,
                skip=skip,
                limit=page_size,
                sort_by=sort_by,
                sort_order=sort_order,
                search_str=search_str
            )

            return Response(result, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Scanner - Resources'],
        summary='Delete resources by filter',
        description='Deletes resources matching the specified MongoDB filter.',
        request=DeleteSerializer,
        responses={
            200: OpenApiResponse(description='Resources deleted successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def delete(self, request):
        """Delete resources matching filter."""
        serializer = DeleteSerializer(data=request.data)
        if serializer.is_valid():
            filter_dict = serializer.validated_data['filter']
            count = Resource.bulk_delete(filter_dict)
            return Response({
                'message': 'Resources deleted successfully',
                'count': count
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class RuleViewSet(viewsets.ViewSet):
    """
    ViewSet for Rule CRUD operations with MongoDB.

    Provides:
    - upload: POST /api/scanner/rules/upload/
    - delete: POST /api/scanner/rules/delete/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        tags=['Scanner - Rules'],
        summary='Upload rules in bulk',
        description='Bulk inserts an array of rule objects into the MongoDB rules collection.',
        request=RuleUploadSerializer,
        responses={
            201: OpenApiResponse(description='Rules uploaded successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def upload(self, request):
        """Bulk upload rules."""
        serializer = RuleUploadSerializer(data=request.data)
        if serializer.is_valid():
            rules = serializer.validated_data['rules']
            count = Rule.bulk_create(rules)
            return Response({
                'message': 'Rules uploaded successfully',
                'count': count
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Scanner - Rules'],
        summary='Delete rules by filter',
        description='Deletes rules matching the specified MongoDB filter.',
        request=DeleteSerializer,
        responses={
            200: OpenApiResponse(description='Rules deleted successfully'),
            400: OpenApiResponse(description='Invalid request data')
        }
    )
    @action(detail=False, methods=['post'])
    def delete(self, request):
        """Delete rules matching filter."""
        serializer = DeleteSerializer(data=request.data)
        if serializer.is_valid():
            filter_dict = serializer.validated_data['filter']
            count = Rule.bulk_delete(filter_dict)
            return Response({
                'message': 'Rules deleted successfully',
                'count': count
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class FindingViewSet(viewsets.ViewSet):
    """
    ViewSet for Finding operations and analytics with MongoDB.

    Provides:
    - list: GET /api/scanner/findings/
    - severity_status: GET /api/scanner/findings/severity_status/
    - by_resource_type: GET /api/scanner/findings/by_resource_type/
    - by_region: GET /api/scanner/findings/by_region/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        tags=['Scanner - Findings'],
        summary='List all findings',
        description='Returns all findings from the findings collection. Each finding represents a detected issue from resource scanning.',
        responses={
            200: OpenApiResponse(
                response=FindingSerializer(many=True),
                description='Findings retrieved successfully'
            )
        }
    )
    def list(self, request):
        """List all findings."""
        findings = Finding.find_all()
        return Response(findings, status=status.HTTP_200_OK)

    @extend_schema(
        tags=['Scanner - Analytics'],
        summary='Get severity status summary',
        description='Aggregates findings by severity level (CRITICAL, HIGH, MEDIUM, LOW, INFO).',
        responses={
            200: OpenApiResponse(
                response=SeverityStatusSerializer,
                description='Severity summary retrieved successfully'
            )
        }
    )
    @action(detail=False, methods=['get'])
    def severity_status(self, request):
        """Get findings count by severity."""
        severity_counts = Finding.get_severity_summary()
        return Response(severity_counts, status=status.HTTP_200_OK)

    @extend_schema(
        tags=['Scanner - Analytics'],
        summary='Get issues by resource type',
        description='Aggregates findings by resource type.',
        responses={
            200: OpenApiResponse(
                response=ResourceTypeIssueSerializer(many=True),
                description='Resource type issues retrieved successfully'
            )
        }
    )
    @action(detail=False, methods=['get'])
    def by_resource_type(self, request):
        """Get findings grouped by resource type."""
        results = Finding.get_by_resource_type()
        return Response(results, status=status.HTTP_200_OK)

    @extend_schema(
        tags=['Scanner - Analytics'],
        summary='Get issues by region',
        description='Joins findings with resources to get region information and aggregates findings by region.',
        responses={
            200: OpenApiResponse(
                response=RegionIssueSerializer(many=True),
                description='Region issues retrieved successfully'
            )
        }
    )
    @action(detail=False, methods=['get'])
    def by_region(self, request):
        """Get findings grouped by region."""
        results = Finding.get_by_region()
        return Response(results, status=status.HTTP_200_OK)


class ScannerViewSet(viewsets.ViewSet):
    """
    ViewSet for scanning operations.

    Provides:
    - list: GET /api/scanner/scan/
    """
    permission_classes = [AllowAny]

    @extend_schema(
        tags=['Scanner - Scanning'],
        summary='Scan all resources against rules',
        description='Fetches all resources and rules, evaluates each resource against all rules using the logic engine, and creates findings for any matches.',
        responses={
            200: OpenApiResponse(description='Scan completed successfully')
        }
    )
    def list(self, request):
        """Scan all resources against all rules."""
        result = ScanEngine.scan_all_resources()
        return Response({
            'message': 'Scan completed successfully',
            'results': result
        }, status=status.HTTP_200_OK)
