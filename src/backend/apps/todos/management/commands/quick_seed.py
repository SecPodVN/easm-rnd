"""
Quick seed command - seeds database with default values
"""
from django.core.management import call_command
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = 'Quick seed with default values (3 users, 10 todos each)'

    def handle(self, *args, **options):
        self.stdout.write(self.style.WARNING('Running quick seed with default values...'))
        call_command('seed_data', users=3, todos_per_user=10)
