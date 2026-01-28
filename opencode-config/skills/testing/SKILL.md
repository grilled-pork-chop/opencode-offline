---
name: testing
description: Write comprehensive tests with proper structure, mocking, and edge case coverage.
license: MIT
metadata:
  category: quality
  priority: high
---

# Testing Best Practices

## Test Structure (AAA Pattern)

Every test follows Arrange-Act-Assert:

```python
def test_calculate_discount_applies_percentage():
    # Arrange - Set up test data
    cart = Cart(items=[Item(price=100)])
    discount = PercentageDiscount(10)
    
    # Act - Execute the code under test
    result = discount.apply(cart)
    
    # Assert - Verify expected outcome
    assert result.total == 90
```

## Naming Convention

```
test_[unit]_[condition]_[expected_result]

# Examples:
test_calculate_total_with_empty_cart_returns_zero
test_login_with_invalid_password_raises_auth_error
test_parse_date_with_timezone_preserves_offset
```

## Test Categories

### Unit Tests

Test single function/method in isolation.

```python
# Good unit test - isolated, fast, focused
def test_validate_email_with_valid_input():
    assert validate_email("user@example.com") is True

def test_validate_email_with_missing_at_symbol():
    assert validate_email("userexample.com") is False
```

Characteristics:
- No external dependencies (database, network, filesystem)
- Fast execution (<100ms)
- Test one behavior per test

### Integration Tests

Test component interactions.

```python
# Integration test - tests real interactions
def test_user_service_creates_user_in_database(db_session):
    service = UserService(db_session)
    
    user = service.create(email="test@example.com", name="Test")
    
    saved = db_session.query(User).filter_by(email="test@example.com").first()
    assert saved is not None
    assert saved.name == "Test"
```

Characteristics:
- Uses real dependencies where practical
- Slower but more realistic
- Tests boundaries between components

## Edge Cases Checklist

Always test these scenarios:

### Empty/Null Inputs
```python
def test_process_list_with_empty_list():
    assert process_list([]) == []

def test_get_user_with_none_id():
    with pytest.raises(ValueError):
        get_user(None)
```

### Boundary Values
```python
def test_paginate_at_exactly_page_size():
    items = list(range(10))  # Exactly one page
    result = paginate(items, page=1, size=10)
    assert len(result) == 10

def test_paginate_one_over_page_size():
    items = list(range(11))  # One more than page size
    result = paginate(items, page=2, size=10)
    assert len(result) == 1
```

### Invalid Inputs
```python
def test_divide_by_zero_raises_error():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)

def test_parse_date_with_invalid_format():
    with pytest.raises(ValueError):
        parse_date("not-a-date")
```

### Error Conditions
```python
def test_fetch_user_handles_network_timeout(mock_http):
    mock_http.get.side_effect = TimeoutError()
    
    with pytest.raises(ServiceUnavailable):
        fetch_user(123)
```

## Mocking

### When to Mock

✅ Mock these:
- External APIs and services
- Database calls (for unit tests)
- File system operations
- Time-dependent functions
- Random number generation

❌ Don't mock:
- The code under test
- Simple data classes
- Pure functions

### Python Mocking

```python
from unittest.mock import Mock, patch, MagicMock

# Mock a method return value
def test_get_user_returns_user_data():
    mock_repo = Mock()
    mock_repo.find_by_id.return_value = User(id=1, name="Test")
    
    service = UserService(repo=mock_repo)
    result = service.get_user(1)
    
    assert result.name == "Test"
    mock_repo.find_by_id.assert_called_once_with(1)

# Mock with patch decorator
@patch('myapp.services.external_api')
def test_sync_calls_external_api(mock_api):
    mock_api.fetch.return_value = {"status": "ok"}
    
    result = sync_data()
    
    assert result["status"] == "ok"

# Mock with context manager
def test_send_email():
    with patch('myapp.email.smtp_client') as mock_smtp:
        send_email("test@example.com", "Hello")
        
        mock_smtp.send.assert_called_once()
```

### TypeScript/JavaScript Mocking

```typescript
import { vi, describe, it, expect, beforeEach } from 'vitest';

// Mock module
vi.mock('./database', () => ({
  query: vi.fn()
}));

import { query } from './database';
import { getUser } from './userService';

describe('getUser', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns user from database', async () => {
    vi.mocked(query).mockResolvedValue({ id: 1, name: 'Test' });
    
    const result = await getUser(1);
    
    expect(result.name).toBe('Test');
    expect(query).toHaveBeenCalledWith('SELECT * FROM users WHERE id = ?', [1]);
  });
});
```

## Fixtures

### Python (pytest)

```python
import pytest

@pytest.fixture
def sample_user():
    """Create a sample user for testing."""
    return User(id=1, email="test@example.com", name="Test User")

@pytest.fixture
def db_session():
    """Create a test database session."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session = Session(engine)
    yield session
    session.close()

@pytest.fixture(autouse=True)
def reset_singletons():
    """Reset singletons before each test."""
    SingletonClass._instance = None
    yield

# Using fixtures
def test_user_can_update_name(sample_user, db_session):
    db_session.add(sample_user)
    sample_user.name = "New Name"
    db_session.commit()
    
    assert db_session.query(User).first().name == "New Name"
```

### TypeScript/JavaScript

```typescript
// Fixture factory
const createUser = (overrides = {}): User => ({
  id: 1,
  email: 'test@example.com',
  name: 'Test User',
  ...overrides
});

// Setup/teardown
describe('UserService', () => {
  let service: UserService;
  let mockDb: MockDatabase;

  beforeEach(() => {
    mockDb = new MockDatabase();
    service = new UserService(mockDb);
  });

  afterEach(() => {
    mockDb.clear();
  });

  it('creates user', async () => {
    const user = createUser({ name: 'New User' });
    await service.create(user);
    expect(mockDb.users).toHaveLength(1);
  });
});
```

## Test Organization

```
tests/
├── unit/                    # Fast, isolated tests
│   ├── test_validators.py
│   ├── test_utils.py
│   └── test_models.py
├── integration/             # Component interaction tests
│   ├── test_user_service.py
│   └── test_api_handlers.py
├── e2e/                     # End-to-end tests
│   └── test_user_flow.py
├── conftest.py              # Shared fixtures
└── factories.py             # Test data factories
```

## Common Pitfalls

### ❌ Testing Implementation Details

```python
# Bad - tests internal implementation
def test_cache_uses_lru_algorithm():
    cache = Cache()
    assert cache._algorithm == "lru"  # Don't test private details
```

```python
# Good - tests behavior
def test_cache_evicts_least_recently_used():
    cache = Cache(max_size=2)
    cache.set("a", 1)
    cache.set("b", 2)
    cache.get("a")  # Access a
    cache.set("c", 3)  # Should evict b
    
    assert cache.get("a") == 1
    assert cache.get("b") is None
    assert cache.get("c") == 3
```

### ❌ Flaky Tests

```python
# Bad - depends on timing
def test_timeout():
    start = time.time()
    do_something()
    assert time.time() - start < 1.0  # Flaky!
```

```python
# Good - mock time
@patch('myapp.time.time')
def test_timeout(mock_time):
    mock_time.side_effect = [0, 0.5, 2.0]  # Controlled time
    with pytest.raises(TimeoutError):
        do_something_with_timeout(1.0)
```

### ❌ Test Interdependence

```python
# Bad - tests depend on order
class TestUser:
    user_id = None
    
    def test_create_user(self):
        TestUser.user_id = create_user()  # Shared state!
    
    def test_get_user(self):
        get_user(TestUser.user_id)  # Fails if run alone!
```

```python
# Good - each test is independent
def test_create_user(db):
    user_id = create_user()
    assert user_id is not None

def test_get_user(db):
    user_id = create_user()  # Create own data
    user = get_user(user_id)
    assert user is not None
```
