---
name: git-workflow
description: Git best practices for commits, branches, and collaboration. Conventional commits, branch naming, PR templates.
license: MIT
metadata:
  category: workflow
  priority: medium
---

# Git Workflow Standards

## Commit Message Format

### Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, no feature/fix |
| `perf` | Performance improvement |
| `test` | Adding/correcting tests |
| `chore` | Build, dependencies, etc. |
| `ci` | CI/CD changes |
| `revert` | Revert previous commit |

### Rules

- **Subject**: Imperative mood, no period, <50 chars
- **Body**: Wrap at 72 chars, explain WHAT and WHY
- **Footer**: Reference issues, breaking changes

### Examples

```
feat(auth): add OAuth2 login with Google

Implement Google OAuth2 authentication using passport-google-oauth20.
Users can now sign in with their Google accounts.

- Add /auth/google routes
- Store OAuth tokens in session
- Add user profile sync on login

Closes #123
```

```
fix(api): prevent null pointer in user lookup

The getUserById function could return null when user was deleted
but still cached. Now returns 404 immediately.

Fixes #456
```

```
refactor(db): extract connection pool to separate module

No functional changes. Improves testability by allowing
mock connection injection.

BREAKING CHANGE: Database.connect() signature changed
```

## Branch Naming

### Format

```
<type>/<ticket>-<short-description>
```

### Examples

```
feature/AUTH-123-oauth-login
fix/BUG-456-null-user-lookup
refactor/TECH-789-extract-auth-service
hotfix/PROD-101-memory-leak
docs/DOC-202-api-documentation
chore/DEP-303-upgrade-react
```

### Rules

- Lowercase with hyphens
- Include ticket number if available
- Keep description short but meaningful

## Pull Request Template

```markdown
## Summary
[One paragraph describing the change]

## Type of Change
- [ ] Bug fix (non-breaking)
- [ ] New feature (non-breaking)
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- [Change 1]
- [Change 2]

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

### Test Instructions
1. [Step 1]
2. [Expected result]

## Checklist
- [ ] Code follows project style
- [ ] Self-review performed
- [ ] Documentation updated
- [ ] No new warnings

## Related Issues
Closes #[issue number]
```

## Changelog Entry (Keep a Changelog)

```markdown
## [Unreleased]

### Added
- OAuth2 authentication with Google (#123)

### Changed
- Improved error messages for API validation

### Fixed
- Null pointer in user lookup (#456)

### Removed
- Deprecated v1 API endpoints

### Security
- Updated dependencies to patch CVE-XXXX-YYYY
```

## Git Commands Reference

### Before Committing

```bash
# Check status
git status

# Review changes
git diff
git diff --staged

# Stage specific files
git add path/to/file.py

# Interactive staging
git add -p
```

### Commit

```bash
# Commit with message
git commit -m "feat(auth): add login endpoint"

# Commit with editor for longer message
git commit

# Amend last commit (before push)
git commit --amend
```

### Branches

```bash
# Create and switch
git checkout -b feature/new-feature

# Switch branches
git checkout main

# Delete merged branch
git branch -d feature/old-feature

# Delete unmerged branch
git branch -D feature/abandoned
```

### Keeping Up to Date

```bash
# Fetch latest
git fetch origin

# Rebase on main
git rebase origin/main

# If conflicts, resolve then:
git rebase --continue
```

### Undo

```bash
# Undo staged changes
git reset HEAD file.py

# Undo uncommitted changes
git checkout -- file.py

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```
