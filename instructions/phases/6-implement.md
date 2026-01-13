# Phase 6: Implement

## Purpose
Write the code that realizes the design. Follow the task breakdown, write tests alongside code, and maintain quality throughout.

## Agent
**Delegate to: `@implementer`**

The implementer agent has full write access and follows established patterns.

## Activities

### 1. Setup
Before writing code:
- Review design document
- Review task breakdown
- Understand acceptance criteria
- Check existing patterns

### 2. Task Execution
For each task in order:
- Implement the functionality
- Write tests as you go
- Run tests to verify
- Mark task complete

### 3. Quality Checks
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

### Code Quality
- [ ] Follows project style guide
- [ ] No linting errors
- [ ] No hardcoded values that should be config
- [ ] No sensitive data in code
- [ ] Error handling is appropriate

### Testing
- [ ] Unit tests for business logic
- [ ] Integration tests for API endpoints
- [ ] Edge cases covered
- [ ] All tests passing

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

- [ ] All tasks in breakdown are marked complete
- [ ] All tests written and passing
- [ ] Code follows project conventions
- [ ] Changes committed with clear messages
- [ ] No blocking issues remain

## Common Pitfalls

1. **Scope Creep** - Adding features not in design
2. **Skipping Tests** - "I'll add them later"
3. **Ignoring Patterns** - Not following existing conventions
4. **Silent Deviation** - Changing design without documenting

## Next Phase
Proceed to Phase 7: Validate when criteria are met.
