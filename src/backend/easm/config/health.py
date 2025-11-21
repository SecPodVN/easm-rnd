from django.http import JsonResponse
from django.db import connections
from django.conf import settings
import redis


def health_check(request):
    """
    Health check endpoint for monitoring
    """
    health_status = {
        'status': 'healthy',
        'components': {}
    }
    overall_status = 200

    # Check database
    try:
        connections['default'].cursor()
        health_status['components']['database'] = 'healthy'
    except Exception as e:
        health_status['components']['database'] = f'unhealthy: {str(e)}'
        health_status['status'] = 'unhealthy'
        overall_status = 503

    # Check Redis
    try:
        r = redis.Redis(
            host=settings.CACHES['default']['LOCATION'].split('://')[1].split(':')[0],
            port=int(settings.CACHES['default']['LOCATION'].split(':')[-1].split('/')[0]),
            decode_responses=True
        )
        r.ping()
        health_status['components']['redis'] = 'healthy'
    except Exception as e:
        health_status['components']['redis'] = f'unhealthy: {str(e)}'
        health_status['status'] = 'unhealthy'
        overall_status = 503

    # Check MongoDB (for scanner service)
    try:
        from easm.apps.scanner.db import get_mongodb
        db = get_mongodb()
        if db is not None:
            # Ping MongoDB to verify connection
            db.client.admin.command('ping')
            health_status['components']['mongodb'] = 'healthy'
        else:
            health_status['components']['mongodb'] = 'not configured'
    except Exception as e:
        health_status['components']['mongodb'] = f'unhealthy: {str(e)}'
        health_status['status'] = 'unhealthy'
        overall_status = 503

    return JsonResponse(health_status, status=overall_status)


def readiness_check(request):
    """
    Readiness check - is the application ready to serve traffic
    """
    return JsonResponse({'status': 'ready'}, status=200)


def liveness_check(request):
    """
    Liveness check - is the application alive
    """
    return JsonResponse({'status': 'alive'}, status=200)
