---
name: debugging
description: Systematic debugging methodology using scientific method. Root cause analysis and common bug patterns.
license: MIT
metadata:
  category: workflow
  priority: high
---

# Systematic Debugging

## The Scientific Method for Bugs

1. **Observe**: Gather information about the bug
2. **Hypothesize**: Form theories about the cause
3. **Predict**: What would confirm/deny each theory?
4. **Test**: Run experiments to verify
5. **Conclude**: Identify root cause and fix

## Step 1: Gather Information

### Questions to Answer

```
□ What is the expected behavior?
□ What is the actual behavior?
□ When did it start happening?
□ Does it happen consistently or intermittently?
□ What changed recently? (code, config, dependencies)
□ Can you reproduce it reliably?
□ What environment does it occur in?
```

### Information Sources

```bash
# Recent code changes
git log --oneline -20
git diff HEAD~5

# Error logs
tail -100 /var/log/app.log
grep -i error /var/log/app.log | tail -50

# System state
ps aux | grep app
free -h
df -h
```

## Step 2: Reproduce the Bug

### Create Minimal Reproduction

1. Start with the full failing case
2. Remove components one at a time
3. Stop when removing anything makes bug disappear
4. Document exact steps to reproduce

### Document the Reproduction

```markdown
## Reproduction Steps
1. Start with clean database
2. Create user with email "test@example.com"
3. Attempt to create second user with same email
4. Expected: Error message "Email already exists"
5. Actual: 500 Internal Server Error
```

## Step 3: Form Hypotheses

### List Possible Causes

```
Based on symptoms, what could cause this?

Hypothesis 1: Database unique constraint not enforced
- Test: Check table schema for constraint
- Likelihood: Low (worked before)

Hypothesis 2: Exception handling missing for duplicate key
- Test: Add logging around insert
- Likelihood: High (recent code change)

Hypothesis 3: Race condition on concurrent inserts
- Test: Try rapid concurrent requests
- Likelihood: Medium (happens intermittently)
```

### Prioritize by Likelihood

Test most likely hypotheses first to save time.

## Step 4: Test Hypotheses

### Add Diagnostic Output

```python
# Strategic print debugging
def create_user(email: str):
    print(f"DEBUG: Creating user with email={email}")
    
    existing = db.query(User).filter_by(email=email).first()
    print(f"DEBUG: Existing user query result: {existing}")
    
    if existing:
        print(f"DEBUG: User exists, should raise error")
        raise DuplicateEmailError(email)
    
    user = User(email=email)
    print(f"DEBUG: About to insert user: {user}")
    
    try:
        db.add(user)
        db.commit()
        print(f"DEBUG: Insert successful, id={user.id}")
    except Exception as e:
        print(f"DEBUG: Insert failed: {type(e).__name__}: {e}")
        raise
```

### Use Debugger

```python
# Python - drop into debugger
import pdb; pdb.set_trace()

# Or with breakpoint (Python 3.7+)
breakpoint()
```

```javascript
// JavaScript - debugger statement
debugger;
```

### Binary Search with Git Bisect

```bash
# Find the commit that introduced the bug
git bisect start
git bisect bad HEAD              # Current version is bad
git bisect good v1.2.0           # Known working version
# Git checks out middle commit
# Test if bug exists
git bisect good  # or git bisect bad
# Repeat until culprit found
git bisect reset
```

## Step 5: Identify Root Cause

### Ask "Why?" Repeatedly

```
Problem: 500 error on duplicate email

Why? → Exception not caught
Why? → No try/catch around insert
Why? → Developer assumed validation would catch it
Why? → Validation only checks format, not uniqueness
Root cause: Missing uniqueness check before insert
```

### Document the Root Cause

```markdown
## Root Cause Analysis

**Symptom**: 500 error when creating user with duplicate email

**Root Cause**: The `create_user` function relies on database
constraint to catch duplicates, but doesn't handle the 
IntegrityError exception.

**Why it wasn't caught before**: Previous implementation used
ORM's `get_or_create` which handled duplicates internally.
```

## Common Bug Patterns

### Off-by-One Errors

```python
# Wrong: misses last element
for i in range(len(items) - 1):
    process(items[i])

# Right: processes all elements
for i in range(len(items)):
    process(items[i])
```

### Null/None Dereference

```python
# Wrong: crashes if user is None
def get_email(user_id):
    user = find_user(user_id)
    return user.email  # NoneType has no attribute 'email'

# Right: handle None case
def get_email(user_id):
    user = find_user(user_id)
    return user.email if user else None
```

### Race Conditions

```python
# Wrong: race condition
if not user_exists(email):
    create_user(email)  # Another request might create between check and create

# Right: atomic operation
try:
    create_user(email)
except DuplicateKeyError:
    # Handle duplicate
```

### State Mutation

```python
# Wrong: modifies original
def add_discount(prices):
    for i in range(len(prices)):
        prices[i] *= 0.9  # Mutates input!
    return prices

# Right: return new list
def add_discount(prices):
    return [p * 0.9 for p in prices]
```

### Async/Await Mistakes

```javascript
// Wrong: not awaited
async function getData() {
    const data = fetchData();  // Missing await!
    return data.items;  // data is a Promise, not the result
}

// Right: await the promise
async function getData() {
    const data = await fetchData();
    return data.items;
}
```

## When You're Stuck

1. **Take a break**: Fresh eyes find bugs faster
2. **Rubber duck debugging**: Explain code line-by-line
3. **Question assumptions**: What are you sure is true?
4. **Simplify**: Create minimal reproduction case
5. **Get another perspective**: Ask a colleague
6. **Sleep on it**: Subconscious often finds solutions

## Fix Verification

```markdown
□ Bug no longer reproduces
□ Original tests still pass
□ New regression test added
□ No new bugs introduced
□ Fix is minimal and focused
□ Root cause documented
```
