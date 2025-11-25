"""
Management command to create a superuser with profile
"""
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from easm.auth.models import UserProfile


class Command(BaseCommand):
    help = 'Create a superuser with profile'

    def add_arguments(self, parser):
        parser.add_argument('--username', type=str, help='Username for the superuser')
        parser.add_argument('--email', type=str, help='Email for the superuser')
        parser.add_argument('--password', type=str, help='Password for the superuser')
        parser.add_argument('--organization', type=str, help='Organization name', default='')
        parser.add_argument('--job-title', type=str, help='Job title', default='Administrator')
        parser.add_argument('--phone', type=str, help='Phone number', default='')

    def handle(self, *args, **options):
        username = options.get('username')
        email = options.get('email')
        password = options.get('password')

        # Interactive mode if arguments not provided
        if not username:
            username = input('Username: ')
        if not email:
            email = input('Email: ')
        if not password:
            from getpass import getpass
            password = getpass('Password: ')
            password_confirm = getpass('Password (again): ')
            if password != password_confirm:
                self.stdout.write(self.style.ERROR('Passwords do not match'))
                return

        # Check if user exists
        if User.objects.filter(username=username).exists():
            self.stdout.write(self.style.ERROR(f'User "{username}" already exists'))
            return

        # Create superuser
        user = User.objects.create_superuser(
            username=username,
            email=email,
            password=password
        )

        # Update or create profile
        profile, created = UserProfile.objects.get_or_create(user=user)
        if options.get('organization'):
            profile.organization = options['organization']
        if options.get('job_title'):
            profile.job_title = options['job_title']
        if options.get('phone'):
            profile.phone_number = options['phone']
        profile.save()

        self.stdout.write(self.style.SUCCESS(f'Superuser "{username}" created successfully'))
        if profile.organization:
            self.stdout.write(self.style.SUCCESS(f'  Organization: {profile.organization}'))
        if profile.job_title:
            self.stdout.write(self.style.SUCCESS(f'  Job Title: {profile.job_title}'))
