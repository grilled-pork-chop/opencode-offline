---
name: anti-hallucination
description: Prevent fabrication of APIs, imports, file paths, and code patterns. Verify before assuming.
license: MIT
metadata:
  category: core
  priority: critical
---

# Anti-Hallucination Protocol

## The Problem

LLMs confidently generate plausible but incorrect:
- Import statements for non-existent modules
- Function calls with wrong signatures
- File paths that don't exist
- API endpoints that were never defined
- Configuration options that aren't supported

This causes runtime errors, wasted debugging time, and broken code.

## The Solution: Verify Everything

### Rule 1: Verify Imports Exist

```
BEFORE writing: from module import function

DO:
1. grep({ pattern: "def function|function =|class function", path: "**/*.py" })
2. OR check if it's a standard library / installed package
3. Only then write the import

DON'T:
- Assume a function exists because it "should"
- Invent utility functions that would be convenient
- Guess at module structure
```

### Rule 2: Verify Function Signatures

```
BEFORE calling: result = some_function(arg1, arg2, arg3)

DO:
1. read the file containing the function
2. Check the actual signature: def some_function(a, b): # only 2 args!
3. Match your call to the real signature

DON'T:
- Add parameters that "make sense"
- Assume keyword arguments exist
- Guess at default values
```

### Rule 3: Verify File Paths

```
BEFORE editing: path/to/file.py

DO:
1. glob({ pattern: "**/file.py" })
2. OR: ls({ path: "path/to/" })
3. Confirm exact path before editing

DON'T:
- Assume directory structure
- Guess at file locations
- Create paths from memory
```

### Rule 4: Verify API Shapes

```
BEFORE using: response.data.user.name

DO:
1. Find where the API response is defined/documented
2. Check actual response structure
3. Handle missing fields appropriately

DON'T:
- Assume nested structure exists
- Invent response fields
- Skip null checks
```

### Rule 5: Verify Config Options

```
BEFORE setting: config.some_option = value

DO:
1. grep for where config is defined/used
2. Check what options actually exist
3. Verify option types and valid values

DON'T:
- Invent configuration keys
- Assume option names from similar projects
- Guess at value formats
```

## Verification Commands

### Find Function/Class Definition
```bash
# Python
rg "def function_name\(|class ClassName" --type py

# TypeScript/JavaScript  
rg "function functionName|const functionName|class ClassName" --type ts

# Go
rg "func FunctionName|type TypeName" --type go
```

### Check Module Exports
```bash
# What does this module export?
read({ file: "module/__init__.py" })
read({ file: "module/index.ts" })
```

### Verify Path Exists
```bash
# Does this path exist?
ls({ path: "expected/directory/" })
glob({ pattern: "**/expected_file.py" })
```

### Find Usage Examples
```bash
# How is this function actually used?
rg "function_name\(" --type py -A 2
```

## Response Patterns

### When Uncertain About an Import

```
❌ WRONG:
"I'll import the helper function:"
from utils import helper_function  # May not exist!

✅ CORRECT:
"Let me verify the helper function exists:"
grep({ pattern: "def helper|helper =", path: "utils.py" })
# Then proceed based on actual findings
```

### When Uncertain About a Function Signature

```
❌ WRONG:
"I'll call the function with these parameters:"
process_data(items, validate=True, strict=True)  # Params may not exist!

✅ CORRECT:
"Let me check the function signature:"
read({ file: "processor.py", start: 1, end: 50 })
# Find: def process_data(items, validate=False):  # Only 2 params!
# Then: process_data(items, validate=True)
```

### When Uncertain About File Location

```
❌ WRONG:
"I'll edit the auth handler:"
edit({ file: "src/handlers/auth.py", ... })  # Path may be wrong!

✅ CORRECT:
"Let me find the auth handler:"
glob({ pattern: "**/auth*.py" })
# Found: src/api/handlers/authentication.py
# Then edit the correct path
```

## Red Flags to Watch For

### In Your Own Output

Watch for phrases that indicate guessing:
- "This should be..."
- "I assume..."
- "Typically this would..."
- "Based on common patterns..."
- "This is likely..."

**If you catch yourself using these → STOP and verify**

### In Code You're Writing

Watch for:
- Imports you haven't verified
- Function calls you haven't checked
- File paths you haven't confirmed
- Config options you haven't validated
- API fields you haven't seen defined

## Recovery From Hallucination

If you realize you've hallucinated:

1. **Acknowledge it**: "I assumed X existed but need to verify"
2. **Verify**: Use grep/glob/read to find the truth
3. **Correct**: Update your code with verified information
4. **Explain**: Note what the actual structure/API is

## The Mindset

Think like a new developer on the codebase:
- You don't know where things are
- You can't trust your memory
- You must look things up
- Documentation might be wrong
- Only the code tells the truth
