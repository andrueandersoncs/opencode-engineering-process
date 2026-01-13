# Phase 3: Scope

## Purpose
Define clear boundaries for the work. Distinguish between what must be done now versus what can be done later. Identify the minimal viable implementation.

## Agent
None (main conversation handles this phase, informed by research)

## Activities

### 1. Define In-Scope Items
Based on requirements and research:
- What functionality must be delivered?
- What behavior changes are required?
- What integration points need work?
- **What E2E tests MUST be written (required for every story)?**

### 2. Define Out-of-Scope Items
Explicitly exclude:
- Related but separate work
- Nice-to-haves that aren't required
- Future enhancements
- Technical debt that isn't blocking

### 3. Define Test Scope (CRITICAL)
Specify which tests are required vs. optional:
- **Required E2E tests** (at least one per story, ideally per acceptance criterion)
- Required unit tests (for complex business logic)
- Optional integration tests
- Test coverage expectations

### 4. Identify Minimal Viable Implementation
Find the smallest working solution:
- What's the critical path?
- What can be simplified without losing value?
- What can be deferred to iteration?

### 5. Assess Dependencies
Document what blocks or is blocked by this work:
- Prerequisites that must exist
- Work that depends on this
- External dependencies (APIs, services, teams)

### 6. Risk Assessment
Identify potential issues:
- Technical risks
- Integration risks
- Timeline risks
- Knowledge gaps

## Output

Document scope decisions:

```markdown
## Scope: [Feature Name]

### In Scope
- [ ] Functionality 1 - [brief description]
- [ ] Functionality 2 - [brief description]
- [ ] Integration with [system]

### Out of Scope
- Enhancement A - [reason for exclusion]
- Related feature B - [should be separate ticket]
- Technical improvement C - [not blocking, defer]

### Minimal Viable Implementation
[Description of the smallest valuable increment]

Key simplifications:
- Instead of X, we'll do Y
- Defer Z until validation confirms it's needed

### Dependencies

#### Prerequisites
- [Dependency 1] - [status: exists/needs work]
- [Dependency 2] - [status]

#### Downstream
- [Feature/team] depends on this work

#### External
- [API/service] - [any constraints]

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Strategy] |

### Test Scope (REQUIRED)
| Test Type | Required | File/Location | Status |
|-----------|----------|---------------|--------|
| E2E: User can X | Yes | tests/e2e/feature.spec.ts | Pending |
| E2E: Error handling | Yes | tests/e2e/feature.spec.ts | Pending |
| Unit: Logic Y | Yes | src/__tests__/logic.test.ts | Pending |

### Acceptance Criteria
1. Given [context], when [action], then [result]
2. Given [context], when [action], then [result]
```

## Completion Criteria

- [ ] In-scope items clearly defined
- [ ] Out-of-scope items explicitly listed with reasons
- [ ] Minimal viable implementation identified
- [ ] Dependencies mapped and understood
- [ ] Risks assessed with mitigations
- [ ] Acceptance criteria defined
- [ ] **CRITICAL: Required E2E tests are specified**
- [ ] **CRITICAL: Test coverage expectations are defined**

## Common Pitfalls

1. **Scope Creep** - Adding items without removing others
2. **Gold Plating** - Making things more complex than needed
3. **Unclear Boundaries** - Vague scope that grows during implementation
4. **Missing Dependencies** - Not recognizing what blocks the work

## Negotiation Points

When scope seems too large:
- Can we split into multiple phases?
- What's the 80/20? (80% of value with 20% of effort)
- What's the minimum testable increment?

When scope seems too small:
- Are we addressing the actual user need?
- Will this require immediate follow-up work?
- Are we creating technical debt?

## Next Phase
Proceed to Phase 4: Design when criteria are met.
