# Test-Driven Development Guide

This guide establishes the **test-first philosophy** that is central to this engineering process. Tests are not an afterthought—they are the foundation upon which all implementation is built.

## Core Principle: Tests Are the Source of Truth

**Every user story must have at least one end-to-end test (ideally multiple) written BEFORE any implementation code.**

These tests:
1. **Define done** - A story is complete when its tests pass
2. **Must fail first** - Verify the test actually tests what you think it tests
3. **Guide implementation** - Write only the code needed to make tests pass
4. **Prevent regression** - Guard against future changes breaking functionality
5. **Serve as documentation** - Show how the feature should work

## Test-First Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. UNDERSTAND: Extract acceptance criteria → test scenarios     │
├─────────────────────────────────────────────────────────────────┤
│ 2. RESEARCH: Discover existing test patterns and infrastructure│
├─────────────────────────────────────────────────────────────────┤
│ 3. SCOPE: Define which tests are in/out of scope               │
├─────────────────────────────────────────────────────────────────┤
│ 4. DESIGN: Design test architecture alongside feature design   │
├─────────────────────────────────────────────────────────────────┤
│ 5. DECOMPOSE: Each task must reference its required tests      │
├─────────────────────────────────────────────────────────────────┤
│ 6. IMPLEMENT: Write tests FIRST, then implementation           │
│    └─ RED: Write failing test                                   │
│    └─ GREEN: Write minimal code to pass                         │
│    └─ REFACTOR: Clean up while keeping tests green             │
├─────────────────────────────────────────────────────────────────┤
│ 7. VALIDATE: Verify coverage, review test quality              │
├─────────────────────────────────────────────────────────────────┤
│ 8. DEPLOY: Run full test suite before and after deployment     │
└─────────────────────────────────────────────────────────────────┘
```

## Test Types

### End-to-End Tests (E2E) - MANDATORY
- **Tool**: Playwright (see [PLAYWRIGHT_GUIDE.md](PLAYWRIGHT_GUIDE.md))
- **Purpose**: Verify complete user workflows
- **When written**: FIRST, before any implementation
- **Minimum**: At least one per user story, ideally multiple per acceptance criterion

### Unit Tests
- **Tool**: Vitest (see [VITEST_GUIDE.md](VITEST_GUIDE.md))
- **Purpose**: Verify individual functions and components
- **When written**: Alongside implementation of each function/component

### Integration Tests
- **Tool**: Vitest with appropriate mocking
- **Purpose**: Verify modules work together correctly
- **When written**: After unit tests, before E2E in the testing pyramid

## Phase-Specific Testing Requirements

### Phase 1: Understand
- Extract acceptance criteria that can become test scenarios
- Ask: "How will we verify this requirement is met?"
- Document: "Given X, when Y, then Z" for each criterion

### Phase 2: Research
- Identify existing test infrastructure and patterns
- Document: test framework, configuration, running commands
- Note: existing fixtures, helpers, mocks

### Phase 3: Scope
- Define which tests are required vs optional
- Identify dependencies that need mocking
- Clarify: what constitutes "done" in terms of test coverage

### Phase 4: Design
- Design test architecture alongside feature architecture
- Document: test file locations, naming conventions, shared fixtures
- Plan: what to mock, what to test in isolation vs integration

### Phase 5: Decompose
- Every task MUST reference its required tests
- Format: "Task: Implement X → Tests: E2E scenario Y, Unit tests for Z"
- Include "Write failing E2E test" as the FIRST task for each feature

### Phase 6: Implement
**CRITICAL**: Follow this sequence for every feature:

1. **Write E2E test first**
   ```typescript
   // Example: tests/e2e/user-login.spec.ts
   test('user can log in with valid credentials', async ({ page }) => {
     await page.goto('/login');
     await page.getByLabel('Email').fill('user@example.com');
     await page.getByLabel('Password').fill('password123');
     await page.getByRole('button', { name: 'Sign in' }).click();
     await expect(page).toHaveURL('/dashboard');
   });
   ```

2. **Run test - verify it FAILS**
   ```bash
   npx playwright test user-login.spec.ts
   # Expected: FAIL - feature doesn't exist yet
   ```

3. **Write minimal code to pass**
   - Implement only what's needed for the test to pass
   - No gold-plating, no "nice to have"

4. **Run test - verify it PASSES**
   ```bash
   npx playwright test user-login.spec.ts
   # Expected: PASS
   ```

5. **Refactor if needed**
   - Clean up code while keeping tests green
   - Add unit tests for complex logic

6. **Repeat for next feature**

### Phase 7: Validate
- Run full test suite
- Check coverage metrics
- Review test quality (not just quantity)
- Verify edge cases are covered

### Phase 8: Deploy
- Run tests against staging/preview environment
- Run smoke tests after deployment
- Monitor for test failures in production

## Test Quality Checklist

### E2E Tests Should:
- [ ] Test complete user workflows, not implementation details
- [ ] Use accessible locators (getByRole, getByLabel) over CSS selectors
- [ ] Include proper cleanup (create→verify→delete patterns)
- [ ] Be idempotent (can run multiple times without side effects)
- [ ] Test both happy path and error scenarios
- [ ] Be readable as documentation of expected behavior

### Unit Tests Should:
- [ ] Test one behavior per test
- [ ] Use descriptive names ("returns null when user not found")
- [ ] Mock external dependencies
- [ ] Cover edge cases and error conditions
- [ ] Be fast and independent

## Anti-Patterns to Avoid

### ❌ Writing Tests After Implementation
Tests written after code often just verify the code does what it does, not what it should do.

### ❌ Skipping E2E Tests
"Unit tests pass" is not the same as "feature works." Always have E2E tests.

### ❌ Tests That Don't Fail First
If you write a test that passes immediately, you haven't verified it tests the right thing.

### ❌ Testing Implementation Details
Test behavior and outcomes, not internal implementation.

### ❌ Flaky Tests
Tests that sometimes pass and sometimes fail destroy trust in the test suite.

## Failure Is Progress

When following TDD:
- A failing test is not a problem—it's a specification
- "Red" state is valuable—it defines what you need to build
- Tests define "done"—when they're green, you're done

## Quick Reference

### Starting a New Feature
```bash
# 1. Create test file
touch tests/e2e/new-feature.spec.ts

# 2. Write failing test
# ... (describe expected behavior)

# 3. Run test - expect failure
npx playwright test new-feature.spec.ts

# 4. Implement feature
# ... (write minimal code)

# 5. Run test - expect pass
npx playwright test new-feature.spec.ts
```

### Running Tests
```bash
# E2E tests (Playwright)
npx playwright test
npx playwright test --ui          # Interactive mode
npx playwright test --debug       # Debug mode

# Unit tests (Vitest)
npx vitest
npx vitest run                    # Single run
npx vitest --ui                   # UI mode
npx vitest run --coverage         # With coverage
```

## References

- [Playwright Testing Guide](PLAYWRIGHT_GUIDE.md) - Complete E2E testing reference
- [Vitest Testing Guide](VITEST_GUIDE.md) - Complete unit testing reference
- [Testing Checklist](checklists/testing-checklist.md) - Phase-by-phase testing verification
