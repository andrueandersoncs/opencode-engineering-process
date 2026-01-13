# Phase 7: Validate

## Purpose
Verify that the implementation is correct, secure, and meets all requirements. Catch issues before deployment.

**CRITICAL: Validation primarily means verifying that all tests pass and provide adequate coverage.**

## Agent
**Delegate to: `@reviewer`**

The reviewer agent performs thorough code review without making changes.

## Activities

### 1. Code Review
Examine all changes:
- Logic correctness
- Error handling
- Security considerations
- Code quality

### 2. Test Verification (CRITICAL)
Run and assess ALL tests:
```bash
# Run E2E tests (Playwright) - MUST ALL PASS
npx playwright test
npx playwright test --reporter=html  # For detailed report

# Run unit tests (Vitest)
npx vitest run

# Check coverage
npx vitest run --coverage
```

**Test Coverage Requirements:**
- All E2E tests from the task breakdown must pass
- Unit test coverage should be reasonable for new code
- No skipped or pending tests without documented reasons

### 3. Acceptance Criteria (Verified by Tests)
For each criterion from the user story:
- **Verify there is at least one E2E test covering it**
- Run the specific test to confirm it passes
- Document which test verifies which criterion

**Acceptance criteria are verified by passing tests, not manual inspection.**

### 4. Security Review
Check for vulnerabilities:
- Input validation
- Authentication/authorization
- Data exposure risks
- Injection vulnerabilities

### 5. Documentation Review
Ensure completeness:
- API docs updated
- README updated
- Code comments adequate

## Delegation to Reviewer Agent

```
@reviewer Validation phase for [feature description]

Design document: docs/stories/<slug>/design.md
Implementation summary: [brief description of what was implemented]

Acceptance criteria:
1. [Criterion 1]
2. [Criterion 2]
3. [Criterion 3]

Focus areas:
- [Any specific concerns from implementation]
- [Areas of complexity]

Expected output:
- Code review report
- Acceptance criteria verification
- Recommendation (approve/changes needed)
```

## Validation Checklist

### Correctness
- [ ] Implements all requirements from design
- [ ] Logic handles edge cases
- [ ] Error conditions handled appropriately
- [ ] No regressions to existing functionality

### Security
- [ ] Input validation on all user input
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets
- [ ] Authentication checks where needed
- [ ] Authorization checks where needed
- [ ] Sensitive data not logged

### Performance
- [ ] No N+1 query problems
- [ ] Appropriate use of caching
- [ ] No blocking operations in hot paths
- [ ] Pagination for large data sets

### Testing (CRITICAL)
- [ ] **All E2E tests pass**
- [ ] **E2E tests were written BEFORE implementation**
- [ ] Unit tests for complex business logic
- [ ] Edge cases covered by tests
- [ ] All tests passing

### Documentation
- [ ] API documentation updated
- [ ] README updated
- [ ] Code comments where logic is complex

## Review Outcomes

### Approved
- All criteria met
- No blocking issues
- Ready for deployment

### Changes Requested
- Issues found that must be fixed
- Return to implementation phase
- Re-review after changes

### Needs Discussion
- Fundamental concerns
- Scope questions
- Design reconsideration needed

## Handling Review Feedback

```
┌─────────────────────────────────────────────────────┐
│  If changes requested:                              │
│                                                     │
│  1. Review feedback carefully                       │
│  2. Categorize by severity (critical/major/minor)  │
│  3. Address critical issues first                   │
│  4. Commit fixes with clear messages                │
│  5. Request re-review                               │
│                                                     │
│  If you disagree:                                   │
│  - Discuss with reviewer                            │
│  - Provide rationale                                │
│  - Document decision                                │
└─────────────────────────────────────────────────────┘
```

## Completion Criteria

- [ ] **CRITICAL: All E2E tests pass**
- [ ] **CRITICAL: Each acceptance criterion has a passing test**
- [ ] Code review completed
- [ ] All critical/major issues addressed
- [ ] All unit tests passing
- [ ] Security assessment passed
- [ ] Review approved

## Common Pitfalls

1. **Rubber Stamping** - Approving without thorough review
2. **Nitpicking** - Blocking on style when linters should handle it
3. **Missing Security** - Not checking for common vulnerabilities
4. **Ignoring Edge Cases** - Only testing happy paths
5. **Manual-Only Validation** - Relying on manual testing instead of automated tests
6. **Ignoring Test Coverage** - Not verifying that tests actually cover the acceptance criteria

## Next Phase
Proceed to Phase 8: Deploy when criteria are met.
