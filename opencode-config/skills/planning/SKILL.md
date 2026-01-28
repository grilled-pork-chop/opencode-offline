---
name: planning
description: Create structured implementation plans before coding. Break down complex tasks into verifiable steps.
license: MIT
metadata:
  category: workflow
  priority: high
---

# Implementation Planning Protocol

## Why Plan First?

- **Reduces rework**: Catch design issues before writing code
- **Enables review**: Others can validate approach before investment
- **Tracks progress**: Know what's done and what remains
- **Manages scope**: Prevents feature creep during implementation
- **Improves estimates**: Concrete steps are easier to estimate

## Plan Structure

```markdown
## Task: [One-line description]

### Understanding
[Restate the requirement in your own words]
[List any assumptions you're making]

### Scope
**In Scope:**
- [What will be done]

**Out of Scope:**
- [What will NOT be done]

### Files to Modify
1. `path/to/file.py` — [what changes]
2. `path/to/other.py` — [what changes]

### Files to Create
1. `path/to/new.py` — [purpose]

### Implementation Steps
1. [ ] [Step 1 - specific and verifiable]
2. [ ] [Step 2 - specific and verifiable]
3. [ ] [Step 3 - specific and verifiable]

### Testing Strategy
- [ ] Unit test: [what to test]
- [ ] Integration test: [what to test]
- [ ] Manual test: [how to verify]

### Risks & Mitigations
- **Risk**: [potential problem]
  **Mitigation**: [how to address]

### Dependencies
- [External dependency or blocker]

### Estimated Effort
[trivial | small | medium | large]
```

## Planning Levels

### Level 1: Quick Tasks (trivial/small)
- Single file changes
- Bug fixes with clear cause
- Simple additions

Plan format:
```
Files: [list]
Change: [one-line description]
Test: [how to verify]
```

### Level 2: Standard Tasks (small/medium)
- Multi-file changes
- New features
- Refactoring

Use full plan structure above.

### Level 3: Complex Tasks (medium/large)
- Architecture changes
- Multi-component features
- Breaking changes

Add:
```
### Phases
#### Phase 1: [Name]
- Goal: [what this phase achieves]
- Steps: [list]
- Verification: [how to confirm phase complete]

#### Phase 2: [Name]
...

### Rollback Plan
[How to revert if issues arise]

### Communication
[Who needs to know, when]
```

## Good vs Bad Steps

### Good Steps (Specific & Verifiable)

```
✅ Add `validate_email()` function to `utils/validation.py` that:
   - Takes email string as input
   - Returns True if valid, False otherwise
   - Uses regex pattern: ^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$
   
✅ Update `UserService.create()` in `services/user.py` to:
   - Call `validate_email(email)` before creating user
   - Raise `ValidationError` if email invalid

✅ Add unit test in `tests/test_validation.py`:
   - Test valid emails: user@example.com, user+tag@example.com
   - Test invalid emails: invalid, @example.com, user@
```

### Bad Steps (Vague & Unverifiable)

```
❌ Add email validation
   (Where? What counts as valid? How to verify?)

❌ Update the user service
   (What specifically? Which method? What change?)

❌ Add some tests
   (What tests? What cases? How many?)
```

## Step Decomposition

### Too Big → Break Down

```
❌ "Implement authentication"

✅ Break into:
1. Add User model with password hash field
2. Create password hashing utility functions
3. Add login endpoint that validates credentials
4. Add JWT token generation
5. Add auth middleware that validates tokens
6. Add logout endpoint that invalidates tokens
7. Add tests for each component
```

### Too Small → Combine

```
❌ 
1. Open file
2. Find function
3. Add parameter
4. Save file

✅ "Add `timeout` parameter to `fetch_data()` in `api.py`"
```

## Pre-Planning Checklist

Before creating a plan, verify:

```
□ I understand what success looks like
□ I know which files are involved (checked with grep/glob)
□ I've read the relevant code sections
□ I understand existing patterns in the codebase
□ I've identified potential risks
□ I know how to test the changes
```

## Plan Validation

After creating a plan, check:

```
□ Each step is specific enough to execute
□ Each step is verifiable (you can confirm it's done)
□ Steps are in dependency order
□ No steps are missing between start and end state
□ Testing is included
□ Risks are acknowledged
```

## When Plans Change

Plans are not contracts. Update them when:

- You discover new information
- Requirements change
- A better approach emerges
- Risks materialize

Document changes:
```
### Plan Updates
- [Date]: Changed step 3 because [reason]
- [Date]: Added step 5a for [reason]
```

## Templates

### Bug Fix Plan
```markdown
## Bug: [description]

### Reproduction
[Steps to reproduce]

### Root Cause
[Why the bug occurs]

### Fix
File: `path/to/file.py`
Change: [specific change]

### Test
- [ ] Bug no longer reproduces
- [ ] Existing tests pass
- [ ] Add regression test: [description]
```

### Feature Plan
```markdown
## Feature: [name]

### User Story
As a [user type], I want [action] so that [benefit].

### Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

### Implementation
[Full plan structure]
```

### Refactoring Plan
```markdown
## Refactor: [what]

### Current State
[Description of current code/structure]

### Target State
[Description of desired code/structure]

### Steps
[Incremental steps, each leaving code working]

### Verification
- [ ] All tests pass after each step
- [ ] Behavior unchanged (same inputs → same outputs)
```
