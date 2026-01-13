# Phase 8: Deploy

## Purpose
Release the implementation to production safely. Monitor for issues and be ready to respond.

## Agent
**Delegate to: `@implementer`** for deployment execution

## Activities

### 1. Pre-Deployment Checks
Verify readiness:
- All validation criteria met
- No blocking issues
- Deployment plan clear
- Rollback plan exists

### 2. Deployment Execution
Execute the release:
- Follow deployment procedures
- Monitor deployment progress
- Verify deployment success

### 3. Post-Deployment Verification
Confirm production state:
- Feature works as expected
- No errors in logs
- Performance acceptable
- Monitoring in place

### 4. Stakeholder Communication
Close the loop:
- Notify relevant parties
- Document what was deployed
- Update tracking systems

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing in CI
- [ ] Code reviewed and approved
- [ ] Database migrations tested (if applicable)
- [ ] Feature flags configured (if applicable)
- [ ] Rollback plan documented
- [ ] On-call/support notified (if applicable)

### During Deployment
- [ ] Deploy to staging first (if available)
- [ ] Verify staging deployment
- [ ] Deploy to production
- [ ] Monitor deployment process

### Post-Deployment
- [ ] Verify feature works in production
- [ ] Check error logs for new errors
- [ ] Verify performance metrics
- [ ] Confirm monitoring/alerting active

### Communication
- [ ] Update issue/ticket status
- [ ] Notify stakeholders
- [ ] Document deployment notes

## Deployment Strategies

### Direct Deploy
For low-risk changes:
- Push to main/master
- CI/CD deploys automatically
- Monitor post-deploy

### Feature Flag
For higher-risk changes:
- Deploy behind flag (disabled)
- Enable for subset of users
- Gradually roll out
- Monitor at each stage

### Blue-Green
For critical changes:
- Deploy to inactive environment
- Test thoroughly
- Switch traffic
- Keep old environment for rollback

## Rollback Plan

Always have a plan:

```markdown
## Rollback Procedure

### Trigger Conditions
- Error rate increases by >X%
- Response time increases by >Yms
- Critical functionality broken

### Rollback Steps
1. [Step 1 - e.g., revert PR]
2. [Step 2 - e.g., deploy previous version]
3. [Step 3 - e.g., verify rollback]

### Post-Rollback
- Document what went wrong
- Investigate root cause
- Plan fix before re-attempting
```

## Monitoring

### What to Watch
- Error rates
- Response times
- Resource utilization
- Business metrics

### Alert Thresholds
- Error rate: [threshold]
- Latency P95: [threshold]
- CPU/Memory: [threshold]

### Duration
- Intensive monitoring: First hour
- Regular checks: First day
- Normal monitoring: After 24h stable

## Completion Criteria

- [ ] Deployment successful
- [ ] Feature verified in production
- [ ] No new errors observed
- [ ] Performance acceptable
- [ ] Stakeholders notified
- [ ] Workflow state marked complete

## Common Pitfalls

1. **Friday Deploys** - Avoid deploying before weekends/holidays
2. **No Monitoring** - Deploying without watching for issues
3. **No Rollback Plan** - Unable to quickly revert if needed
4. **Silent Deploy** - Not communicating changes to stakeholders

## Workflow Completion

After successful deployment:

1. **Update workflow state**:
```json
{
  "currentPhase": "complete",
  "completedPhases": ["understand", "research", "scope", "design", "decompose", "implement", "validate", "deploy"],
  "completedAt": "ISO timestamp"
}
```

2. **Summary report**:
```markdown
## Completed: [Feature Name]

### What Was Delivered
- [Summary of functionality]

### Key Artifacts
- Design: docs/stories/<slug>/design.md
- Tasks: docs/stories/<slug>/tasks.md

### Deployment Details
- Deployed: [date/time]
- Environment: [production]
- Version/Commit: [reference]

### Follow-up Items
- [ ] Item 1 (if any)
- [ ] Item 2 (if any)

### Lessons Learned
- [What went well]
- [What could improve]
```

3. **Celebrate** - Acknowledge the completed work!
