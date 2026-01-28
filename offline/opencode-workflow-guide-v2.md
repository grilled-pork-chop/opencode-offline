# OpenCode Developer Workflow Guide

A step-by-step guide for taking a feature request to production-ready code, using the full agent ecosystem.

---

## Available Agents

| Agent | Invoke | Purpose |
|-------|--------|---------|
| **build-strict** | `Tab` (primary) | Implement code changes |
| **plan** | `Tab` (primary) | Read-only analysis |
| **@explore** | `@explore` | Fast codebase navigation |
| **@architect** | `@architect` | System design, ADRs |
| **@review** | `@review` | Code review |
| **@security** | `@security` | Security audit |
| **@refactor** | `@refactor` | Safe refactoring |
| **@test** | `@test` | Write tests |
| **@debug** | `@debug` | Bug investigation |
| **@docs** | `@docs` | Documentation |
| **@git** | `@git` | Commits, branches, PRs |

---

## The Workflow: Feature Request → Production Code

### Scenario
You receive a feature request:
> "Add rate limiting to the API endpoints - max 100 requests per minute per user"

---

## Step 1: Start Session

```bash
cd /path/to/your/project
opencode
```

First time? Initialize:
```
/init
```

---

## Step 2: Explore the Codebase

Use **@explore** agent for fast, read-only navigation.

```
@explore Where is the API middleware defined? Show me the request handling flow.
```

```
@explore Find all files related to authentication and request processing.
```

```
@explore How are Redis connections managed in this project?
```

**Why @explore?** It's optimized for fast searching with read-only access. Won't accidentally modify anything.

---

## Step 3: Architecture & Design

Use **@architect** agent for design decisions.

```
@architect I need to add rate limiting (100 req/min per user, Redis backend).
Design the solution considering our current architecture.
```

The architect will produce:
- Component design
- Data flow
- Integration points
- Trade-offs

For complex features, request an ADR:

```
@architect Create an ADR for the rate limiting approach.
```

---

## Step 4: Create Implementation Plan

Switch to **Plan** mode (press **Tab** until you see "Plan" indicator).

```
Based on @architect's design, create a detailed implementation plan with:
1. Files to modify/create
2. Step-by-step tasks
3. Testing strategy
4. Rollback considerations
```

Review and refine:

```
What edge cases should we handle? What about:
- Distributed rate limiting across multiple servers?
- Different limits for different endpoints?
- Graceful degradation if Redis is down?
```

---

## Step 5: Implement

Switch to **Build** mode (press **Tab**).

### 5.1 Start with Infrastructure

```
Implement step 1: Add Redis client configuration to src/config.py
```

Review each diff carefully:
```
─────────────────────────────────────────────
 Edit: src/config.py
─────────────────────────────────────────────
 [a]pprove  [d]eny  [e]dit
```

### 5.2 Continue Step by Step

```
Continue with step 2: Create the rate limit middleware.
```

```
Continue with step 3: Apply middleware to routes.
```

### 5.3 Handle Issues

If something looks wrong, stop and redirect:

```
Stop. Use async Redis client instead of sync. Fix that.
```

If you need to undo:
```
/undo
```

---

## Step 6: Write Tests

Use **@test** agent for comprehensive test coverage.

```
@test Write unit tests for the RateLimitMiddleware class.
Cover:
- Normal request counting
- Rate limit exceeded (429 response)
- Redis connection failure fallback
- Rate limit header values
```

```
@test Add integration tests for the rate limiting flow.
```

```
@test What edge cases are we missing?
```

Run and verify:

```
@test Run the rate limit tests and fix any failures.
```

---

## Step 7: Code Review

Use **@review** agent for thorough review.

```
@review Review all the rate limiting changes we made.
Focus on:
- Error handling
- Performance implications
- Code style consistency
```

Address each issue:

```
Fix the issues @review identified, starting with the critical ones.
```

---

## Step 8: Security Audit

Use **@security** agent for security-focused review.

```
@security Audit the rate limiting implementation for:
- Bypass vulnerabilities
- DoS attack vectors
- Information leakage
- Redis security
```

```
Fix any security issues found.
```

---

## Step 9: Documentation

Use **@docs** agent for documentation.

```
@docs Add docstrings to all public functions in the rate limiting module.
```

```
@docs Update the API documentation to include:
- Rate limit behavior
- Response headers (X-RateLimit-*)
- Error responses (429)
- Configuration options
```

```
@docs Add a section to README about rate limiting configuration.
```

---

## Step 10: Final Verification

Back in **Build** mode:

```
Run the full test suite.
```

```
Run linter and fix any issues.
```

```
Run type checker and fix any errors.
```

---

## Step 11: Prepare Commit

Use **@git** agent for Git workflow.

```
@git Show me a summary of all changes made.
```

```
@git Generate a commit message following conventional commits.
```

```
@git Create a PR description for these changes.
```

### Commit

```bash
git add .
git commit
# Paste the generated commit message

git push origin feature/rate-limiting
```

---

## Complete Command Sequence

```bash
cd /path/to/project
opencode
```

```
# ============ EXPLORE ============
@explore Where is API middleware defined? Show request flow.

@explore How is Redis used in this project?

# ============ DESIGN ============
@architect Design rate limiting: 100 req/min/user, Redis backend.
Consider current architecture.

@architect Create an ADR for this approach.

# ============ PLAN ============
# (Tab to Plan mode)

Create implementation plan based on the design:
- Files to modify/create
- Step-by-step tasks
- Testing strategy

What edge cases should we handle?

# ============ BUILD ============
# (Tab to Build mode)

Implement step 1: Redis configuration.
# Review diff → approve

Continue with step 2: Rate limit middleware.
# Review diff → approve

Continue with step 3: Apply to routes.
# Review diff → approve

# ============ TEST ============
@test Write unit tests for RateLimitMiddleware.

@test Add integration tests for rate limiting.

@test Run tests and fix failures.

# ============ REVIEW ============
@review Review all rate limiting changes.

Fix the issues identified.

# ============ SECURITY ============
@security Audit rate limiting for vulnerabilities.

Fix security issues.

# ============ DOCS ============
@docs Add docstrings to rate limiting functions.

@docs Update API docs with rate limit info.

# ============ VERIFY ============
Run full test suite.

Run linter and type checker.

# ============ COMMIT ============
@git Generate commit message.

@git Create PR description.
```

```bash
git add . && git commit
git push origin feature/rate-limiting
```

---

## Workflow Cheat Sheet

```
┌─────────────────────────────────────────────────────────────┐
│              FEATURE → PRODUCTION WORKFLOW                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. EXPLORE      @explore "How does X work?"                │
│                  @explore "Find files related to Y"         │
│                                                             │
│  2. DESIGN       @architect "Design solution for Z"         │
│                  @architect "Create ADR for approach"       │
│                                                             │
│  3. PLAN         [Tab → Plan mode]                          │
│                  "Create implementation plan"               │
│                  "What edge cases to handle?"               │
│                                                             │
│  4. BUILD        [Tab → Build mode]                         │
│                  "Implement step 1..."                      │
│                  Review diffs → approve/deny                │
│                  "Continue with step 2..."                  │
│                                                             │
│  5. TEST         @test "Write unit tests"                   │
│                  @test "Write integration tests"            │
│                  @test "Run tests, fix failures"            │
│                                                             │
│  6. REVIEW       @review "Review all changes"               │
│                  "Fix the issues"                           │
│                                                             │
│  7. SECURITY     @security "Audit for vulnerabilities"      │
│                  "Fix security issues"                      │
│                                                             │
│  8. DOCS         @docs "Add docstrings"                     │
│                  @docs "Update API documentation"           │
│                                                             │
│  9. VERIFY       "Run full test suite"                      │
│                  "Run linter and type checker"              │
│                                                             │
│ 10. COMMIT       @git "Generate commit message"             │
│                  @git "Create PR description"               │
│                  git add . && git commit && git push        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Workflow Patterns by Task Type

### New Feature

```
@explore  → understand codebase
@architect → design solution
Plan mode → implementation plan
Build     → implement
@test     → write tests
@review   → code review
@security → security audit
@docs     → documentation
@git      → commit
```

### Bug Fix

```
@explore  → find relevant code
@debug    → investigate root cause
Plan mode → plan the fix
Build     → implement fix
@test     → add regression test
@review   → verify fix is correct
@git      → commit
```

```
@debug There's a bug where expired tokens aren't rejected.
Investigate and identify the root cause.

# After @debug identifies the issue:

Create a plan to fix the token expiration bug.

# (Tab to Build)

Implement the fix.

@test Add a regression test for this bug.

@review Verify the fix is correct and complete.

@git Generate commit message for this bugfix.
```

### Refactoring

```
@explore  → understand current structure
@architect → design new structure
@refactor → implement safely
@test     → verify behavior unchanged
@review   → check quality
@git      → commit
```

```
@explore Show me the structure of UserService. It's too large.

@architect How should we split UserService into smaller modules?

@refactor Implement the refactoring:
- Extract authentication logic to AuthService
- Extract profile logic to ProfileService
- Keep UserService as facade

@test Run tests after each extraction to verify behavior unchanged.

@review Check the refactored code for issues.

@git Generate commit message for refactoring.
```

### Code Review (External PR)

```
@explore  → understand the changes
@review   → systematic review
@security → security check
```

```
@explore Read the changes in PR #456 (files: src/api/orders.py, src/models/order.py)

@review Review these changes for:
- Correctness
- Error handling
- Performance
- Style

@security Check for security vulnerabilities.

Summarize findings for PR comment.
```

### Performance Investigation

```
@explore  → find slow code paths
@debug    → profile and identify bottleneck
@architect → design optimization
Build     → implement
@test     → verify improvement
```

```
@explore Where is the order processing logic?

@debug The order processing is slow. Analyze potential bottlenecks.

@architect Design an optimization for the N+1 query problem identified.

# Build mode
Implement the optimization.

@test Add performance test to prevent regression.
```

### Adding Tests to Existing Code

```
@explore  → understand code behavior
@test     → write comprehensive tests
@review   → verify test quality
```

```
@explore Show me the PaymentService class and explain what each method does.

@test Write comprehensive tests for PaymentService covering:
- Successful payments
- Failed payments
- Refunds
- Edge cases

@review Check test quality - are we testing behavior, not implementation?
```

---

## Agent Selection Guide

| Task | Primary Agent | Supporting Agents |
|------|---------------|-------------------|
| "Where is X?" | @explore | - |
| "How does X work?" | @explore | Plan mode |
| "Design a solution" | @architect | @explore |
| "Create a plan" | Plan mode | @architect |
| "Implement X" | Build mode | - |
| "Write tests" | @test | @explore |
| "Fix a bug" | @debug → Build | @test |
| "Review code" | @review | @security |
| "Check security" | @security | @review |
| "Refactor X" | @refactor | @test, @review |
| "Write docs" | @docs | @explore |
| "Prepare commit" | @git | @review |

---

## Tips for Best Results

1. **Start with @explore** — Understand before changing
2. **Use @architect for design** — Don't jump straight to coding
3. **Plan before build** — 5 min planning saves 30 min debugging
4. **@test early** — Write tests alongside implementation
5. **@review everything** — Catch issues before commit
6. **@security for sensitive code** — Auth, payments, user data
7. **@docs as you go** — Don't leave docs for "later"
8. **@git for consistency** — Professional commits and PRs

---

## Troubleshooting

### Agent not responding as expected

```
Stop. Let me clarify: [restate your request clearly]
```

### Need to switch tasks mid-flow

```
/compact

# Start fresh context for new task
@explore [new task context]
```

### Agent made a mistake

```
/undo

That's not right. [Explain what's wrong]. Try again.
```

### Complex feature getting messy

Break it down:
```
@architect Break this feature into smaller, independent pieces we can implement one at a time.
```
