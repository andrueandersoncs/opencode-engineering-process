# Phase 6: Implement

## Purpose
Write tests first, then code that makes them pass. Execute tasks using the **autonomous loop** for fresh context per task.

**CRITICAL: E2E tests MUST be written and verified to FAIL before any implementation code is written.**

## Execution Model: Autonomous Loop

**Phase 6 operates differently from other phases.** Instead of delegating all work to a single agent, this phase uses the **Ralph Wiggum loop pattern**:

```
┌─────────────────────────────────────────────────────────────────┐
│  MAIN AGENT BECOMES SCHEDULER - DO NOT DELEGATE ALL TASKS      │
│                                                                 │
│  Fresh context per task = 100% smart zone utilization          │
└─────────────────────────────────────────────────────────────────┘
```

### Why Loop Mode?

With ~176K usable tokens in a 200K context window:
- **Single-context approach**: Early tasks get full quality, later tasks degrade as context fills
- **Loop approach**: Every task gets fresh context, maintaining quality throughout

### Starting the Loop (Agent-Invoked)

**The orchestrator agent automatically invokes the loop when entering this phase.**

When entering Phase 6, the orchestrator runs:

```bash
./scripts/loop.sh "<story-slug>"
```

The user does NOT need to run this manually - the workflow handles it automatically.

#### Loop Options (for manual runs if needed)

```bash
# Preview without executing (dry run)
DRY_RUN=1 ./scripts/loop.sh "<story-slug>"

# Skip validation between tasks (faster, riskier)
SKIP_VALIDATION=1 ./scripts/loop.sh "<story-slug>"

# Limit iterations
MAX_ITERATIONS=10 ./scripts/loop.sh "<story-slug>"
```

### Loop Execution Flow

```
┌──────────────────────────────────────────────────────────────┐
│  1. Parse tasks.md, find next incomplete task                │
│  2. Mark task as in_progress                                 │
│  3. Spawn FRESH OpenCode context with:                       │
│     - Single task details only                               │
│     - Relevant context (tasks.md, design.md, research.md)    │
│  4. Execute ONE task (@implementer behavior)                 │
│  5. Run validation (tests/lint/typecheck as backpressure)    │
│  6. If PASS: mark task complete, loop to step 1              │
│  7. If FAIL: leave in_progress, report failure               │
│  8. Repeat until all tasks complete                          │
└──────────────────────────────────────────────────────────────┘
```

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

## Pre-Loop Setup

Before starting the loop:

1. **Verify tasks.md exists** with proper structure
2. **Verify first task(s) are "Write failing E2E test"**
3. **Review design.md** to understand the approach
4. **Check test infrastructure** is ready (Playwright, Vitest, etc.)

## Task Execution (Per-Task Behavior)

Each loop iteration spawns a fresh context that:

### 1. Writes E2E Tests FIRST (if task requires)

```typescript
// Example: tests/e2e/user-login.spec.ts
import { test, expect } from '@playwright/test';

test('user can log in with valid credentials', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page).toHaveURL('/dashboard');
  await expect(page.getByText('Welcome')).toBeVisible();
});
```

### 2. Verifies Tests FAIL

```bash
npx playwright test user-login.spec.ts
# Expected output: FAILED (because feature doesn't exist yet)
```

If tests pass immediately, something is wrong:
- Test is not actually testing the new feature
- Test is too vague
- Feature already exists (verify scope)

### 3. Implements to Make Tests Pass

Write the **minimum code** to make the test pass:
1. Read the failing test to understand what's needed
2. Implement only what's required
3. Run the test to verify it passes
4. Commit with clear message

### 4. The Red-Green-Refactor Cycle

```
┌─────────────────────────────────────────────────┐
│  RED: Write failing test                        │
│       ↓                                         │
│  GREEN: Write minimum code to pass              │
│       ↓                                         │
│  REFACTOR: Clean up while staying green         │
│       ↓                                         │
│  COMMIT: Clear message referencing task         │
└─────────────────────────────────────────────────┘
```

## Validation as Backpressure

After each task, the loop runs validation:

```bash
# Auto-detected by run-validation.sh:
- npm test / yarn test / pnpm test
- npm run lint / eslint
- npm run typecheck / tsc --noEmit
```

**Validation failures block progress.** The task remains `in_progress` until:
- The issue is fixed
- The loop is re-run

This creates **downstream backpressure** - invalid work is rejected automatically.

## Implementation Order

Tasks should follow this order (enforced by task dependencies):

```
0. Write E2E tests (MUST BE FIRST)
   ↓ Verify tests FAIL
   ↓
1. Database/Schema changes (if any)
   ↓
2. Data layer / Models
   ↓
3. Business logic / Services + Unit tests
   ↓
4. API endpoints / Controllers
   ↓
5. UI components (if any)
   ↓
6. Integration / Wiring
   ↓
7. Verify all E2E tests PASS
```

## Handling Loop Failures

### Task Execution Failed
```
1. Loop leaves task as in_progress
2. Review the error output
3. Fix the issue manually or adjust task scope
4. Re-run the loop
```

### Validation Failed
```
1. Tests/lint failed after implementation
2. Task remains in_progress
3. Fix the failing tests or lint issues
4. Re-run the loop (it will retry the same task)
```

### Design Doesn't Work
```
1. Stop the loop (Ctrl+C)
2. Document the issue in tasks.md or design.md
3. Return to design phase if needed: /phase design
4. Regenerate tasks if design changed significantly
```

### Blocked by Dependencies
```
1. Check if task dependencies are properly marked
2. Verify blocking tasks are complete
3. If circular dependency: refactor tasks.md
4. Re-run the loop
```

## Commit Guidelines

### Message Format
```
type: short description

Longer explanation if needed.

- Bullet points for details
- Reference to task: Task X.Y
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `test`: Adding tests
- `refactor`: Code change that doesn't change behavior
- `docs`: Documentation changes
- `chore`: Maintenance tasks

### Frequency
- One commit per task (loop handles this naturally)
- Each commit should build/test successfully

## Quality Checklist (Per Task)

Each task completion requires:
- [ ] **E2E test written FIRST and verified to FAIL** (if applicable)
- [ ] **E2E test now PASSES after implementation**
- [ ] Implementation matches design
- [ ] Unit tests cover complex logic
- [ ] All tests pass locally
- [ ] No linting errors
- [ ] No type errors
- [ ] Follows project conventions

## Loop Completion

The loop exits when:
- All tasks in tasks.md are marked `[x]` complete
- Or MAX_ITERATIONS reached (safety limit)

### Success Output
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[INFO] Loop Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Iterations: 8
  Completed:  8
  Failed:     0

[SUCCESS] All tasks completed! Ready for validation phase.
[INFO] Run '/phase validate' to proceed.
```

## Output

After loop completion:
- **All E2E tests passing**
- All implementation tasks complete
- All unit tests passing
- Commit history with clear messages
- tasks.md fully marked complete

## Completion Criteria

- [ ] **CRITICAL: Loop completed successfully (all tasks done)**
- [ ] **CRITICAL: All E2E tests pass**
- [ ] **CRITICAL: Tests were written BEFORE implementation**
- [ ] All tasks in breakdown are complete (`[x]`)
- [ ] All unit tests pass
- [ ] No linting errors
- [ ] Code follows project conventions
- [ ] All commits have clear messages

## Next Phase
Proceed to Phase 7: Validate when the loop completes successfully.
