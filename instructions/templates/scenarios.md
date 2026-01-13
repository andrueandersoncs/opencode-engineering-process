# Scenarios: [Feature Name]

> Use concrete scenarios to disambiguate requirements. Instead of asking "what do you mean?", show examples and let the user react.

## Normal Flow Scenarios

### Scenario 1: [Happy Path Name]

**Context**: [Starting state]
**Actor**: [User role]

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | [User action] | [System response] |
| 2 | [User action] | [System response] |
| 3 | [User action] | [System response] |

**End State**: [Final state after scenario completes]

---

### Scenario 2: [Another Normal Path]

**Context**: [Starting state]
**Actor**: [User role]

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | [User action] | [System response] |

**End State**: [Final state]

---

## Edge Case Scenarios

### Scenario E1: [Edge Case Name]

**Context**: [Unusual but valid starting state]
**Actor**: [User role]

| Step | Action | Expected Result | Notes |
|------|--------|-----------------|-------|
| 1 | [Action that triggers edge case] | [Expected behavior - may be UNDEFINED] | [Needs clarification?] |

**Question**: [If behavior is undefined, what should happen?]

**Options**:
- [ ] Option A: [Behavior description]
- [ ] Option B: [Alternative behavior]
- [ ] Option C: [Another alternative]

---

### Scenario E2: [Error Condition]

**Context**: [State that leads to error]
**Actor**: [User role]

| Step | Action | Expected Result | Notes |
|------|--------|-----------------|-------|
| 1 | [Action that causes error] | ??? | UNDEFINED - needs decision |

**Question**: What should happen when [error condition]?

---

## Race Condition Scenarios

### Scenario R1: [Concurrent Action Name]

**Context**: [Multi-user or multi-request scenario]

| Time | Actor A | Actor B | System State |
|------|---------|---------|--------------|
| T1 | [Action] | - | [State] |
| T2 | - | [Action] | [State] |
| T3 | [Action] | [Action] | ??? |

**Question**: When both actors do [action] simultaneously, what happens?

**Options**:
- [ ] First wins
- [ ] Last wins
- [ ] Both fail
- [ ] Merge/conflict resolution
- [ ] Queue operations

---

## Boundary Scenarios

### Scenario B1: [Boundary Name]

**Testing**: [What limit/boundary is being tested]

| Input | Expected Output | Notes |
|-------|-----------------|-------|
| [Min value] | [Result] | |
| [Max value] | [Result] | |
| [Over max] | [Error/truncate/???] | UNDEFINED? |
| [Empty/null] | [Result] | |

---

## Scenario Coverage Matrix

| Requirement | Scenario(s) | Coverage Status |
|-------------|-------------|-----------------|
| [Requirement 1] | S1, S2 | Covered |
| [Requirement 2] | E1 | Partial - edge case undefined |
| [Requirement 3] | None | NOT COVERED |

---

## Unresolved Questions from Scenarios

Questions that emerged from scenario analysis:

1. **[Question from Scenario E1]**
   - Context: [When this matters]
   - Impact: [What breaks if undefined]
   - Suggested default: [If we must assume]

2. **[Question from Scenario R1]**
   - Context: [When this matters]
   - Impact: [What breaks if undefined]
   - Suggested default: [If we must assume]

---

## Notes

- Scenarios marked with `???` or `UNDEFINED` need clarification before implementation
- Use these scenarios as the basis for E2E tests
- Each scenario should map to at least one acceptance criterion
