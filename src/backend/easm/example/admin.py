"""
Admin configuration for Example domain app.
"""
from django.contrib import admin
from .models import Todo


@admin.register(Todo)
class TodoAdmin(admin.ModelAdmin):
    """Admin interface for Todo model."""

    list_display = ['title', 'user', 'status', 'priority', 'due_date', 'created_at']
    list_filter = ['status', 'priority', 'created_at', 'due_date']
    search_fields = ['title', 'description', 'user__username']
    readonly_fields = ['created_at', 'updated_at', 'completed_at']

    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'description', 'user')
        }),
        ('Status & Priority', {
            'fields': ('status', 'priority', 'due_date', 'completed_at')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

    def get_queryset(self, request):
        """Optimize queryset with select_related."""
        qs = super().get_queryset(request)
        return qs.select_related('user')
