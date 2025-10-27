"""
REST API Views - Centralized REST API business logic
"""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny


@api_view(['GET'])
@permission_classes([AllowAny])
def api_root(request):
    """
    API Root endpoint - provides information about available endpoints
    """
    # Base URL patterns
    TODO_BASE = '/api/todos/'
    TODO_DETAIL = '/api/todos/{id}/'

    return Response({
        'message': 'EASM REST API',
        'version': '1.0.0',
        'endpoints': {
            'auth': {
                'token_obtain': '/api/token/',
                'token_refresh': '/api/token/refresh/',
            },
            'todos': {
                'list': TODO_BASE,
                'create': TODO_BASE,
                'retrieve': TODO_DETAIL,
                'update': TODO_DETAIL,
                'delete': TODO_DETAIL,
                'complete': f'{TODO_DETAIL}complete/',
                'uncomplete': f'{TODO_DETAIL}uncomplete/',
                'my_todos': f'{TODO_BASE}my_todos/',
                'statistics': f'{TODO_BASE}statistics/',
                'overdue': f'{TODO_BASE}overdue/',
                'by_status': f'{TODO_BASE}by_status/?status={{status}}',
                'by_priority': f'{TODO_BASE}by_priority/?priority={{priority}}',
                'bulk_update': f'{TODO_BASE}bulk_update/',
                'bulk_delete': f'{TODO_BASE}bulk_delete/',
                'bulk_complete': f'{TODO_BASE}bulk_complete/',
            },
            'docs': {
                'swagger': '/api/docs/',
                'redoc': '/api/redoc/',
                'schema': '/api/schema/',
            }
        }
    })
