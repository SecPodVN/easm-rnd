"""
Common filter classes for API endpoints.
Shared filters for all apps
"""
from django_filters import rest_framework as filters


class BaseFilterSet(filters.FilterSet):
    """
    Base filter set with common filters for timestamped models.
    """
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')
    updated_after = filters.DateTimeFilter(field_name='updated_at', lookup_expr='gte')
    updated_before = filters.DateTimeFilter(field_name='updated_at', lookup_expr='lte')

    search = filters.CharFilter(method='filter_search')

    def filter_search(self, queryset, name, value):
        """
        Override this method in child classes to implement search functionality.
        """
        return queryset


class ActiveObjectsFilter(filters.FilterSet):
    """
    Filter for objects with soft delete functionality.
    """
    is_active = filters.BooleanFilter(field_name='is_deleted', method='filter_is_active')

    def filter_is_active(self, queryset, name, value):
        if value:
            return queryset.filter(is_deleted=False)
        return queryset.filter(is_deleted=True)
