"""
Management command to deactivate/activate users
"""
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User


class Command(BaseCommand):
    help = 'Activate or deactivate user accounts'

    def add_arguments(self, parser):
        parser.add_argument('username', type=str, help='Username to activate/deactivate')
        parser.add_argument(
            '--activate',
            action='store_true',
            help='Activate the user (default is deactivate)'
        )

    def handle(self, *args, **options):
        username = options['username']
        activate = options['activate']

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            self.stdout.write(self.style.ERROR(f'User "{username}" does not exist'))
            return

        if activate:
            if user.is_active:
                self.stdout.write(self.style.WARNING(f'User "{username}" is already active'))
            else:
                user.is_active = True
                user.save()
                self.stdout.write(self.style.SUCCESS(f'User "{username}" has been activated'))
        else:
            if not user.is_active:
                self.stdout.write(self.style.WARNING(f'User "{username}" is already inactive'))
            else:
                user.is_active = False
                user.save()
                self.stdout.write(self.style.SUCCESS(f'User "{username}" has been deactivated'))
