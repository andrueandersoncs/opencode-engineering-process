# Phase 6: Implement

## Purpose
Write tests FIRST, then code that makes them pass. Follow the task breakdown using strict TDD: Red → Green → Refactor.

**CRITICAL: E2E tests MUST be written and verified to FAIL before any implementation code is written.**

## Agent
**Delegate to: `@implementer`**

The implementer agent has full write access and follows established patterns with test-first discipline.

## The Test-First Mandate

```
┌─────────────────────────────────────────────────────────────────┐
│ IRON RULE: NO IMPLEMENTATION CODE WITHOUT A FAILING TEST FIRST │
└─────────────────────────────────────────────────────────────────┘
```

### Why Tests First?
1. **Tests define done** - You know exactly what to build
2. **Tests verify they work** - A test that passes immediately hasn't been verified
3. **Tests guide design** - Writing tests first leads to better interfaces
4. **Tests prevent gold-plating** - You only write what's needed to pass

## Activities

### 1. Setup
Before writing ANY code:
- Review design document
- Review task breakdown (which should start with "Write failing E2E test")
- Understand acceptance criteria as test scenarios
- Check existing test patterns for reference

### 2. Write E2E Tests FIRST (CRITICAL)

**This is the FIRST implementation task, before any feature code.**

```typescript
// Example: tests/e2e/user-login.spec.ts
import { test, expect } from '@playwright/test';

test('user can log in with valid credentials', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page).toHaveURL('/dashboard');
});
```

### 3. Verify Tests FAIL

**CRITICAL: Run the tests and confirm they fail. This is not optional.**

```bash
npx playwright test user-login.spec.ts
# Expected output: FAILED (because feature doesn't exist yet)
```

If tests pass immediately, something is wrong:
- Test is not actually testing the new feature
- Test is too vague
- Feature already exists (verify scope)

### 4. Implement to Make Tests Pass

**Only now do you write implementation code.**

For each implementation task:
1. Read the failing test to understand what's needed
2. Write the **minimum code** to make the test pass
3. Run the test to verify it passes
4. Refactor if needed while keeping tests green
5. Commit with clear message
6. Mark task complete

### 5. The Red-Green-Refactor Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│  RED: Write failing test                                        │
│       ↓                                                         │
│  GREEN: Write minimum code to pass                              │
│       ↓                                                         │
│  REFACTOR: Clean up while staying green                         │
│       ↓                                                         │
│  REPEAT for next feature                                        │
└─────────────────────────────────────────────────────────────────┘
```

### 6. Quality Checks
Throughout implementation:
- Follow project conventions
- Keep code simple
- Handle errors appropriately
- Add logging where useful

### 4. Progress Tracking
Keep workflow state updated:
- Mark tasks complete as finished
- Note any blockers or deviations
- Update if scope changes

## Delegation to Implementer Agent

```
@implementer Implementation phase for [feature description]

Design document: docs/stories/<slug>/design.md
Task breakdown: docs/stories/<slug>/tasks.md

Current task: [Task X.Y from breakdown]

Context:
- [Relevant context from previous phases]
- [Any decisions made during design]

Constraints:
- Follow patterns from [location]
- Tests required for all new code

Expected output:
- Working code with tests
- Updated task breakdown
- Notes on any issues discovered
```

## Implementation Flow

```
┌─────────────────────────────────────────────────────┐
│  For each task in tasks.md:                         │
│                                                     │
│  1. Read the task and its dependencies              │
│  2. Check if dependencies are complete              │
│  3. Implement the functionality                     │
│  4. Write/update tests                              │
│  5. Run tests locally                               │
│  6. Mark task [x] complete in tasks.md              │
│  7. Commit with descriptive message                 │
│                                                     │
│  If blocked:                                        │
│  - Document the blocker                             │
│  - Propose solutions                                │
│  - Escalate if needed                               │
└─────────────────────────────────────────────────────┘
```

## Commit Strategy

### Commit Frequency
- After each completed task
- When reaching a stable intermediate state
- Before major changes to enable rollback

### Commit Messages
Follow conventional commits:
```
feat: add user authentication endpoint
fix: correct validation for email field
test: add integration tests for login flow
refactor: extract auth middleware to separate file
docs: update API documentation for auth
```

## Quality Checklist

Before marking implementation complete:

### Testing (CRITICAL)
- [ ] **E2E tests were written FIRST and verified to FAIL**
- [ ] **All E2E tests now PASS**
- [ ] Unit tests for complex business logic
- [ ] Edge cases covered by tests
- [ ] All tests passing

### Code Quality
- [ ] Follows project style guide
- [ ] No linting errors
- [ ] No hardcoded values that should be config
- [ ] No sensitive data in code
- [ ] Error handling is appropriate

### Documentation
- [ ] Code is self-documenting or has comments
- [ ] API documentation updated if needed
- [ ] README updated if needed

### Cleanup
- [ ] No TODO comments left unaddressed
- [ ] No commented-out code
- [ ] No debug logging left in

## Handling Issues

### Design Doesn't Work
1. Stop implementation
2. Document what doesn't work
3. Propose alternative
4. Get design revision before continuing

### Missing Information
1. Check research notes
2. Make reasonable assumption
3. Document the assumption
4. Flag for review phase

### Technical Blockers
1. Document the blocker
2. Identify workarounds
3. Escalate for decision

## Completion Criteria

- [ ] **CRITICAL: All E2E tests pass**
- [ ] **CRITICAL: Tests were written BEFORE implementation**
- [ ] All tasks in breakdown are marked complete
- [ ] All unit tests passing
- [ ] Code follows project conventions
- [ ] Changes committed with clear messages
- [ ] No blocking issues remain

## Common Pitfalls

1. **Scope Creep** - Adding features not in design
2. **Skipping Tests** - "I'll add them later"
3. **Ignoring Patterns** - Not following existing conventions
4. **Silent Deviation** - Changing design without documenting
5. **Tests After Implementation** - Writing tests last instead of first (VIOLATES TDD)
6. **Skipping Test Verification** - Not confirming tests fail before implementation

## Next Phase
Proceed to Phase 7: Validate when criteria are met.
