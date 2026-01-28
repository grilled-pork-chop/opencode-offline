---
name: python-patterns
description: Python best practices, idioms, and common patterns for production code.
license: MIT
metadata:
  category: language
  priority: medium
---

# Python Best Practices

## Type Hints

### Basic Types

```python
from typing import Optional, List, Dict, Tuple, Union, Any
from collections.abc import Callable, Iterator, Sequence

def greet(name: str) -> str:
    return f"Hello, {name}"

def process_items(items: List[int]) -> Dict[str, int]:
    return {"sum": sum(items), "count": len(items)}

def find_user(user_id: int) -> Optional[User]:
    """Returns None if not found."""
    return db.query(User).get(user_id)
```

### Modern Python (3.10+)

```python
# Use built-in types directly
def process(items: list[int]) -> dict[str, int]:
    pass

# Union with |
def parse(value: str | int) -> float:
    pass

# Optional shorthand
def find(id: int) -> User | None:
    pass
```

### Complex Types

```python
from typing import TypeVar, Generic, Protocol

# TypeVar for generics
T = TypeVar('T')

def first(items: list[T]) -> T | None:
    return items[0] if items else None

# Protocol for structural typing
class Comparable(Protocol):
    def __lt__(self, other: Any) -> bool: ...

def sort_items(items: list[Comparable]) -> list[Comparable]:
    return sorted(items)
```

## Data Classes

### Basic Usage

```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass
class User:
    id: int
    email: str
    name: str
    created_at: datetime = field(default_factory=datetime.now)
    tags: list[str] = field(default_factory=list)
    
    def __post_init__(self):
        self.email = self.email.lower()
```

### Immutable Data

```python
@dataclass(frozen=True)
class Point:
    x: float
    y: float
    
    def distance_to(self, other: "Point") -> float:
        return ((self.x - other.x)**2 + (self.y - other.y)**2)**0.5
```

### With Validation (Pydantic)

```python
from pydantic import BaseModel, EmailStr, validator

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v
```

## Context Managers

### For Resource Cleanup

```python
from contextlib import contextmanager

@contextmanager
def database_transaction(connection):
    """Ensure transaction is committed or rolled back."""
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise

# Usage
with database_transaction(conn) as db:
    db.execute("INSERT INTO users ...")
```

### For Temporary State

```python
@contextmanager
def temporary_env(key: str, value: str):
    """Temporarily set environment variable."""
    old_value = os.environ.get(key)
    os.environ[key] = value
    try:
        yield
    finally:
        if old_value is None:
            del os.environ[key]
        else:
            os.environ[key] = old_value
```

## Generators

### For Memory Efficiency

```python
def read_large_file(path: str) -> Iterator[str]:
    """Read file line by line without loading entire file."""
    with open(path) as f:
        for line in f:
            yield line.strip()

def process_in_batches(items: Iterable[T], batch_size: int) -> Iterator[list[T]]:
    """Yield items in batches."""
    batch = []
    for item in items:
        batch.append(item)
        if len(batch) >= batch_size:
            yield batch
            batch = []
    if batch:
        yield batch
```

## Decorators

### Function Decorator

```python
from functools import wraps
import time

def timer(func):
    """Log function execution time."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result
    return wrapper

@timer
def slow_function():
    time.sleep(1)
```

### Decorator with Arguments

```python
def retry(max_attempts: int = 3, exceptions: tuple = (Exception,)):
    """Retry function on failure."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except exceptions:
                    if attempt == max_attempts - 1:
                        raise
            return None
        return wrapper
    return decorator

@retry(max_attempts=3, exceptions=(ConnectionError,))
def fetch_data():
    pass
```

## Common Patterns

### Singleton

```python
class Singleton:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

### Factory

```python
from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def speak(self) -> str:
        pass

class Dog(Animal):
    def speak(self) -> str:
        return "Woof!"

class Cat(Animal):
    def speak(self) -> str:
        return "Meow!"

def create_animal(animal_type: str) -> Animal:
    animals = {"dog": Dog, "cat": Cat}
    if animal_type not in animals:
        raise ValueError(f"Unknown animal: {animal_type}")
    return animals[animal_type]()
```

### Repository Pattern

```python
from abc import ABC, abstractmethod

class UserRepository(ABC):
    @abstractmethod
    def get(self, user_id: int) -> User | None:
        pass
    
    @abstractmethod
    def save(self, user: User) -> User:
        pass

class SQLUserRepository(UserRepository):
    def __init__(self, session: Session):
        self.session = session
    
    def get(self, user_id: int) -> User | None:
        return self.session.query(User).get(user_id)
    
    def save(self, user: User) -> User:
        self.session.add(user)
        self.session.commit()
        return user
```

## Pythonic Idioms

```python
# List comprehension
squares = [x**2 for x in range(10)]

# Dict comprehension
name_lengths = {name: len(name) for name in names}

# Unpacking
first, *rest = items
a, b = b, a  # Swap

# Walrus operator (3.8+)
if (n := len(items)) > 10:
    print(f"Too many items: {n}")

# Enumerate with start
for i, item in enumerate(items, start=1):
    print(f"{i}. {item}")

# Zip for parallel iteration
for name, score in zip(names, scores):
    print(f"{name}: {score}")

# Any/all for conditions
if any(item.is_valid for item in items):
    pass

if all(score >= 60 for score in scores):
    pass

# Get with default
value = dictionary.get("key", "default")

# Setdefault for initialization
counts.setdefault(key, 0)
counts[key] += 1
```
