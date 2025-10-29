"""
Scanner API Serializers
"""
from rest_framework import serializers


class ResourceSerializer(serializers.Serializer):
    """Serializer for Resource documents."""

    _id = serializers.CharField(read_only=True)
    name = serializers.CharField(required=True)
    resource_type = serializers.CharField(required=True)
    region = serializers.CharField(required=False, allow_blank=True)
    tags = serializers.DictField(required=False, default=dict)
    metadata = serializers.DictField(required=False, default=dict)
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)

    def to_internal_value(self, data):
        """Allow flexible fields for MongoDB."""
        validated_data = super().to_internal_value(data)
        for key, value in data.items():
            if key not in validated_data and key != '_id':
                validated_data[key] = value
        return validated_data


class ResourceUploadSerializer(serializers.Serializer):
    """Serializer for bulk resource upload."""

    resources = serializers.ListField(
        child=serializers.DictField(),
        required=True
    )


class ResourceListSerializer(serializers.Serializer):
    """Serializer for resource list request."""

    filter = serializers.DictField(required=False, default=dict)
    page_number = serializers.IntegerField(required=False, default=1, min_value=1)
    page_size = serializers.IntegerField(required=False, default=10, min_value=1, max_value=100)
    sort_by = serializers.CharField(required=False, default='name')
    sort_order = serializers.ChoiceField(choices=['asc', 'desc'], required=False, default='asc')
    search_str = serializers.CharField(required=False, allow_blank=True)


class RuleSerializer(serializers.Serializer):
    """Serializer for Rule documents."""

    _id = serializers.CharField(read_only=True)
    name = serializers.CharField(required=True)
    description = serializers.CharField(required=False, allow_blank=True)
    field = serializers.CharField(required=True)
    op = serializers.CharField(required=True)
    value = serializers.CharField(required=True)
    severity = serializers.ChoiceField(
        choices=['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO'],
        required=False,
        default='MEDIUM'
    )
    resource_type = serializers.CharField(required=False, allow_blank=True)
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)

    def to_internal_value(self, data):
        """Allow flexible fields for MongoDB."""
        validated_data = super().to_internal_value(data)
        for key, value in data.items():
            if key not in validated_data and key != '_id':
                validated_data[key] = value
        return validated_data


class RuleUploadSerializer(serializers.Serializer):
    """Serializer for bulk rule upload."""

    rules = serializers.ListField(
        child=serializers.DictField(),
        required=True
    )


class FindingSerializer(serializers.Serializer):
    """Serializer for Finding documents."""

    _id = serializers.CharField(read_only=True)
    resource_id = serializers.CharField(required=True)
    resource_name = serializers.CharField(required=True)
    resource_type = serializers.CharField(required=True)
    rule_name = serializers.CharField(required=True)
    rule_description = serializers.CharField(required=False, allow_blank=True)
    severity = serializers.CharField(required=True)
    field = serializers.CharField(required=True)
    actual_value = serializers.CharField(required=True)
    expected_value = serializers.CharField(required=True)
    created_at = serializers.DateTimeField(read_only=True)


class DeleteSerializer(serializers.Serializer):
    """Serializer for delete operations."""

    filter = serializers.DictField(required=True)


class SeverityStatusSerializer(serializers.Serializer):
    """Serializer for severity status response."""

    CRITICAL = serializers.IntegerField()
    HIGH = serializers.IntegerField()
    MEDIUM = serializers.IntegerField()
    LOW = serializers.IntegerField()
    INFO = serializers.IntegerField()


class ResourceTypeIssueSerializer(serializers.Serializer):
    """Serializer for issues by resource type."""

    resource_type = serializers.CharField()
    count = serializers.IntegerField()


class RegionIssueSerializer(serializers.Serializer):
    """Serializer for issues by region."""

    region = serializers.CharField()
    count = serializers.IntegerField()
