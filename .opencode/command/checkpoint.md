---
description: Validate current phase completion before proceeding
---

# Engineering Process: Checkpoint Validation

## Purpose

Validate that the current phase is complete and ready to proceed to the next phase.

## Validation Steps

### 1. Load Workflow State

Find the active story and read its `workflow-state.json` to determine:
- Current phase
- Completed phases
- Expected artifacts

### 2. Phase-Specific Validation

#### Understand Phase
- [ ] Requirements are documented or clearly understood
- [ ] Ambiguities have been identified
- [ ] Questions for stakeholders are listed (if any)

#### Research Phase
- [ ] Relevant codebase areas identified with file:line references
- [ ] Assumptions explicitly listed and verified
- [ ] Research notes documented in `docs/stories/<slug>/research-notes.md`
- [ ] No blocking questions remain

#### Scope Phase
- [ ] In-scope items clearly defined
- [ ] Out-of-scope items explicitly listed
- [ ] Minimal viable implementation identified
- [ ] Dependencies identified

#### Design Phase
- [ ] Design document exists at `docs/stories/<slug>/design.md`
- [ ] Architecture decisions documented with rationale
- [ ] API contracts defined (if applicable)
- [ ] Data model changes specified (if applicable)
- [ ] Risks and mitigations identified

#### Decompose Phase
- [ ] Task breakdown document exists at `docs/stories/<slug>/tasks.md`
- [ ] Tasks are small enough to complete in a few hours each
- [ ] Tasks have clear completion criteria
- [ ] Dependencies between tasks identified

#### Implement Phase
- [ ] All tasks from breakdown are complete
- [ ] Tests written and passing
- [ ] Code follows project conventions
- [ ] No TODO comments left unaddressed

#### Validate Phase
- [ ] Code review completed (or self-reviewed with @reviewer)
- [ ] All tests pass
- [ ] Acceptance criteria verified
- [ ] No security issues identified
- [ ] Documentation updated

#### Deploy Phase
- [ ] Changes deployed successfully
- [ ] Monitoring in place
- [ ] No errors in production logs
- [ ] Stakeholders notified

### 3. Report Results

Output a structured report:

```
## Checkpoint: [Phase Name]

### Status: [PASS / FAIL / PARTIAL]

### Completed
- [x] Item 1
- [x] Item 2

### Missing
- [ ] Item 3 - [reason/recommendation]

### Artifacts
- Design doc: docs/stories/<slug>/design.md
- Task breakdown: docs/stories/<slug>/tasks.md

### Recommendation
[Proceed to next phase / Complete missing items first]
```

### 4. Update Workflow State

If validation passes:
1. Add current phase to `completedPhases`
2. Update `currentPhase` to next phase
3. Record completion timestamp

## Usage

Run this command:
- After completing phase activities
- Before starting a new phase
- When resuming work after a break
- To get a status overview at any time
