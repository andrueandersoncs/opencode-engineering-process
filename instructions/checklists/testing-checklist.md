# Testing Checklist

**Use this checklist at EVERY phase to ensure test-first discipline is maintained.**

## Core Principle

```
┌─────────────────────────────────────────────────────────────────┐
│ IRON RULE: EVERY USER STORY MUST HAVE E2E TESTS WRITTEN BEFORE │
│            ANY IMPLEMENTATION CODE                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Understand

### Testable Requirements
- [ ] Each requirement is expressed as testable acceptance criteria
- [ ] Acceptance criteria use "Given/When/Then" format
- [ ] Test scenarios are documented alongside requirements
- [ ] Success criteria can be verified by automated tests

### Example Format
```
Requirement: Users can log in with email/password
Given: A registered user
When: They enter valid credentials
Then: They are redirected to the dashboard
E2E Test: tests/e2e/user-login.spec.ts
```

---

## Phase 2: Research

### Test Infrastructure Discovery
- [ ] E2E test framework identified (e.g., Playwright)
- [ ] Unit test framework identified (e.g., Vitest)
- [ ] Test directory structure documented
- [ ] Test configuration files located
- [ ] Commands to run tests documented:
  - [ ] E2E: `npx playwright test`
  - [ ] Unit: `npx vitest run`
  - [ ] Coverage: `npx vitest run --coverage`

### Existing Test Patterns
- [ ] Example E2E tests reviewed
- [ ] Fixture patterns documented
- [ ] Mock patterns documented
- [ ] Test helpers identified
- [ ] Coverage thresholds known

---

## Phase 3: Scope

### Test Scope Definition
- [ ] Required E2E tests listed (at least one per story)
- [ ] Required unit tests listed (for complex logic)
- [ ] Optional tests identified
- [ ] Test coverage expectations defined
- [ ] Test data requirements identified

### Test Scope Table
| Test Type | Required? | File Location | Status |
|-----------|-----------|---------------|--------|
| E2E: Main flow | Yes | tests/e2e/... | Pending |
| E2E: Error cases | Yes | tests/e2e/... | Pending |
| Unit: Logic X | Yes | src/__tests__/... | Pending |

---

## Phase 4: Design

### Test Architecture
- [ ] E2E test scenarios defined for each acceptance criterion
- [ ] E2E test file locations specified
- [ ] Test isolation strategy defined
- [ ] Shared fixtures/helpers planned
- [ ] Test data setup documented
- [ ] Cleanup strategy defined

### Test File Structure
```
tests/
├── e2e/
│   └── feature-name.spec.ts    # E2E tests
├── unit/
│   └── feature-name.test.ts    # Unit tests
└── fixtures/
    └── feature-fixtures.ts      # Shared fixtures
```

---

## Phase 5: Decompose

### Test Tasks (MUST BE FIRST)
- [ ] First task is "Write failing E2E test for [main flow]"
- [ ] Second task is "Write failing E2E test for [error scenarios]"
- [ ] Implementation tasks reference which tests they satisfy
- [ ] Final task is "Verify all E2E tests pass"

### Task Reference Format
```markdown
- [ ] **Task 0.1**: Write failing E2E test for user login
  - Files: tests/e2e/user-login.spec.ts
  - Criteria: Test exists and FAILS
  - Verifies: AC-1 (Users can log in)
```

---

## Phase 6: Implement

### CRITICAL: Test-First Sequence
- [ ] **STEP 1**: E2E test written FIRST
- [ ] **STEP 2**: E2E test runs and FAILS (verified)
- [ ] **STEP 3**: Implementation code written
- [ ] **STEP 4**: E2E test runs and PASSES (verified)

### Red-Green-Refactor Cycle
```
RED:      npx playwright test feature.spec.ts  → FAIL ✓
          (This is correct - feature doesn't exist)

GREEN:    npx playwright test feature.spec.ts  → PASS ✓
          (After implementation)

REFACTOR: Clean up code while tests stay green
```

### Quality Gates
- [ ] No implementation code written before failing test exists
- [ ] Test failure verified before implementation began
- [ ] Test passing verified after implementation complete
- [ ] Unit tests added for complex logic
- [ ] All tests run successfully: `npx playwright test && npx vitest run`

---

## Phase 7: Validate

### Test Verification (CRITICAL)
- [ ] All E2E tests pass: `npx playwright test`
- [ ] All unit tests pass: `npx vitest run`
- [ ] Test coverage meets thresholds: `npx vitest run --coverage`
- [ ] No skipped tests without documented reasons

### Acceptance Criteria → Test Mapping
| Acceptance Criterion | Test File | Test Name | Status |
|---------------------|-----------|-----------|--------|
| AC-1: User can X | tests/e2e/feature.spec.ts | "user can X" | PASS |
| AC-2: Error Y shown | tests/e2e/feature.spec.ts | "shows error Y" | PASS |

### Test Quality Review
- [ ] Tests verify behavior, not implementation details
- [ ] Tests are readable as documentation
- [ ] Tests use accessible locators (getByRole, getByLabel)
- [ ] Tests are idempotent (can run multiple times)
- [ ] Tests include proper cleanup

---

## Phase 8: Deploy

### Pre-Deployment Test Gate
- [ ] All E2E tests pass in CI
- [ ] All unit tests pass in CI
- [ ] Test coverage meets minimum thresholds
- [ ] No failing tests are skipped

### Post-Deployment Verification
- [ ] E2E tests run against staging/production
- [ ] Smoke tests pass
- [ ] No regressions detected

```bash
# Run E2E tests against deployed environment
PLAYWRIGHT_BASE_URL=https://staging.example.com npx playwright test
```

---

## Anti-Patterns to Avoid

### Testing Anti-Patterns
- [ ] ❌ Writing tests AFTER implementation
- [ ] ❌ Tests that pass immediately (not testing new feature)
- [ ] ❌ Skipping the "verify test fails" step
- [ ] ❌ Testing implementation details instead of behavior
- [ ] ❌ Flaky tests that sometimes pass/fail
- [ ] ❌ Tests that depend on each other
- [ ] ❌ Tests with hardcoded waits instead of proper assertions

### How to Fix
If you find yourself with tests written after implementation:
1. STOP
2. Delete or disable the implementation
3. Write the test properly
4. Verify it fails
5. Re-implement
6. Verify it passes

---

## Quick Reference

### Running Tests
```bash
# E2E Tests (Playwright)
npx playwright test                    # Run all E2E tests
npx playwright test feature.spec.ts    # Run specific test
npx playwright test --ui               # Interactive mode
npx playwright test --debug            # Debug mode

# Unit Tests (Vitest)
npx vitest run                         # Run all unit tests
npx vitest run --coverage              # With coverage
npx vitest --ui                        # UI mode
```

### Test File Templates
```typescript
// E2E Test (Playwright)
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test('user can complete main workflow', async ({ page }) => {
    await page.goto('/feature');
    await page.getByLabel('Input').fill('value');
    await page.getByRole('button', { name: 'Submit' }).click();
    await expect(page.getByText('Success')).toBeVisible();
  });
});
```

```typescript
// Unit Test (Vitest)
import { describe, it, expect } from 'vitest';
import { functionToTest } from '../module';

describe('functionToTest', () => {
  it('returns expected result for valid input', () => {
    expect(functionToTest('input')).toBe('expected');
  });
});
```
