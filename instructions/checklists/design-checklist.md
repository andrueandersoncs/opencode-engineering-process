# Design Phase Checklist

Use this checklist to ensure design is complete before implementation.

## Architecture
- [ ] Overall structure clearly described
- [ ] Component responsibilities defined
- [ ] Component interactions documented
- [ ] Fits coherently with existing architecture

## API Design (if applicable)
- [ ] All endpoints specified
- [ ] Request/response formats defined
- [ ] Error responses documented
- [ ] Authentication/authorization specified
- [ ] Versioning considered

## Data Model (if applicable)
- [ ] Schema changes specified
- [ ] New entities/relationships defined
- [ ] Migration strategy documented
- [ ] Validation rules defined
- [ ] Indexes considered for performance

## Key Decisions
- [ ] All significant decisions documented
- [ ] Options considered for each decision
- [ ] Trade-offs explicitly stated
- [ ] Rationale provided for chosen option
- [ ] Rejected alternatives explained

## Test Architecture (CRITICAL)
- [ ] **E2E test scenarios defined for each acceptance criterion**
- [ ] **E2E test file locations specified**
- [ ] **Test dependencies (fixtures, mocks) identified**
- [ ] **Test isolation strategy defined**
- [ ] **Existing test patterns referenced**
- [ ] **Test data setup documented**

## Implementation Guidance
- [ ] Suggested approach documented
- [ ] Patterns to follow identified
- [ ] Gotchas and pitfalls noted
- [ ] **E2E tests to write FIRST are specified**

## Risk Assessment
- [ ] Technical risks identified
- [ ] Integration risks considered
- [ ] Mitigations proposed for each risk
- [ ] Likelihood and impact assessed

## Documentation
- [ ] Design.md created in story directory
- [ ] Follows standard template structure
- [ ] Clear enough for implementer to execute
- [ ] References research findings where relevant

## Quality Check
- [ ] Design is not over-engineered for scope
- [ ] Design addresses all in-scope requirements
- [ ] Constraints from research are incorporated
- [ ] Open questions from research are addressed
- [ ] **Test architecture is complete**
- [ ] **E2E test scenarios cover all acceptance criteria**
