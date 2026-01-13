# Phase 5: Decompose

## Purpose
Break the design into implementable tasks. Create a clear, ordered list of work items that can be completed incrementally.

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

### 4. Define Completion Criteria
For each task:
- What constitutes "done"?
- How will it be verified?
- What artifacts are produced?

## Output

Create `tasks.md` in the story directory:

```markdown
# Tasks: [Feature Name]

## Overview
Design document: [link to design.md]
Estimated tasks: [count]

## Implementation Order

### Phase 1: Foundation
Tasks that must complete first.

- [ ] **Task 1.1**: [Title]
  - Description: [What needs to be done]
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]

- [ ] **Task 1.2**: [Title]
  - Description: [What needs to be done]
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]

### Phase 2: Core Implementation
Main feature work.

- [ ] **Task 2.1**: [Title]
  - Description: [What needs to be done]
  - Depends on: Task 1.1, 1.2
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]

- [ ] **Task 2.2**: [Title]
  - Description: [What needs to be done]
  - Files: [Expected files to touch]
  - Done when: [Completion criteria]

### Phase 3: Integration & Polish
Connecting pieces and refinement.

- [ ] **Task 3.1**: [Title]
  - Description: [What needs to be done]
  - Depends on: Task 2.1, 2.2
  - Done when: [Completion criteria]

### Phase 4: Testing
Test coverage tasks.

- [ ] **Task 4.1**: Write unit tests for [component]
  - Done when: Tests pass, coverage adequate

- [ ] **Task 4.2**: Write integration tests for [feature]
  - Done when: Tests pass, scenarios covered

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

## Common Pitfalls

1. **Missing Tasks** - Forgetting infrastructure, tests, or config
2. **Wrong Granularity** - Tasks too large or too small
3. **Hidden Dependencies** - Not recognizing task ordering needs
4. **Vague Criteria** - "Done" isn't clearly defined

## Next Phase
Proceed to Phase 6: Implement when criteria are met.
