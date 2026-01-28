---
name: diff-editing
description: Apply minimal, surgical code changes using diff-only edits. Essential for preserving code context and preventing full-file rewrites.
license: MIT
metadata:
  category: core
  priority: critical
---

# Diff-Only Editing Protocol

## Core Principle

**Make the MINIMUM change required. Never rewrite entire files.**

The edit tool replaces exact text matches. Using it correctly prevents:
- Lost comments and documentation
- Broken formatting
- Merge conflicts
- Unintended side effects

## The Golden Rules

### Rule 1: READ Before WRITE

```
ALWAYS:
1. read({ file: "target.py" })
2. Analyze current content
3. Identify EXACT text to change
4. Then edit
```

**Why**: File contents may have changed. Your memory of the file may be wrong. The edit tool requires exact matches.

### Rule 2: Use EDIT, Not WRITE

```
✅ CORRECT:
edit({
  file: "src/auth.py",
  old_text: "def login(username, password):\n    return check_password(username, password)",
  new_text: "def login(username: str, password: str) -> bool:\n    return check_password(username, password)"
})

❌ WRONG:
write({
  file: "src/auth.py",
  content: "[entire file content]"
})
```

**Why**: `write` overwrites everything. Comments, imports, other functions—all gone or must be perfectly reproduced.

### Rule 3: Include Enough Context

```
✅ CORRECT (unique match):
old_text: "def calculate_total(items):\n    total = 0\n    for item in items:"

❌ WRONG (ambiguous):
old_text: "total = 0"
```

**Why**: `old_text` must match exactly ONE location. Include surrounding lines to ensure uniqueness.

### Rule 4: One Logical Change Per Edit

```
✅ CORRECT:
# Edit 1: Add type hint to function A
edit({ file: "x.py", old_text: "def func_a():", new_text: "def func_a() -> None:" })

# Edit 2: Add type hint to function B  
edit({ file: "x.py", old_text: "def func_b():", new_text: "def func_b() -> None:" })

❌ WRONG:
# Trying to change multiple unrelated things in one edit
edit({ file: "x.py", old_text: "[100 lines]", new_text: "[100 lines modified]" })
```

**Why**: Smaller edits are easier to verify, review, and revert.

### Rule 5: Preserve Exact Formatting

```
✅ CORRECT (matches file exactly):
old_text: "    def method(self):\n        pass"  # 4-space indent

❌ WRONG (whitespace mismatch):
old_text: "  def method(self):\n    pass"  # 2-space indent (won't match)
```

**Why**: The edit tool does exact string matching. Whitespace differences cause failures.

### Rule 6: Verify After Every Edit

```
ALWAYS after editing:
1. read({ file: "target.py", start: X, end: Y })
2. Confirm change applied correctly
3. Then proceed to next change
```

**Why**: Edits can fail silently if `old_text` doesn't match. Verification catches this immediately.

## When Edit Fails

```
If edit returns "text not found":

1. READ the file again
   read({ file: "target.py" })

2. Find the ACTUAL current text
   (It may have changed since you last read it)

3. Copy text EXACTLY as it appears
   Including whitespace, newlines, punctuation

4. Retry the edit with corrected old_text
```

## Multi-File Changes

```
For changes spanning multiple files:

1. Plan the order (dependencies first)
2. Edit file A
3. Verify file A
4. Edit file B
5. Verify file B
...
N. Run tests to confirm everything works together
```

## Examples

### Adding an Import

```python
# Read first
read({ file: "handler.py", start: 1, end: 20 })

# Current content shows:
# import json
# from typing import Dict
#
# def handle():

# Add new import
edit({
  file: "handler.py",
  old_text: "import json\nfrom typing import Dict",
  new_text: "import json\nimport logging\nfrom typing import Dict"
})

# Verify
read({ file: "handler.py", start: 1, end: 20 })
```

### Fixing a Bug

```python
# Read the function
read({ file: "utils.py", start: 45, end: 60 })

# Current shows:
# def divide(a, b):
#     return a / b

# Add zero check
edit({
  file: "utils.py",
  old_text: "def divide(a, b):\n    return a / b",
  new_text: "def divide(a, b):\n    if b == 0:\n        raise ValueError(\"Cannot divide by zero\")\n    return a / b"
})

# Verify
read({ file: "utils.py", start: 45, end: 65 })
```

### Renaming a Variable

```python
# Read context
read({ file: "config.py" })

# Find all occurrences
grep({ pattern: "old_name", path: "config.py" })

# Edit each occurrence
edit({
  file: "config.py",
  old_text: "old_name = get_config()",
  new_text: "new_name = get_config()"
})

edit({
  file: "config.py", 
  old_text: "use_setting(old_name)",
  new_text: "use_setting(new_name)"
})

# Verify no occurrences remain
grep({ pattern: "old_name", path: "config.py" })
```

## Anti-Patterns

❌ **Rewriting entire files**
- Loses comments, formatting, unrelated code
- Creates massive diffs for review
- High risk of introducing bugs

❌ **Editing without reading first**
- old_text won't match if file changed
- Wastes iterations on failed edits

❌ **Guessing file contents**
- Memory is unreliable
- Files change between reads

❌ **Large multi-line old_text**
- More likely to have matching errors
- Harder to verify correctness

❌ **Skipping verification**
- Silent failures go unnoticed
- Compounds into larger problems
