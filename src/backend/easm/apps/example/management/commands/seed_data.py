"""
Django management command to seed database with sample data
"""
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from easm.apps.example.models import Todo
from django.utils import timezone
from datetime import timedelta
import random


class Command(BaseCommand):
    help = 'Seeds the database with sample data for testing APIs'

    def add_arguments(self, parser):
        parser.add_argument(
            '--users',
            type=int,
            default=3,
            help='Number of users to create (default: 3)'
        )
        parser.add_argument(
            '--todos-per-user',
            type=int,
            default=10,
            help='Number of todos per user (default: 10)'
        )
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing data before seeding'
        )

    def handle(self, *args, **options):
        num_users = options['users']
        todos_per_user = options['todos_per_user']
        clear_data = options['clear']

        if clear_data:
            self.stdout.write(self.style.WARNING('Clearing existing data...'))
            Todo.objects.all().delete()
            User.objects.filter(is_superuser=False).delete()
            self.stdout.write(self.style.SUCCESS('Data cleared!'))

        # Create users
        self.stdout.write(self.style.MIGRATE_HEADING('Creating users...'))
        users = []

        for i in range(1, num_users + 1):
            username = f'user{i}'
            email = f'user{i}@example.com'

            user, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'email': email,
                    'first_name': f'Test',
                    'last_name': f'User{i}'
                }
            )

            if created:
                user.set_password('password123')
                user.save()
                self.stdout.write(
                    self.style.SUCCESS(f'✓ Created user: {username} (password: password123)')
                )
            else:
                self.stdout.write(
                    self.style.WARNING(f'⚠ User {username} already exists')
                )

            users.append(user)

        # Create superuser if not exists
        if not User.objects.filter(username='admin').exists():
            admin = User.objects.create_superuser(
                username='admin',
                email='admin@example.com',
                password='admin123',
                first_name='Admin',
                last_name='User'
            )
            self.stdout.write(
                self.style.SUCCESS('✓ Created superuser: admin (password: admin123)')
            )
            users.append(admin)

        # Sample todo data
        todo_titles = [
            'Complete project documentation',
            'Review pull requests',
            'Update dependencies',
            'Fix bug in authentication',
            'Implement new feature',
            'Write unit tests',
            'Deploy to staging',
            'Database optimization',
            'Code review meeting',
            'Update API documentation',
            'Refactor legacy code',
            'Security audit',
            'Performance testing',
            'User feedback analysis',
            'Sprint planning',
            'Design system update',
            'Configure CI/CD pipeline',
            'Monitor application logs',
            'Backup database',
            'Client presentation'
        ]

        todo_descriptions = [
            'Need to complete this task as soon as possible',
            'This is a high priority task for the sprint',
            'Regular maintenance task',
            'Important for the next release',
            'Requested by the product team',
            'Technical debt item',
            'Enhancement request from users',
            'Part of the quarterly goals',
            'Critical for production stability',
            'Nice to have feature'
        ]

        statuses = ['pending', 'in_progress', 'completed']
        priorities = ['low', 'medium', 'high']

        # Create todos for each user
        self.stdout.write(self.style.MIGRATE_HEADING('\nCreating todos...'))
        total_todos = 0

        for user in users:
            for i in range(todos_per_user):
                title = random.choice(todo_titles)
                description = random.choice(todo_descriptions)
                status = random.choice(statuses)
                priority = random.choice(priorities)

                # Random due date (between now and 30 days from now)
                days_ahead = random.randint(1, 30)
                due_date = timezone.now() + timedelta(days=days_ahead)

                # Set completed_at if status is completed
                completed_at = None
                if status == 'completed':
                    completed_at = timezone.now() - timedelta(days=random.randint(1, 10))

                todo = Todo.objects.create(
                    user=user,
                    title=f'{title} #{i+1}',
                    description=description,
                    status=status,
                    priority=priority,
                    due_date=due_date,
                    completed_at=completed_at
                )
                total_todos += 1

            self.stdout.write(
                self.style.SUCCESS(f'✓ Created {todos_per_user} todos for {user.username}')
            )

        # Summary
        self.stdout.write('\n' + '=' * 60)
        self.stdout.write(self.style.SUCCESS('\n✨ Database seeding completed!\n'))
        self.stdout.write(self.style.MIGRATE_HEADING('Summary:'))
        self.stdout.write(f'  • Total users: {len(users)}')
        self.stdout.write(f'  • Total todos: {total_todos}')
        self.stdout.write(f'  • Todos per user: {todos_per_user}')

        self.stdout.write('\n' + self.style.MIGRATE_HEADING('Test Credentials:'))
        self.stdout.write('  • Superuser: admin / admin123')
        for i in range(1, num_users + 1):
            self.stdout.write(f'  • User{i}: user{i} / password123')

        self.stdout.write('\n' + self.style.MIGRATE_HEADING('API Endpoints:'))
        self.stdout.write('  • Token: POST /api/token/')
        self.stdout.write('  • Examples: GET/POST /api/example/')
        self.stdout.write('  • Detail: GET/PUT/PATCH/DELETE /api/example/{id}/')
        self.stdout.write('  • Complete: POST /api/example/{id}/complete/')
        self.stdout.write('  • Stats: GET /api/example/stats/')
        self.stdout.write('  • Overdue: GET /api/example/overdue/')
        self.stdout.write('=' * 60 + '\n')
