"""
Tests for the Example domain app.
This serves as a template for testing domain logic.
"""
from django.test import TestCase
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta

from .models import Todo
from .services import TodoService
from easm.common.enums import TodoStatus, TodoPriority


class TodoModelTests(TestCase):
    """Tests for Todo model."""

    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

    def test_create_todo(self):
        """Test creating a todo."""
        todo = Todo.objects.create(
            user=self.user,
            title='Test Todo',
            description='Test description',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.HIGH.value
        )

        self.assertEqual(todo.title, 'Test Todo')
        self.assertEqual(todo.user, self.user)
        self.assertEqual(todo.status, TodoStatus.PENDING.value)
        self.assertIsNone(todo.completed_at)

    def test_mark_complete(self):
        """Test marking todo as complete."""
        todo = Todo.objects.create(
            user=self.user,
            title='Test Todo',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.MEDIUM.value
        )

        todo.mark_complete()
        todo.refresh_from_db()

        self.assertEqual(todo.status, TodoStatus.COMPLETED.value)
        self.assertIsNotNone(todo.completed_at)

    def test_todo_str(self):
        """Test string representation."""
        todo = Todo.objects.create(
            user=self.user,
            title='My Todo',
            priority=TodoPriority.LOW.value
        )

        self.assertEqual(str(todo), 'My Todo')


class TodoServiceTests(TestCase):
    """Tests for TodoService business logic."""

    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

    def test_get_user_statistics(self):
        """Test getting user statistics."""
        # Create sample todos
        Todo.objects.create(
            user=self.user,
            title='Pending Todo',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.LOW.value
        )
        Todo.objects.create(
            user=self.user,
            title='In Progress Todo',
            status=TodoStatus.IN_PROGRESS.value,
            priority=TodoPriority.MEDIUM.value
        )
        Todo.objects.create(
            user=self.user,
            title='Completed Todo',
            status=TodoStatus.COMPLETED.value,
            priority=TodoPriority.HIGH.value
        )

        stats = TodoService.get_user_statistics(self.user)

        self.assertEqual(stats['total_todos'], 3)
        self.assertEqual(stats['pending_todos'], 1)
        self.assertEqual(stats['in_progress_todos'], 1)
        self.assertEqual(stats['completed_todos'], 1)

    def test_mark_todo_complete(self):
        """Test service method for marking complete."""
        todo = Todo.objects.create(
            user=self.user,
            title='Test Todo',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.MEDIUM.value
        )

        updated_todo = TodoService.mark_todo_complete(todo.id)

        self.assertEqual(updated_todo.status, TodoStatus.COMPLETED.value)
        self.assertIsNotNone(updated_todo.completed_at)

    def test_bulk_update_priority(self):
        """Test bulk priority update."""
        todo1 = Todo.objects.create(
            user=self.user,
            title='Todo 1',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.LOW.value
        )
        todo2 = Todo.objects.create(
            user=self.user,
            title='Todo 2',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.LOW.value
        )

        updated_count = TodoService.bulk_update_priority(
            todo_ids=[todo1.id, todo2.id],
            priority=TodoPriority.HIGH.value
        )

        self.assertEqual(updated_count, 2)

        todo1.refresh_from_db()
        todo2.refresh_from_db()

        self.assertEqual(todo1.priority, TodoPriority.HIGH.value)
        self.assertEqual(todo2.priority, TodoPriority.HIGH.value)

    def test_get_overdue_todos(self):
        """Test getting overdue todos."""
        # Create overdue todo
        overdue_todo = Todo.objects.create(
            user=self.user,
            title='Overdue Todo',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.HIGH.value,
            due_date=timezone.now() - timedelta(days=1)
        )

        # Create future todo
        future_todo = Todo.objects.create(
            user=self.user,
            title='Future Todo',
            status=TodoStatus.PENDING.value,
            priority=TodoPriority.MEDIUM.value,
            due_date=timezone.now() + timedelta(days=1)
        )

        overdue_todos = TodoService.get_overdue_todos(self.user)

        self.assertEqual(overdue_todos.count(), 1)
        self.assertEqual(overdue_todos.first(), overdue_todo)


# TODO: Add API tests in apps/api/example/tests.py
# Example:
# from rest_framework.test import APITestCase
# from rest_framework import status
#
# class TodoAPITests(APITestCase):
#     def test_list_todos(self):
#         ...
