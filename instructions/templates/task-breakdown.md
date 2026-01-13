# Tasks: [Feature Name]

## Overview

- **Design Document**: [Link to design.md]
- **Total Tasks**: [count]
- **Estimated Effort**: [rough estimate if known]

## Implementation Order

### Phase 1: Foundation
*Tasks that must complete first - infrastructure, setup, dependencies*

- [ ] **Task 1.1**: [Title]
  - **Description**: [What needs to be done]
  - **Files**: [Expected files to create/modify]
  - **Done when**: [Specific completion criteria]

- [ ] **Task 1.2**: [Title]
  - **Description**: [What needs to be done]
  - **Files**: [Expected files to create/modify]
  - **Done when**: [Specific completion criteria]

---

### Phase 2: Core Implementation
*Main feature work - the meat of the implementation*

- [ ] **Task 2.1**: [Title]
  - **Description**: [What needs to be done]
  - **Depends on**: Task 1.1, 1.2
  - **Files**: [Expected files to create/modify]
  - **Done when**: [Specific completion criteria]

- [ ] **Task 2.2**: [Title]
  - **Description**: [What needs to be done]
  - **Files**: [Expected files to create/modify]
  - **Done when**: [Specific completion criteria]

- [ ] **Task 2.3**: [Title]
  - **Description**: [What needs to be done]
  - **Depends on**: Task 2.1
  - **Files**: [Expected files to create/modify]
  - **Done when**: [Specific completion criteria]

---

### Phase 3: Integration
*Connecting pieces together - wiring, configuration, coordination*

- [ ] **Task 3.1**: [Title]
  - **Description**: [What needs to be done]
  - **Depends on**: Task 2.x
  - **Files**: [Expected files to create/modify]
  - **Done when**: [Specific completion criteria]

---

### Phase 4: Testing
*Dedicated testing tasks - unit, integration, edge cases*

- [ ] **Task 4.1**: Write unit tests for [component]
  - **Description**: Test [specific functionality]
  - **Files**: [test file locations]
  - **Done when**: Tests pass, coverage adequate for component

- [ ] **Task 4.2**: Write integration tests for [feature]
  - **Description**: Test [specific integration]
  - **Files**: [test file locations]
  - **Done when**: Tests pass, key scenarios covered

- [ ] **Task 4.3**: Test edge cases
  - **Description**: Handle and test edge cases:
    - [Edge case 1]
    - [Edge case 2]
  - **Done when**: Edge cases handled and tested

---

### Phase 5: Polish
*Final touches - documentation, cleanup, minor refinements*

- [ ] **Task 5.1**: Update documentation
  - **Description**: Update API docs, README, etc.
  - **Files**: [doc file locations]
  - **Done when**: Documentation is current and accurate

- [ ] **Task 5.2**: Code cleanup
  - **Description**: Remove TODOs, clean up debug code, final review
  - **Done when**: Code is production-ready

---

## Dependencies Graph

```
Phase 1: 1.1 ──┬──> Phase 2: 2.1 ──┬──> 2.3 ──┬──> Phase 3: 3.1
         1.2 ──┘              2.2 ──┘         │
                                              v
                                    Phase 4: 4.1, 4.2, 4.3
                                              │
                                              v
                                    Phase 5: 5.1, 5.2
```

## Temporal Logic Constraints (REQUIRED)

Document ordering, concurrency, and timing constraints:

### Sequence Constraints (A must happen before B)

| Constraint | Type | Rationale |
|------------|------|-----------|
| Auth middleware MUST be deployed before protected routes | Deploy order | Routes depend on auth |
| Database migration MUST complete before API deployment | Deploy order | API needs schema |
| [Constraint] | [Type] | [Why] |

### Mutual Exclusion (A and B cannot run simultaneously)

| Resource/Operation A | Resource/Operation B | Conflict Type |
|---------------------|---------------------|---------------|
| Session creation | Token refresh | Race condition |
| Write to user table | Concurrent user update | Data integrity |
| [Operation A] | [Operation B] | [Conflict type] |

### Liveness Requirements (Must eventually happen)

| Requirement | Trigger | Timeout/Guarantee |
|-------------|---------|-------------------|
| User MUST eventually see confirmation | After purchase | 30 seconds |
| Webhook MUST eventually fire | After state change | 5 retries |
| [Requirement] | [Trigger] | [Guarantee] |

### Atomicity Requirements (All-or-nothing)

| Operation Group | Rollback Strategy | Notes |
|-----------------|-------------------|-------|
| Payment + Order creation | Refund payment if order fails | Saga pattern |
| If payment fails, cart MUST NOT be cleared | No action needed | Preserve state |
| [Operation] | [Rollback] | [Notes] |

### Deadlock Analysis

- [ ] Verified: No circular dependencies in task graph
- [ ] Verified: No resource locks that can block each other
- [ ] Verified: No API calls that wait on each other

Potential deadlocks identified:
1. [None / Description of any found]

## Notes for Implementer

### Key Considerations
- [Important context from design phase]
- [Patterns to follow with file references]
- [Common mistakes to avoid]

### Resources
- [Link to relevant documentation]
- [Link to similar implementations in codebase]

### Blockers/Risks
- [Any known blockers to watch for]
- [Risks identified in design phase]

---

## Progress Tracking

| Phase | Tasks | Completed | Status |
|-------|-------|-----------|--------|
| 1. Foundation | X | 0 | Not started |
| 2. Core | X | 0 | Not started |
| 3. Integration | X | 0 | Not started |
| 4. Testing | X | 0 | Not started |
| 5. Polish | X | 0 | Not started |

**Last Updated**: [date/time]
