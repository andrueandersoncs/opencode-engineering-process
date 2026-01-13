# Preferences Consistency Checklist

## Purpose

Track what users have accepted and rejected over time. New requests should be checked against this history to catch contradictions and maintain consistency.

## Location

Store preferences at: `docs/stories/.preferences.json`

This file is shared across all stories to maintain cross-story memory of user decisions.

## When to Update Preferences

### After User Explicitly Rejects Something
```json
{
  "rejected": [
    {
      "pattern": "modals for confirmations",
      "story": "checkout-flow",
      "date": "2024-01-15",
      "reason": "User said: 'modals are disruptive'"
    }
  ]
}
```

### After User Explicitly Prefers Something
```json
{
  "preferred": [
    {
      "pattern": "toast notifications",
      "story": "checkout-flow",
      "date": "2024-01-15",
      "reason": "Non-blocking feedback"
    }
  ]
}
```

### After Making a Significant Design Decision
```json
{
  "decisions": [
    {
      "topic": "state management",
      "choice": "React Query for server state",
      "alternatives_rejected": ["Redux", "Zustand", "SWR"],
      "story": "data-fetching-refactor",
      "date": "2024-01-20",
      "rationale": "Better caching, less boilerplate"
    }
  ]
}
```

### After Establishing Performance/Quality Constraints
```json
{
  "constraints": [
    {
      "type": "performance",
      "requirement": "API latency < 200ms p95",
      "story": "performance-audit",
      "date": "2024-01-10"
    }
  ]
}
```

## Consistency Check Process

### Before Story Generation / Design Phase

1. **Load preferences file**
   ```bash
   cat docs/stories/.preferences.json
   ```

2. **Check for conflicts with rejected patterns**
   - Does this story require a pattern the user previously rejected?
   - If yes, flag: "This would require [pattern], which was rejected in [story] as [reason]. Has your thinking changed?"

3. **Verify alignment with preferred patterns**
   - Can we use patterns the user has previously preferred?
   - If not using them, document why

4. **Check constraint compliance**
   - Does this design meet established constraints?
   - If violating, explicitly call out the trade-off

5. **Review relevant past decisions**
   - Has a similar decision been made before?
   - If choosing differently, document why

## Example Consistency Check Output

```markdown
## Preference Consistency Check

### Against Rejected Patterns
- [ ] This story does not use "modals for confirmations" (rejected in checkout-flow)
- [!] **CONFLICT**: This design uses a modal for deletion confirmation
  - Previous rejection: "modals are disruptive" (checkout-flow, 2024-01-15)
  - **Question**: Should we use a toast with undo instead? Or has thinking changed?

### Alignment with Preferred Patterns
- [x] Using toast notifications for success feedback (preferred in checkout-flow)
- [x] Using inline validation (preferred in signup-form)

### Constraint Compliance
- [x] API calls designed to meet <200ms p95 requirement
- [ ] N/A - no performance constraints apply

### Related Decisions
- Using React Query for data fetching (decided in data-fetching-refactor)
  - Consistent: Yes, following established pattern
```

## Integration Points

### Story Generator
- Load .preferences.json during Step 2 (Research)
- Check new story against preferences during Step 5 (Counterfactual Probing)
- Document in assumptions.md under "## Preference Consistency"

### Design Phase
- Check proposed design against preferences before finalizing
- Flag any conflicts for user review

### Scope Phase
- Consider preferences when scoping alternatives
- Use preferred patterns by default

## Maintenance

- Review and clean up preferences quarterly
- Remove preferences that are no longer relevant
- Merge duplicate or overlapping entries
- Update dates when patterns are re-confirmed
