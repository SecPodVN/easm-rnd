"""
Filters for the Example domain API.
"""
from django_filters import rest_framework as filters
from easm.example.models import Todo
from easm.core.filters import BaseFilterSet


class TodoFilter(BaseFilterSet):
    """
    Filter set for Todo model.
    """
    status = filters.ChoiceFilter(choices=Todo.STATUS_CHOICES)
    priority = filters.ChoiceFilter(choices=Todo.PRIORITY_CHOICES)
    due_date_after = filters.DateTimeFilter(field_name='due_date', lookup_expr='gte')
    due_date_before = filters.DateTimeFilter(field_name='due_date', lookup_expr='lte')
    is_completed = filters.BooleanFilter(method='filter_is_completed')

    class Meta:
        model = Todo
        fields = ['status', 'priority', 'created_after', 'created_before',
                  'updated_after', 'updated_before', 'due_date_after',
                  'due_date_before', 'is_completed', 'search']

    def filter_is_completed(self, queryset, name, value):
        """Filter by completion status."""
        if value:
            return queryset.filter(status='completed')
        return queryset.exclude(status='completed')

    def filter_search(self, queryset, name, value):
        """Search in title and description."""
        from django.db.models import Q
        return queryset.filter(
            Q(title__icontains=value) | Q(description__icontains=value)
        )
