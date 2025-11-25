"""
Utility functions
"""
from typing import Any, Dict, List
import hashlib
import uuid


def generate_uuid() -> str:
    """Generate a unique UUID string"""
    return str(uuid.uuid4())


def hash_string(value: str, algorithm: str = 'sha256') -> str:
    """
    Hash a string using specified algorithm

    Args:
        value: String to hash
        algorithm: Hash algorithm (md5, sha1, sha256, sha512)
    """
    hash_obj = hashlib.new(algorithm)
    hash_obj.update(value.encode())
    return hash_obj.hexdigest()


def chunks(lst: List, size: int) -> List[List]:
    """Split a list into chunks of specified size"""
    return [lst[i:i + size] for i in range(0, len(lst), size)]


def flatten_dict(d: Dict, parent_key: str = '', sep: str = '.') -> Dict:
    """
    Flatten a nested dictionary

    Example:
        {'a': {'b': 1, 'c': 2}} -> {'a.b': 1, 'a.c': 2}
    """
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def safe_get(dictionary: Dict, *keys, default: Any = None) -> Any:
    """
    Safely get nested dictionary values

    Example:
        safe_get({'a': {'b': 1}}, 'a', 'b') -> 1
        safe_get({'a': {}}, 'a', 'b') -> None
    """
    result = dictionary
    for key in keys:
        if isinstance(result, dict):
            result = result.get(key)
        else:
            return default
        if result is None:
            return default
    return result
