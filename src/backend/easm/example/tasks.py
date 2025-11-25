"""
Celery tasks for the Example domain app.
This serves as a template for implementing asynchronous tasks in domain apps.
"""
from celery import shared_task
from celery.utils.log import get_task_logger
from typing import List, Dict, Any

logger = get_task_logger(__name__)


@shared_task(bind=True, name='example.process_items')
def process_items_task(self, item_ids: List[int]) -> Dict[str, Any]:
    """
    Example async task to process multiple items.

    Args:
        item_ids: List of item IDs to process

    Returns:
        Dictionary with processing results
    """
    logger.info(f"Processing {len(item_ids)} items")

    try:
        # Import here to avoid circular imports
        from .models import Todo
        from .services import TodoService

        processed_count = 0
        failed_count = 0

        for item_id in item_ids:
            try:
                # Simulate processing logic
                todo = Todo.objects.get(id=item_id)
                # Example: Mark as completed
                TodoService.mark_todo_complete(todo_id=todo.id)
                processed_count += 1

                # Update task progress
                self.update_state(
                    state='PROGRESS',
                    meta={
                        'current': processed_count + failed_count,
                        'total': len(item_ids),
                        'status': f'Processing item {item_id}'
                    }
                )
            except Todo.DoesNotExist:
                logger.warning(f"Item {item_id} not found")
                failed_count += 1
            except Exception as e:
                logger.error(f"Error processing item {item_id}: {str(e)}")
                failed_count += 1

        result = {
            'success': True,
            'processed': processed_count,
            'failed': failed_count,
            'total': len(item_ids)
        }

        logger.info(f"Task completed: {result}")
        return result

    except Exception as e:
        logger.error(f"Task failed: {str(e)}")
        return {
            'success': False,
            'error': str(e)
        }


@shared_task(bind=True, name='example.periodic_cleanup')
def periodic_cleanup_task(self):
    """
    Example periodic task for cleanup operations.
    This can be scheduled in config/celery.py beat_schedule.
    """
    logger.info("Running periodic cleanup task")

    try:
        from .models import Todo
        from django.utils import timezone
        from datetime import timedelta

        # Example: Delete old completed items
        thirty_days_ago = timezone.now() - timedelta(days=30)
        deleted_count = Todo.objects.filter(
            completed=True,
            updated_at__lt=thirty_days_ago
        ).delete()[0]

        logger.info(f"Deleted {deleted_count} old completed items")
        return {'deleted': deleted_count}

    except Exception as e:
        logger.error(f"Cleanup task failed: {str(e)}")
        raise


@shared_task(name='example.send_notification')
def send_notification_task(user_id: int, message: str) -> bool:
    """
    Example task for sending notifications.

    Args:
        user_id: User ID to send notification to
        message: Notification message

    Returns:
        True if sent successfully
    """
    logger.info(f"Sending notification to user {user_id}")

    try:
        # Simulate notification sending
        # In real implementation, integrate with email/SMS/push service
        logger.info(f"Notification sent: {message}")
        return True
    except Exception as e:
        logger.error(f"Failed to send notification: {str(e)}")
        return False
