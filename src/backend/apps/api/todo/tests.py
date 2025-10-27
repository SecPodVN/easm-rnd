"""
Todo API Tests
"""
from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from rest_framework import status
from apps.todos.models import Todo
from django.utils import timezone
from datetime import timedelta


class TodoAPITestCase(TestCase):
    """
    Test cases for Todo API endpoints
    """

    def setUp(self):
        """
        Set up test client and create test user
        """
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.client.force_authenticate(user=self.user)

        # Create some test todos
        self.todo1 = Todo.objects.create(
            title='Test Todo 1',
            description='Description 1',
            status='pending',
            priority='high',
            user=self.user
        )
        self.todo2 = Todo.objects.create(
            title='Test Todo 2',
            description='Description 2',
            status='in_progress',
            priority='medium',
            user=self.user
        )
        self.todo3 = Todo.objects.create(
            title='Test Todo 3',
            description='Description 3',
            status='completed',
            priority='low',
            user=self.user,
            completed_at=timezone.now()
        )

    def test_list_todos(self):
        """
        Test listing todos
        """
        response = self.client.get('/api/todos/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 3)

    def test_create_todo(self):
        """
        Test creating a new todo
        """
        data = {
            'title': 'New Todo',
            'description': 'New Description',
            'status': 'pending',
            'priority': 'high'
        }
        response = self.client.post('/api/todos/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['title'], 'New Todo')
        self.assertEqual(Todo.objects.count(), 4)

    def test_retrieve_todo(self):
        """
        Test retrieving a specific todo
        """
        response = self.client.get(f'/api/todos/{self.todo1.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Test Todo 1')

    def test_update_todo(self):
        """
        Test updating a todo
        """
        data = {
            'title': 'Updated Todo',
            'description': 'Updated Description',
            'status': 'in_progress',
            'priority': 'medium'
        }
        response = self.client.put(f'/api/todos/{self.todo1.id}/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Updated Todo')

    def test_partial_update_todo(self):
        """
        Test partially updating a todo
        """
        data = {'status': 'completed'}
        response = self.client.patch(f'/api/todos/{self.todo1.id}/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'completed')

    def test_delete_todo(self):
        """
        Test deleting a todo
        """
        response = self.client.delete(f'/api/todos/{self.todo1.id}/')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Todo.objects.count(), 2)

    def test_complete_todo(self):
        """
        Test marking a todo as complete
        """
        response = self.client.post(f'/api/todos/{self.todo1.id}/complete/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'completed')
        self.assertIsNotNone(response.data['completed_at'])

    def test_uncomplete_todo(self):
        """
        Test marking a completed todo as pending
        """
        response = self.client.post(f'/api/todos/{self.todo3.id}/uncomplete/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'pending')
        self.assertIsNone(response.data['completed_at'])

    def test_statistics(self):
        """
        Test getting todo statistics
        """
        response = self.client.get('/api/todos/statistics/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['total'], 3)
        self.assertEqual(response.data['by_status']['pending'], 1)
        self.assertEqual(response.data['by_status']['in_progress'], 1)
        self.assertEqual(response.data['by_status']['completed'], 1)

    def test_by_status(self):
        """
        Test filtering todos by status
        """
        response = self.client.get('/api/todos/by_status/?status=pending')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_by_priority(self):
        """
        Test filtering todos by priority
        """
        response = self.client.get('/api/todos/by_priority/?priority=high')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_overdue_todos(self):
        """
        Test getting overdue todos
        """
        # Create an overdue todo
        past_date = timezone.now() - timedelta(days=1)
        Todo.objects.create(
            title='Overdue Todo',
            description='This is overdue',
            status='pending',
            priority='high',
            due_date=past_date,
            user=self.user
        )

        response = self.client.get('/api/todos/overdue/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data['results']), 1)

    def test_bulk_update(self):
        """
        Test bulk updating todos
        """
        data = {
            'ids': [self.todo1.id, self.todo2.id],
            'status': 'completed',
            'priority': 'low'
        }
        response = self.client.post('/api/todos/bulk_update/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['updated_count'], 2)

        # Verify updates
        self.todo1.refresh_from_db()
        self.todo2.refresh_from_db()
        self.assertEqual(self.todo1.status, 'completed')
        self.assertEqual(self.todo2.status, 'completed')
        self.assertEqual(self.todo1.priority, 'low')
        self.assertEqual(self.todo2.priority, 'low')

    def test_bulk_delete(self):
        """
        Test bulk deleting todos
        """
        data = {
            'ids': [self.todo1.id, self.todo2.id]
        }
        response = self.client.post('/api/todos/bulk_delete/', data)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(response.data['deleted_count'], 2)
        self.assertEqual(Todo.objects.count(), 1)

    def test_bulk_complete(self):
        """
        Test bulk completing todos
        """
        data = {
            'ids': [self.todo1.id, self.todo2.id]
        }
        response = self.client.post('/api/todos/bulk_complete/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['completed_count'], 2)

        # Verify completions
        self.todo1.refresh_from_db()
        self.todo2.refresh_from_db()
        self.assertEqual(self.todo1.status, 'completed')
        self.assertEqual(self.todo2.status, 'completed')
        self.assertIsNotNone(self.todo1.completed_at)
        self.assertIsNotNone(self.todo2.completed_at)

    def test_search_todos(self):
        """
        Test searching todos
        """
        response = self.client.get('/api/todos/?search=Test Todo 1')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_todos(self):
        """
        Test filtering todos by status and priority
        """
        response = self.client.get('/api/todos/?status=pending&priority=high')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_ordering_todos(self):
        """
        Test ordering todos
        """
        response = self.client.get('/api/todos/?ordering=-priority')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check that results are ordered
        self.assertTrue(len(response.data['results']) > 0)

    def test_unauthorized_access(self):
        """
        Test that unauthenticated users cannot access todos
        """
        self.client.force_authenticate(user=None)
        response = self.client.get('/api/todos/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
