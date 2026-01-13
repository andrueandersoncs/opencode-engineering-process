# Phase 1: Understand

## Purpose
Comprehend the request—not just what's written, but what's meant. Build a mental model of the problem space before considering solutions.

## Agent
None (main conversation handles this phase)

## Activities

### 1. Parse the Input
- If issue URL: Fetch and read the issue content
- If issue number: Locate in the project's issue tracker
- If description: Parse the natural language requirements

### 2. Identify Explicit Requirements
Document what is clearly stated:
- What functionality is requested?
- What behavior is expected?
- What acceptance criteria are provided?

### 3. Identify Implicit Requirements
Surface what's not stated but implied:
- What does the user actually need (vs. what they asked for)?
- What constraints exist from the context?
- What quality attributes matter (performance, security, etc.)?

### 4. Extract Testable Acceptance Criteria (CRITICAL)
For each requirement, define how it will be verified:
- Convert requirements to "Given/When/Then" format
- Ask: "How will we test that this works?"
- Identify what E2E tests are needed
- Document test scenarios alongside requirements

Example:
```
Requirement: Users can log in with email/password
Test Scenario: Given a registered user, when they enter valid credentials, then they see the dashboard
E2E Test: tests/e2e/user-login.spec.ts
```

### 5. Find Gaps and Ambiguities
List questions that need answers:
- What information is missing?
- What terms are ambiguous?
- What edge cases are unspecified?

### 6. Example-Driven Disambiguation (CRITICAL)
Instead of asking abstract questions, use concrete scenarios to clarify:

**Create scenarios that expose undefined behavior:**

```markdown
### Scenario: Normal Login
- User clicks "Login"
- Enters email: alice@example.com
- Enters password: ****
- Result: Redirected to dashboard ✓

### Scenario: Failed Login (Edge Case)
- User clicks "Login"
- Enters wrong password 3 times
- Result: ??? (Account lockout? CAPTCHA? Just fail again?)
```

**Present scenarios to user** - they react to concrete examples more easily than abstract questions.

Use the template at `instructions/templates/scenarios.md` and save to story directory as `scenarios.md`.

### 7. Clarify with User
If there are blocking questions:
- Present the questions clearly using scenarios where possible
- Provide options when possible
- Get explicit answers before proceeding

## Output

Document in the conversation or a notes file:

```markdown
## Understanding: [Feature Name]

### Request Summary
[One paragraph summarizing what's being asked]

### Explicit Requirements
- [ ] Requirement 1
- [ ] Requirement 2

### Implicit Requirements
- [ ] Inferred requirement 1
- [ ] Inferred requirement 2

### Open Questions
- [ ] Question 1 (blocking: yes/no)
- [ ] Question 2 (blocking: yes/no)

### Assumptions
- Assumption 1 (will verify in research)
- Assumption 2 (will verify in research)

### Test Scenarios (REQUIRED)
| Requirement | Test Scenario | Test Type |
|-------------|---------------|-----------|
| Requirement 1 | Given X, when Y, then Z | E2E |
| Requirement 2 | Given A, when B, then C | E2E |
```

## Completion Criteria

- [ ] Core request is understood and can be summarized
- [ ] Explicit requirements are listed
- [ ] Implicit requirements are surfaced
- [ ] Blocking questions are answered (or escalated to user)
- [ ] Assumptions are documented for verification
- [ ] **CRITICAL: Each requirement has a testable acceptance criterion**
- [ ] **CRITICAL: Test scenarios are documented in Given/When/Then format**
- [ ] **CRITICAL: Edge cases explored via concrete scenarios** - `scenarios.md` created if needed
- [ ] **CRITICAL: No scenarios marked with `???` or `UNDEFINED`** - all clarified

## Common Pitfalls

1. **Solution Jumping** - Thinking about implementation before understanding the problem
2. **Assumption Blindness** - Not recognizing implicit assumptions
3. **Scope Creep** - Adding requirements not in the original request
4. **Ambiguity Tolerance** - Proceeding without clarifying vague requirements

## Next Phase
Proceed to Phase 2: Research when criteria are met.
