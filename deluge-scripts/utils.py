def convert_bytes_to_str(obj):
    """Recursively convert bytes to strings in a data structure."""
    if isinstance(obj, dict):
        return {convert_bytes_to_str(k): convert_bytes_to_str(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_bytes_to_str(item) for item in obj]
    elif isinstance(obj, tuple):
        return tuple(convert_bytes_to_str(item) for item in obj)
    elif isinstance(obj, bytes):
        return obj.decode()
    else:
        return obj

def convert_str_to_bytes(obj):
    """Recursively convert strings to bytes in a data structure."""
    if isinstance(obj, dict):
        return {convert_str_to_bytes(k): convert_str_to_bytes(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_str_to_bytes(item) for item in obj]
    elif isinstance(obj, tuple):
        return tuple(convert_str_to_bytes(item) for item in obj)
    elif isinstance(obj, str):
        return obj.encode()
    else:
        return obj
