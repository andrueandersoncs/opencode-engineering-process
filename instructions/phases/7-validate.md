# Phase 7: Validate

## Purpose
Verify that the implementation is correct, secure, and meets all requirements. Catch issues before deployment.

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

### 2. Test Verification
Ensure adequate coverage:
- Run all tests
- Check for missing test cases
- Verify edge case handling

### 3. Acceptance Criteria
Validate each criterion:
- Walk through user scenarios
- Verify expected behavior
- Document verification

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

### Testing
- [ ] Unit tests for business logic
- [ ] Integration tests for API endpoints
- [ ] Edge cases covered
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

- [ ] Code review completed
- [ ] All critical/major issues addressed
- [ ] All tests passing
- [ ] Acceptance criteria verified
- [ ] Security assessment passed
- [ ] Review approved

## Common Pitfalls

1. **Rubber Stamping** - Approving without thorough review
2. **Nitpicking** - Blocking on style when linters should handle it
3. **Missing Security** - Not checking for common vulnerabilities
4. **Ignoring Edge Cases** - Only testing happy paths

## Next Phase
Proceed to Phase 8: Deploy when criteria are met.
