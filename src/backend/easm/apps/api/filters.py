"""
REST API Filters - Custom filter classes
"""
from django_filters import rest_framework as filters
from easm.apps.todos.models import Todo


class TodoFilter(filters.FilterSet):
    """
    Advanced filtering for Todo model
    """
    title = filters.CharFilter(lookup_expr='icontains')
    description = filters.CharFilter(lookup_expr='icontains')
    status = filters.ChoiceFilter(choices=Todo.STATUS_CHOICES)
    priority = filters.ChoiceFilter(choices=Todo.PRIORITY_CHOICES)
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')
    due_after = filters.DateTimeFilter(field_name='due_date', lookup_expr='gte')
    due_before = filters.DateTimeFilter(field_name='due_date', lookup_expr='lte')
    is_overdue = filters.BooleanFilter(method='filter_overdue')

    class Meta:
        model = Todo
        fields = ['status', 'priority', 'title', 'description']

    def filter_overdue(self, queryset, name, value):
        """
        Filter overdue todos
        """
        from django.utils import timezone
        if value:
            return queryset.filter(
                due_date__lt=timezone.now(),
                status__in=['pending', 'in_progress']
            )
        return queryset
