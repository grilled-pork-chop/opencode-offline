---
name: code-review
description: Systematic code review checklist covering correctness, security, performance, and maintainability.
license: MIT
metadata:
  category: quality
  priority: high
---

# Code Review Checklist

## Review Process

1. **Understand context**: Read PR description, linked issues
2. **Big picture first**: Understand overall approach before details
3. **Check systematically**: Use checklist below
4. **Provide actionable feedback**: Specific, constructive, with examples
5. **Distinguish severity**: Critical vs. nice-to-have

## Checklist

### 1. Correctness

- [ ] Logic matches intended behavior
- [ ] Edge cases handled (null, empty, boundaries)
- [ ] Off-by-one errors checked
- [ ] Type coercion issues identified
- [ ] Race conditions considered (if concurrent)
- [ ] State mutations are intentional

```python
# Common issues to catch:

# Off-by-one
for i in range(len(items) - 1):  # Missing last item?
    
# Null/undefined access
user.profile.name  # What if profile is None?

# Type coercion
if count == "0":  # String comparison, not numeric
```

### 2. Security

- [ ] Input validation present
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] Auth checked before sensitive operations
- [ ] Authorization verified (user owns resource)
- [ ] Secrets not hardcoded
- [ ] Sensitive data not logged

```python
# Security red flags:

# SQL injection
query = f"SELECT * FROM users WHERE id = {user_id}"  # BAD

# Missing auth check
@app.route("/admin/delete/<id>")
def delete_user(id):  # No @require_admin decorator!
    
# Logging sensitive data
logger.info(f"Login attempt: {username}/{password}")  # BAD
```

### 3. Error Handling

- [ ] Exceptions caught at appropriate level
- [ ] Error messages helpful but not leaky
- [ ] Failures don't leave bad state
- [ ] Retry logic has backoff and limits
- [ ] Timeouts on external calls

```python
# Error handling issues:

# Too broad
except Exception:
    pass  # Swallows everything!

# Missing timeout
requests.get(url)  # Could hang forever

# Bad state on failure
self.count += 1
do_something_that_might_fail()  # count incremented even on failure
```

### 4. Performance

- [ ] No N+1 query patterns
- [ ] Appropriate data structures
- [ ] Large collections paginated
- [ ] Expensive operations cached
- [ ] No unnecessary work in loops

```python
# Performance issues:

# N+1 queries
for user in users:
    orders = db.query(Order).filter(user_id=user.id).all()  # Query per user!

# Inefficient lookup
if item in list_of_items:  # O(n) - use set for O(1)

# Repeated expensive work
for x in items:
    config = load_config()  # Loaded every iteration!
```

### 5. Maintainability

- [ ] Functions single-purpose (<30 lines)
- [ ] Names descriptive and consistent
- [ ] Complex logic has comments (WHY)
- [ ] No magic numbers
- [ ] Dead code removed
- [ ] DRY (Don't Repeat Yourself)

```python
# Maintainability issues:

# Magic number
if status == 3:  # What does 3 mean?

# Better:
if status == OrderStatus.SHIPPED:

# Non-descriptive name
def process(d):  # What is d? What processing?

# Better:
def calculate_order_total(order: Order) -> Decimal:
```

### 6. Testing

- [ ] Happy path covered
- [ ] Error paths covered
- [ ] Edge cases covered
- [ ] Mocks used appropriately
- [ ] Tests are deterministic

### 7. Documentation

- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] README updated if needed
- [ ] Breaking changes noted

## Feedback Format

### Critical 🔴
Must fix before merge.
```
🔴 **SQL Injection** (line 45)
User input directly in query. Use parameterized query:
`cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))`
```

### Warning 🟡
Should fix, not blocking.
```
🟡 **Missing null check** (line 72)
`user.profile.name` will throw if profile is None.
Consider: `user.profile.name if user.profile else "Unknown"`
```

### Suggestion 🟢
Nice improvement, optional.
```
🟢 **Naming** (line 15)
Consider renaming `d` to `order_data` for clarity.
```

### Praise ✅
Acknowledge good work.
```
✅ Great error handling here! The retry logic with exponential backoff is well implemented.
```

## Review Etiquette

- **Be kind**: Critique code, not people
- **Be specific**: "This could be null" > "Handle errors better"
- **Explain why**: Share the reasoning
- **Offer alternatives**: Don't just point out problems
- **Ask questions**: "What happens if..." rather than "This is wrong"
- **Acknowledge good work**: Not just problems
