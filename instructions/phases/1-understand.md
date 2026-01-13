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

### 4. Find Gaps and Ambiguities
List questions that need answers:
- What information is missing?
- What terms are ambiguous?
- What edge cases are unspecified?

### 5. Clarify with User
If there are blocking questions:
- Present the questions clearly
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
```

## Completion Criteria

- [ ] Core request is understood and can be summarized
- [ ] Explicit requirements are listed
- [ ] Implicit requirements are surfaced
- [ ] Blocking questions are answered (or escalated to user)
- [ ] Assumptions are documented for verification

## Common Pitfalls

1. **Solution Jumping** - Thinking about implementation before understanding the problem
2. **Assumption Blindness** - Not recognizing implicit assumptions
3. **Scope Creep** - Adding requirements not in the original request
4. **Ambiguity Tolerance** - Proceeding without clarifying vague requirements

## Next Phase
Proceed to Phase 2: Research when criteria are met.
