# Completion Checklist

Use this checklist before marking the workflow complete.

## Implementation
- [ ] All tasks from breakdown are marked complete
- [ ] Code follows project conventions
- [ ] No linting or type errors
- [ ] No hardcoded values that should be config
- [ ] No sensitive data in code
- [ ] Error handling is appropriate
- [ ] Logging added where useful

## Testing (CRITICAL)
- [ ] **E2E tests were written BEFORE implementation**
- [ ] **E2E tests verify each acceptance criterion**
- [ ] **All E2E tests pass**
- [ ] Unit tests for complex business logic
- [ ] Edge cases covered by tests
- [ ] All tests passing
- [ ] Tests are meaningful, not just coverage padding

## Code Quality
- [ ] Code is readable without extensive comments
- [ ] Functions/methods are focused (single responsibility)
- [ ] No duplicated code
- [ ] Appropriate abstraction level
- [ ] No TODO comments left unaddressed
- [ ] No commented-out code

## Security
- [ ] Input validation on all user input
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets or credentials
- [ ] Authentication checks where needed
- [ ] Authorization checks where needed
- [ ] Sensitive data not logged

## Performance
- [ ] No N+1 query problems
- [ ] Appropriate use of caching
- [ ] No unnecessary database calls
- [ ] No blocking operations in hot paths
- [ ] Pagination for large data sets

## Documentation
- [ ] API documentation updated (if applicable)
- [ ] README updated (if applicable)
- [ ] Code comments where logic is complex
- [ ] Changelog updated (if applicable)

## Review
- [ ] Code review completed
- [ ] All critical issues addressed
- [ ] All major issues addressed
- [ ] Minor issues addressed or documented

## Deployment
- [ ] **E2E tests pass against production/staging**
- [ ] Deployment successful
- [ ] Feature verified in production
- [ ] No new errors observed
- [ ] Performance acceptable
- [ ] Monitoring in place

## Workflow Artifacts
- [ ] research-notes.md complete
- [ ] design.md complete
- [ ] tasks.md with all items checked
- [ ] workflow-state.json updated to complete

## Stakeholder Communication
- [ ] Issue/ticket updated
- [ ] Stakeholders notified
- [ ] Follow-up items documented
