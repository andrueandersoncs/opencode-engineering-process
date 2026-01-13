---
description: Jump to or review a specific phase of the engineering process
---

# Engineering Process: Phase Navigation

## Input
**Phase**: $ARGUMENTS

## Valid Phases

| Phase | Description |
|-------|-------------|
| `understand` | Comprehend requirements, identify gaps and ambiguities |
| `research` | Explore codebase, verify assumptions, gather context |
| `scope` | Define boundaries, identify minimal viable implementation |
| `design` | Architecture decisions, API design, data modeling |
| `decompose` | Break work into implementable tasks |
| `implement` | Write code and tests following the design |
| `validate` | Review changes, run tests, verify acceptance criteria |
| `deploy` | Release to production, monitor for issues |

## Actions

### If phase name provided ($ARGUMENTS is not empty):

1. **Find active story** - Look for the most recently modified `workflow-state.json` in `docs/stories/`
2. **Load phase details** from `instructions/phases/<phase-number>-<phase-name>.md`
3. **Update workflow state** to set `currentPhase` to the requested phase
4. **Check prerequisites** - warn if skipping phases that haven't been completed
5. **Execute the phase** following its documented activities

### If no phase name provided:

1. **Read current workflow state** from the active story's `workflow-state.json`
2. **Display current phase** and what's been completed
3. **Show next recommended phase** based on workflow state
4. **List all available stories** with their current phases

## Phase Transitions

When completing a phase:
1. Add the phase to `completedPhases` array in workflow state
2. Record any artifacts created during the phase
3. Run `/checkpoint` to validate completion
4. Proceed to the next phase

## Phase-to-File Mapping

- Phase 1: `instructions/phases/1-understand.md`
- Phase 2: `instructions/phases/2-research.md`
- Phase 3: `instructions/phases/3-scope.md`
- Phase 4: `instructions/phases/4-design.md`
- Phase 5: `instructions/phases/5-decompose.md`
- Phase 6: `instructions/phases/6-implement.md`
- Phase 7: `instructions/phases/7-validate.md`
- Phase 8: `instructions/phases/8-deploy.md`

## Example Usage

```
/phase research    # Jump to research phase
/phase             # Show current status
/phase implement   # Skip to implementation (with warning)
```
