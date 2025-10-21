import pytest
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken
from todos.models import Todo


@pytest.fixture
def api_client():
    """Fixture for API client"""
    return APIClient()


@pytest.fixture
def user(db):
    """Fixture for creating a user"""
    return User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )


@pytest.fixture
def authenticated_client(api_client, user):
    """Fixture for authenticated API client"""
    refresh = RefreshToken.for_user(user)
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return api_client


@pytest.fixture
def todo(user):
    """Fixture for creating a todo"""
    return Todo.objects.create(
        title='Test Todo',
        description='Test Description',
        status='pending',
        priority='medium',
        user=user
    )


@pytest.mark.django_db
class TestTodoAPI:
    """Test Todo API endpoints"""
    
    def test_list_todos_unauthenticated(self, api_client):
        """Test that unauthenticated users cannot list todos"""
        response = api_client.get('/api/todos/')
        assert response.status_code == 401
    
    def test_list_todos_authenticated(self, authenticated_client, todo):
        """Test listing todos for authenticated user"""
        response = authenticated_client.get('/api/todos/')
        assert response.status_code == 200
        assert response.data['count'] >= 1
    
    def test_create_todo(self, authenticated_client):
        """Test creating a new todo"""
        data = {
            'title': 'New Todo',
            'description': 'New Description',
            'status': 'pending',
            'priority': 'high'
        }
        response = authenticated_client.post('/api/todos/', data)
        assert response.status_code == 201
        assert response.data['title'] == 'New Todo'
        assert response.data['priority'] == 'high'
    
    def test_get_todo_detail(self, authenticated_client, todo):
        """Test getting todo detail"""
        response = authenticated_client.get(f'/api/todos/{todo.id}/')
        assert response.status_code == 200
        assert response.data['id'] == todo.id
        assert response.data['title'] == todo.title
    
    def test_update_todo(self, authenticated_client, todo):
        """Test updating a todo"""
        data = {'status': 'completed'}
        response = authenticated_client.patch(f'/api/todos/{todo.id}/', data)
        assert response.status_code == 200
        assert response.data['status'] == 'completed'
    
    def test_delete_todo(self, authenticated_client, todo):
        """Test deleting a todo"""
        response = authenticated_client.delete(f'/api/todos/{todo.id}/')
        assert response.status_code == 204
        assert Todo.objects.filter(id=todo.id).count() == 0
    
    def test_complete_todo_action(self, authenticated_client, todo):
        """Test completing a todo using the complete action"""
        response = authenticated_client.post(f'/api/todos/{todo.id}/complete/')
        assert response.status_code == 200
        assert response.data['status'] == 'completed'
        assert response.data['completed_at'] is not None
    
    def test_todo_statistics(self, authenticated_client, todo):
        """Test getting todo statistics"""
        response = authenticated_client.get('/api/todos/statistics/')
        assert response.status_code == 200
        assert 'total' in response.data
        assert 'pending' in response.data
        assert 'completed' in response.data
        assert 'completion_rate' in response.data
    
    def test_filter_by_status(self, authenticated_client, todo):
        """Test filtering todos by status"""
        response = authenticated_client.get('/api/todos/?status=pending')
        assert response.status_code == 200
        for item in response.data['results']:
            assert item['status'] == 'pending'
    
    def test_filter_by_priority(self, authenticated_client, todo):
        """Test filtering todos by priority"""
        response = authenticated_client.get(f'/api/todos/?priority={todo.priority}')
        assert response.status_code == 200
        for item in response.data['results']:
            assert item['priority'] == todo.priority
    
    def test_search_todos(self, authenticated_client, todo):
        """Test searching todos"""
        response = authenticated_client.get(f'/api/todos/?search={todo.title}')
        assert response.status_code == 200
        assert response.data['count'] >= 1
    
    def test_pagination(self, authenticated_client, user):
        """Test pagination"""
        # Create multiple todos
        for i in range(15):
            Todo.objects.create(
                title=f'Todo {i}',
                user=user,
                status='pending',
                priority='medium'
            )
        
        response = authenticated_client.get('/api/todos/?page_size=10')
        assert response.status_code == 200
        assert len(response.data['results']) == 10
        assert response.data['next'] is not None


@pytest.mark.django_db
class TestTodoModel:
    """Test Todo model"""
    
    def test_create_todo(self, user):
        """Test creating a todo"""
        todo = Todo.objects.create(
            title='Test Todo',
            description='Test Description',
            status='pending',
            priority='high',
            user=user
        )
        assert todo.id is not None
        assert todo.title == 'Test Todo'
        assert todo.status == 'pending'
        assert todo.user == user
    
    def test_todo_string_representation(self, todo):
        """Test todo string representation"""
        assert str(todo) == todo.title
    
    def test_todo_ordering(self, user):
        """Test that todos are ordered by created_at descending"""
        todo1 = Todo.objects.create(title='Todo 1', user=user, status='pending', priority='low')
        todo2 = Todo.objects.create(title='Todo 2', user=user, status='pending', priority='low')
        
        todos = Todo.objects.all()
        assert todos[0] == todo2
        assert todos[1] == todo1
