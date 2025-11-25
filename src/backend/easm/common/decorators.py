"""
Common decorators
"""
import functools
import time
import logging
from typing import Callable, Any

logger = logging.getLogger(__name__)


def timer(func: Callable) -> Callable:
    """
    Decorator to measure function execution time

    Usage:
        @timer
        def my_function():
            pass
    """
    @functools.wraps(func)
    def wrapper(*args, **kwargs) -> Any:
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        logger.info(f"{func.__name__} took {end_time - start_time:.4f} seconds")
        return result
    return wrapper


def retry(max_attempts: int = 3, delay: float = 1.0):
    """
    Decorator to retry a function on failure

    Usage:
        @retry(max_attempts=3, delay=2.0)
        def my_function():
            pass
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs) -> Any:
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    logger.warning(
                        f"{func.__name__} failed (attempt {attempt + 1}/{max_attempts}): {e}. "
                        f"Retrying in {delay}s..."
                    )
                    time.sleep(delay)
        return wrapper
    return decorator


def deprecated(reason: str = ""):
    """
    Decorator to mark functions as deprecated

    Usage:
        @deprecated("Use new_function instead")
        def old_function():
            pass
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs) -> Any:
            warning_msg = f"{func.__name__} is deprecated"
            if reason:
                warning_msg += f": {reason}"
            logger.warning(warning_msg)
            return func(*args, **kwargs)
        return wrapper
    return decorator
