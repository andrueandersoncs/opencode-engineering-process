# User Story Template

Use this template when generating user stories from raw input. Every section is required unless marked optional.

---

# [Story Title]

> Short, descriptive title that captures the capability (e.g., "Add Dark Mode Toggle", "Export Data to CSV")

## Story

> As a **[specific role]**,
> I want **[specific capability]**,
> So that **[specific benefit]**.

**Guidance:**
- **Role**: Be specific. Not "user" but "authenticated user", "admin", "first-time visitor"
- **Capability**: Describe what they want to do, not how
- **Benefit**: The "so that" clause is critical—it explains WHY and prevents solution fixation

## Background

Provide context that helps understand why this story matters:

- What problem does this solve?
- How did this need emerge? (support tickets, user feedback, analytics, etc.)
- What's the current workaround, if any?
- How does this fit into the broader product vision?

**Example:**
> Users have reported difficulty finding the export functionality, with 40% abandoning the workflow at this step. Currently, users must navigate through three menus to access export options. This story addresses the discoverability issue identified in Q3 user research.

## Acceptance Criteria

Criteria must be testable. Use Given/When/Then format for clarity.

### Must Have (P0)

These are non-negotiable for the story to be considered complete.

- [ ] **[Criterion Name]**
  - Given: [precondition/context]
  - When: [action taken]
  - Then: [expected outcome]

- [ ] **[Criterion Name]**
  - Given: [precondition/context]
  - When: [action taken]
  - Then: [expected outcome]

### Should Have (P1)

Important but the story could ship without these in a pinch.

- [ ] **[Criterion Name]**
  - Given: [precondition/context]
  - When: [action taken]
  - Then: [expected outcome]

### Nice to Have (P2)

Would improve the experience but are clearly optional.

- [ ] **[Criterion Name]**
  - Given: [precondition/context]
  - When: [action taken]
  - Then: [expected outcome]

## Edge Cases & Error States

| Scenario | Expected Behavior | Priority |
|----------|-------------------|----------|
| [What if X happens?] | [System should...] | Must Handle / Should Handle / Could Handle |
| [Invalid input case] | [Error message or fallback] | Must Handle / Should Handle / Could Handle |
| [Network failure] | [Graceful degradation] | Must Handle / Should Handle / Could Handle |
| [Permission denied] | [User feedback] | Must Handle / Should Handle / Could Handle |

## Out of Scope

Explicitly list what is NOT part of this story to prevent scope creep:

- [Feature or behavior explicitly excluded]
- [Related functionality that belongs in a different story]
- [Edge case that will be addressed later]
- [Platform or browser not supported in this iteration]

## User Roles & Permissions

| Role | Can Access? | Notes |
|------|-------------|-------|
| [Role 1] | Yes/No | [Any conditions] |
| [Role 2] | Yes/No | [Any conditions] |

## Technical Notes (Optional)

Relevant technical context that might inform implementation:

- Dependencies on existing systems
- Known technical constraints
- Suggested approach (without being prescriptive)
- Performance considerations
- Security implications

## Related Stories (Optional)

- [Link to related story 1] - [relationship: blocks, blocked by, relates to]
- [Link to related story 2] - [relationship]

## Assumptions Made

Document assumptions made during story generation:

| # | Assumption | Confidence | Risk if Wrong | Verification |
|---|------------|------------|---------------|--------------|
| 1 | [What was assumed] | High/Medium/Low | [Impact if incorrect] | [How to verify] |
| 2 | [What was assumed] | High/Medium/Low | [Impact if incorrect] | [How to verify] |

**Guidance:**
- High confidence: Based on clear codebase evidence or common patterns
- Medium confidence: Reasonable inference but should be verified
- Low confidence: Best guess that definitely needs validation

## Open Questions

Questions that require user/stakeholder input:

1. **[Question]**
   - Context: [Why this matters]
   - Options: [Possible answers if known]

2. **[Question]**
   - Context: [Why this matters]
   - Options: [Possible answers if known]

## Sizing Estimate (Optional)

- **T-shirt size**: XS / S / M / L / XL
- **Complexity drivers**: [What makes this simple or complex]
- **Unknown risk**: Low / Medium / High

## Verification Checklist

Before considering this story ready for implementation:

- [ ] Story follows "As a... I want... So that..." format
- [ ] Benefit clause explains the WHY, not just the WHAT
- [ ] All Must Have criteria are testable with Given/When/Then
- [ ] Edge cases are identified with expected behaviors
- [ ] Out of scope is explicitly defined
- [ ] Assumptions are documented with confidence levels
- [ ] Open questions are flagged for stakeholder input

---

## Metadata

```yaml
generated_at: [ISO timestamp]
generated_from: [raw input source]
status: draft | verified | approved | in_progress | complete
story_slug: [kebab-case-identifier]
```
