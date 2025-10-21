"""
REST API Tests
"""
from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from apps.todos.models import Todo


class APIRootTestCase(APITestCase):
    """Test cases for API root endpoint"""
    
    def test_api_root(self):
        """Test API root returns endpoint information"""
        response = self.client.get('/api/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('endpoints', response.data)
        self.assertIn('todos', response.data['endpoints'])


class TodoAPITestCase(APITestCase):
    """Test cases for Todo API endpoints"""
    
    def setUp(self):
        """Set up test data"""
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
        
        self.todo_data = {
            'title': 'Test Todo',
            'description': 'Test Description',
            'status': 'pending',
            'priority': 'medium'
        }
    
    def test_create_todo(self):
        """Test creating a todo via API"""
        response = self.client.post('/api/todos/', self.todo_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['title'], self.todo_data['title'])
    
    def test_list_todos(self):
        """Test listing todos via API"""
        Todo.objects.create(user=self.user, **self.todo_data)
        response = self.client.get('/api/todos/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_retrieve_todo(self):
        """Test retrieving a specific todo via API"""
        todo = Todo.objects.create(user=self.user, **self.todo_data)
        response = self.client.get(f'/api/todos/{todo.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], todo.title)
    
    def test_update_todo(self):
        """Test updating a todo via API"""
        todo = Todo.objects.create(user=self.user, **self.todo_data)
        update_data = {'title': 'Updated Title'}
        response = self.client.patch(f'/api/todos/{todo.id}/', update_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], update_data['title'])
    
    def test_delete_todo(self):
        """Test deleting a todo via API"""
        todo = Todo.objects.create(user=self.user, **self.todo_data)
        response = self.client.delete(f'/api/todos/{todo.id}/')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Todo.objects.filter(id=todo.id).exists())
    
    def test_complete_todo(self):
        """Test completing a todo via API"""
        todo = Todo.objects.create(user=self.user, **self.todo_data)
        response = self.client.post(f'/api/todos/{todo.id}/complete/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'completed')
    
    def test_todo_statistics(self):
        """Test getting todo statistics via API"""
        Todo.objects.create(user=self.user, status='pending', **{
            'title': 'Todo 1',
            'priority': 'low'
        })
        Todo.objects.create(user=self.user, status='completed', **{
            'title': 'Todo 2',
            'priority': 'high'
        })
        
        response = self.client.get('/api/todos/statistics/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['total'], 2)
        self.assertEqual(response.data['pending'], 1)
        self.assertEqual(response.data['completed'], 1)
    
    def test_authentication_required(self):
        """Test that authentication is required for API access"""
        self.client.force_authenticate(user=None)
        response = self.client.get('/api/todos/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
