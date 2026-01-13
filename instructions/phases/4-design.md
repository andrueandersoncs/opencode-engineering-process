# Phase 4: Design

## Purpose
Create a technical design that translates requirements into an implementable plan. Document architecture decisions with rationale.

## Agent
**Delegate to: `@architect`**

The architect agent specializes in solution design and documentation.

## Activities

### 1. Architecture Design
Define the overall structure:
- How does this fit into existing architecture?
- What components are needed?
- How do components interact?

### 2. API Design
For any interfaces:
- Endpoint specifications
- Request/response formats
- Error handling approach
- Authentication/authorization

### 3. Data Modeling
For data changes:
- Schema modifications
- New entities/relationships
- Migration strategy
- Data validation rules

### 4. Key Decisions
Document important choices:
- Options considered
- Trade-offs evaluated
- Decision rationale
- Implications

### 5. Implementation Guidance
Prepare for handoff:
- Suggested approach
- Patterns to follow
- Gotchas to avoid
- Testing strategy

## Delegation to Architect Agent

```
@architect Design phase for [feature description]

Research findings: [summary or link to research-notes.md]

Scope:
- [In-scope item 1]
- [In-scope item 2]

Constraints:
- [Constraint 1]
- [Constraint 2]

Key questions to address:
- How should [X] be structured?
- What's the best approach for [Y]?

Expected output:
- Design document at docs/stories/<slug>/design.md
- Task breakdown at docs/stories/<slug>/tasks.md
```

## Output

Create `design.md` in the story directory:

```markdown
# Design: [Feature Name]

## Overview
[Brief description of what this design addresses]

## Context
- Link to research notes
- Key constraints from scope

## Requirements

### Functional
- Requirement 1
- Requirement 2

### Non-Functional
- Performance: [constraints]
- Security: [requirements]
- Scalability: [considerations]

## Design

### Architecture
[System diagram or description]
[Component interactions]

### API Design
```
POST /api/v1/resource
Request: { field1: string, field2: number }
Response: { id: string, created: timestamp }
Errors: 400 (validation), 401 (auth), 500 (server)
```

### Data Model
[Schema changes]
[New tables/collections]
[Relationships]

### Key Decisions

#### Decision 1: [Topic]
**Context**: [Why this decision was needed]
**Options Considered**:
1. Option A
   - Pros: [list]
   - Cons: [list]
2. Option B
   - Pros: [list]
   - Cons: [list]
**Decision**: Option [X]
**Rationale**: [Why this option was chosen]

## Implementation Notes
- [Guidance for implementers]
- [Patterns to follow]
- [Code locations to reference]

## Testing Strategy
- Unit tests: [what to test]
- Integration tests: [what to test]
- Edge cases: [list]

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

## Open Questions
- [ ] Question 1
```

## Completion Criteria

- [ ] Design document created and complete
- [ ] Architecture clearly described
- [ ] Key decisions documented with rationale
- [ ] API contracts defined (if applicable)
- [ ] Data model specified (if applicable)
- [ ] Implementation guidance provided
- [ ] Testing strategy outlined

## Common Pitfalls

1. **Over-Design** - More detail than needed for the scope
2. **Under-Design** - Leaving critical decisions for implementation
3. **Ignoring Constraints** - Not incorporating research findings
4. **Missing Trade-offs** - Not explaining why alternatives were rejected

## Next Phase
Proceed to Phase 5: Decompose when criteria are met.
