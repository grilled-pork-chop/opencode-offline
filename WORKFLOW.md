# OpenCode Workflow Guide

## Modes

Switch modes with **Tab**:
- **Build** - Write and edit code
- **Plan** - Read-only analysis

## Agents

Invoke with `@agent`:

| Agent | Use For |
|-------|---------|
| `@explore` | Find files, understand code |
| `@architect` | Design solutions |
| `@review` | Code review |
| `@test` | Write tests |
| `@debug` | Fix bugs |
| `@security` | Security audit |
| `@docs` | Documentation |
| `@git` | Commits and PRs |

## Common Workflows

### New Feature
```
@explore    → understand codebase
@architect  → design solution
Tab → Plan  → create implementation plan
Tab → Build → implement step by step
@test       → write tests
@review     → check code quality
@git        → commit
```

### Bug Fix
```
@explore    → find relevant code
@debug      → investigate root cause
Tab → Build → implement fix
@test       → add regression test
@git        → commit
```

### Code Review
```
@explore    → understand the changes
@review     → systematic review
@security   → check for vulnerabilities
```

## Tips

1. **Start with @explore** - Understand before changing
2. **Use Plan mode first** - Think before coding
3. **Review each diff** - Approve or deny changes
4. **Run tests often** - Catch issues early

## Commands

| Command | Action |
|---------|--------|
| `/init` | Initialize project |
| `/undo` | Undo last change |
| `/compact` | Clear context |
| Tab | Switch mode |
