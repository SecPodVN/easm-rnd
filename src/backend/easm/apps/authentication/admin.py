"""
Authentication admin configuration
"""
from django.contrib import admin
from .models import UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'organization', 'job_title', 'created_at']
    search_fields = ['user__username', 'user__email', 'organization']
    list_filter = ['created_at', 'organization']
