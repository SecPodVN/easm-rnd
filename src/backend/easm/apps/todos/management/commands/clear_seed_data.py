"""
Clear all seed data from database
"""
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from easm.apps.todos.models import Todo


class Command(BaseCommand):
    help = 'Clears all seed data (non-superuser users and their todos)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--all',
            action='store_true',
            help='Clear all data including superusers'
        )
        parser.add_argument(
            '--confirm',
            action='store_true',
            help='Skip confirmation prompt'
        )

    def handle(self, *args, **options):
        clear_all = options['all']
        skip_confirm = options['confirm']

        if not skip_confirm:
            if clear_all:
                msg = 'This will delete ALL users and todos. Continue? [y/N] '
            else:
                msg = 'This will delete all non-superuser users and todos. Continue? [y/N] '

            confirm = input(msg)
            if confirm.lower() != 'y':
                self.stdout.write(self.style.WARNING('Operation cancelled'))
                return

        # Delete todos
        todo_count = Todo.objects.count()
        Todo.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(f'✓ Deleted {todo_count} todos'))

        # Delete users
        if clear_all:
            user_count = User.objects.count()
            User.objects.all().delete()
            self.stdout.write(self.style.SUCCESS(f'✓ Deleted {user_count} users'))
        else:
            user_count = User.objects.filter(is_superuser=False).count()
            User.objects.filter(is_superuser=False).delete()
            self.stdout.write(self.style.SUCCESS(f'✓ Deleted {user_count} non-superuser users'))

        self.stdout.write(self.style.SUCCESS('\n✨ Database cleared successfully!'))
