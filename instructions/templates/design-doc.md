# Design: [Feature Name]

## Overview
[Brief description of what this design addresses - 2-3 sentences]

## Context
- **Story**: [Link to story or description]
- **Research**: [Link to research-notes.md]
- **Scope**: [Brief scope summary]

## Requirements

### Functional
- [ ] Requirement 1 - [description]
- [ ] Requirement 2 - [description]
- [ ] Requirement 3 - [description]

### Non-Functional
- **Performance**: [constraints, e.g., "< 200ms response time"]
- **Security**: [requirements, e.g., "authenticated users only"]
- **Scalability**: [considerations, e.g., "handle 1000 concurrent users"]

## Design

### Architecture

[Describe or diagram the overall structure]

```
[Component diagram or ASCII art showing relationships]
```

**Components**:
- **Component A**: [responsibility]
- **Component B**: [responsibility]

### API Design

```
[METHOD] /api/v1/endpoint

Request:
{
  "field1": "string",
  "field2": number
}

Response:
{
  "id": "string",
  "data": object,
  "created": "ISO timestamp"
}

Errors:
- 400: Validation error
- 401: Not authenticated
- 403: Not authorized
- 404: Resource not found
- 500: Server error
```

### Data Model

**New/Modified Tables**:
```sql
-- [Table name and purpose]
CREATE TABLE example (
  id UUID PRIMARY KEY,
  field1 VARCHAR(255) NOT NULL,
  field2 INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_example_field1 ON example(field1);
```

**Relationships**:
- example -> other_table (one-to-many)

### Key Decisions

#### Decision 1: [Topic]

**Context**: [Why this decision was needed]

**Options Considered**:

1. **Option A**: [name]
   - Pros: [list]
   - Cons: [list]

2. **Option B**: [name]
   - Pros: [list]
   - Cons: [list]

**Decision**: Option [X]

**Rationale**: [Why this option was chosen - 2-3 sentences]

---

#### Decision 2: [Topic]

[Same structure as above]

---

## Implementation Notes

### Approach
[Suggested implementation order or strategy]

### Patterns to Follow
- [Pattern 1 with example location in codebase]
- [Pattern 2 with example location]

### Gotchas
- [Potential issue 1 and how to avoid]
- [Potential issue 2 and how to avoid]

## Testing Strategy

### Unit Tests
- [What components need unit tests]
- [Key behaviors to test]

### Integration Tests
- [What integrations need testing]
- [Key scenarios to cover]

### Edge Cases
- [ ] Edge case 1
- [ ] Edge case 2
- [ ] Edge case 3

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [How to mitigate] |
| [Risk 2] | Low/Med/High | Low/Med/High | [How to mitigate] |

## Open Questions

- [ ] [Question 1 - who needs to answer]
- [ ] [Question 2 - who needs to answer]

## Appendix

### References
- [Link to relevant documentation]
- [Link to similar implementations]

### Diagrams
[Any additional diagrams]
