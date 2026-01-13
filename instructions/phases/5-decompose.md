# Phase 5: Decompose

## Purpose
Break the design into implementable tasks. Create a clear, ordered list of work items that can be completed incrementally.

**CRITICAL: Every task MUST reference its required tests. The first task for any feature should be "Write failing E2E test."**

## Agent
**Delegate to: `@architect`** (continuation from design phase)

## Activities

### 1. Identify Work Items
Break down the design:
- Backend changes
- Frontend changes
- Database migrations
- Configuration changes
- Tests to write

### 2. Size Tasks
Ensure tasks are manageable:
- Each task completable in a few hours
- Each task independently testable
- Each task has clear completion criteria

### 3. Order Tasks
Determine sequence:
- Dependencies between tasks
- Optimal implementation order
- Parallel work opportunities

### 4. Define Completion Criteria (Include Tests)
For each task:
- What constitutes "done"?
- **What tests verify completion? (REQUIRED)**
- What artifacts are produced?

## Output

Create `tasks.md` in the story directory:

```markdown
# Tasks: [Feature Name]

## Overview
Design document: [link to design.md]
Estimated tasks: [count]

## Implementation Order

### Phase 0: Write Failing E2E Tests (MUST BE FIRST)
- [ ] **Task 0.1**: Write E2E test for [main user flow]
  - Files: `tests/e2e/feature.spec.ts`
  - Done when: Test exists and FAILS (feature not implemented yet)
  - Verifies: [acceptance criterion]
  - **Run test to confirm it fails before proceeding**

- [ ] **Task 0.2**: Write E2E test for [error scenarios]
  - Files: `tests/e2e/feature.spec.ts`
  - Done when: Test exists and FAILS
  - Verifies: [acceptance criterion]

### Phase 1: Foundation
Tasks that must complete first.

- [ ] **Task 1.1**: [Title]
  - Description: [What needs to be done]
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]
  - Tests: Task 0.1 should now pass

- [ ] **Task 1.2**: [Title]
  - Description: [What needs to be done]
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]
  - Tests: [What tests verify this]

### Phase 2: Core Implementation
Main feature work.

- [ ] **Task 2.1**: [Title]
  - Description: [What needs to be done]
  - Depends on: Task 1.1, 1.2
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]
  - Tests: [What E2E tests should now pass]

- [ ] **Task 2.2**: [Title]
  - Description: [What needs to be done]
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]
  - Tests: [What tests verify this]

### Phase 3: Integration & Verification
- [ ] **Task 3.1**: Verify all E2E tests pass
  - Done when: All E2E tests from Phase 0 are GREEN
  - Run: `npx playwright test feature.spec.ts`

### Phase 4: Unit Testing (As Needed)
- [ ] **Task 4.1**: Write unit tests for [complex logic]
  - Done when: Unit tests pass, coverage adequate

## Dependencies Graph
```
1.1 ─┬─> 2.1 ─┬─> 3.1
1.2 ─┘        │
2.2 ──────────┘
```

## Notes for Implementer
- [Any special considerations]
- [Gotchas from design phase]
- [Suggested approach for complex tasks]
```

## Task Sizing Guidelines

### Too Small
- "Add import statement"
- "Fix typo in variable name"
→ Combine with related work

### Right Size
- "Implement user validation middleware"
- "Add API endpoint for fetching orders"
- "Create database migration for new table"
→ Can be completed in 1-4 hours

### Too Large
- "Implement authentication system"
- "Build the frontend"
→ Break into smaller tasks

## Completion Criteria

- [ ] All design elements have corresponding tasks
- [ ] Tasks are appropriately sized
- [ ] Dependencies are identified
- [ ] Implementation order is clear
- [ ] Each task has completion criteria
- [ ] tasks.md saved in story directory
- [ ] **CRITICAL: First task(s) are "Write failing E2E test"**
- [ ] **CRITICAL: Every implementation task references which test(s) it satisfies**
- [ ] **CRITICAL: Final task verifies all E2E tests pass**

## Common Pitfalls

1. **Missing Tasks** - Forgetting infrastructure, tests, or config
2. **Wrong Granularity** - Tasks too large or too small
3. **Hidden Dependencies** - Not recognizing task ordering needs
4. **Vague Criteria** - "Done" isn't clearly defined
5. **Tests After Implementation** - Writing tests last instead of first (VIOLATES TDD)
6. **No Test References** - Tasks without clear connection to tests

## Next Phase
Proceed to Phase 6: Implement when criteria are met.
