---
name: error-handling
description: Implement robust error handling with proper exception types, messages, and recovery strategies.
license: MIT
metadata:
  category: quality
  priority: high
---

# Error Handling Best Practices

## Principles

1. **Fail fast**: Detect errors early, before they cause damage
2. **Fail loud**: Make errors visible, not silent
3. **Fail safe**: Leave system in consistent state
4. **Fail informatively**: Provide context for debugging

## Exception Hierarchy

### Define Custom Exceptions

```python
# Base exception for your application
class AppError(Exception):
    """Base exception for application errors."""
    def __init__(self, message: str, code: str = None, details: dict = None):
        super().__init__(message)
        self.code = code
        self.details = details or {}

# Specific exception types
class ValidationError(AppError):
    """Invalid input data."""
    pass

class NotFoundError(AppError):
    """Requested resource not found."""
    pass

class AuthenticationError(AppError):
    """Authentication failed."""
    pass

class AuthorizationError(AppError):
    """User lacks permission."""
    pass

class ExternalServiceError(AppError):
    """External service call failed."""
    pass
```

### TypeScript Equivalent

```typescript
class AppError extends Error {
  constructor(
    message: string,
    public code?: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

class ValidationError extends AppError {}
class NotFoundError extends AppError {}
class AuthenticationError extends AppError {}
```

## Catching Exceptions

### ❌ Never Use Bare Except

```python
# BAD - catches everything, hides bugs
try:
    process_data(data)
except:
    pass

# BAD - still too broad
try:
    process_data(data)
except Exception:
    logger.error("Something went wrong")
```

### ✅ Catch Specific Exceptions

```python
# GOOD - specific exceptions with appropriate handling
try:
    result = external_api.fetch(url)
except requests.Timeout:
    logger.warning(f"Timeout fetching {url}, retrying...")
    result = external_api.fetch(url, timeout=30)
except requests.ConnectionError as e:
    logger.error(f"Connection failed: {e}")
    raise ExternalServiceError(f"Cannot connect to {url}") from e
except requests.HTTPError as e:
    if e.response.status_code == 404:
        raise NotFoundError(f"Resource not found: {url}")
    raise
```

## Error Messages

### Include Context

```python
# BAD - no context
raise ValueError("Invalid value")

# GOOD - context helps debugging
raise ValueError(
    f"Invalid email format: '{email}'. "
    f"Expected format: user@domain.com"
)
```

### Don't Leak Sensitive Info

```python
# BAD - exposes internal details
raise AuthenticationError(f"Password hash mismatch for {username}")

# GOOD - safe message
raise AuthenticationError("Invalid username or password")
```

## Error Recovery Patterns

### Retry with Backoff

```python
import time
from functools import wraps

def retry(max_attempts=3, backoff_factor=2, exceptions=(Exception,)):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    last_exception = e
                    if attempt < max_attempts - 1:
                        sleep_time = backoff_factor ** attempt
                        time.sleep(sleep_time)
            raise last_exception
        return wrapper
    return decorator

@retry(max_attempts=3, exceptions=(requests.Timeout,))
def fetch_data(url):
    return requests.get(url, timeout=10)
```

### Fallback Values

```python
def get_user_preferences(user_id: int) -> dict:
    try:
        return preferences_service.get(user_id)
    except NotFoundError:
        return DEFAULT_PREFERENCES
    except ExternalServiceError:
        logger.warning("Preferences service unavailable")
        return DEFAULT_PREFERENCES
```

## Validation Pattern

```python
def validate_user_input(data: dict) -> dict:
    """Validate user input, collecting all errors."""
    errors = []
    
    if not data.get("email"):
        errors.append({"field": "email", "message": "Email is required"})
    elif not is_valid_email(data["email"]):
        errors.append({"field": "email", "message": "Invalid email format"})
    
    if not data.get("password"):
        errors.append({"field": "password", "message": "Password is required"})
    elif len(data["password"]) < 8:
        errors.append({"field": "password", "message": "Min 8 characters"})
    
    if errors:
        raise ValidationError("Validation failed", details={"errors": errors})
    
    return data
```

## API Error Responses

```python
@app.errorhandler(ValidationError)
def handle_validation_error(e):
    return {"error": {"code": "VALIDATION_ERROR", "message": str(e), "details": e.details}}, 400

@app.errorhandler(NotFoundError)
def handle_not_found(e):
    return {"error": {"code": "NOT_FOUND", "message": str(e)}}, 404

@app.errorhandler(Exception)
def handle_unexpected(e):
    logger.error(f"Unexpected error: {e}", exc_info=True)
    return {"error": {"code": "INTERNAL_ERROR", "message": "An unexpected error occurred"}}, 500
```

## Exception Chaining

```python
try:
    data = json.loads(raw_data)
except json.JSONDecodeError as e:
    raise ValidationError(f"Invalid JSON: {e.msg}") from e
```

## Cleanup with Context Managers

```python
# Use context managers for automatic cleanup
def process_file(path: str):
    try:
        with open(path, 'r') as file:
            return process(file.read())
    except FileNotFoundError:
        raise NotFoundError(f"File not found: {path}")
    except PermissionError:
        raise AuthorizationError(f"Cannot read file: {path}")
```
