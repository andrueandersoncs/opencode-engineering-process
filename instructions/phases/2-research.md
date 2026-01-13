# Phase 2: Research

## Purpose
Explore the codebase and verify assumptions before designing a solution. Build a map of the terrain before deciding on a route.

## Agent
**Delegate to: `@explorer`**

The explorer agent has read-only access and specializes in codebase navigation without making changes.

## Activities

### 1. Codebase Exploration
Find relevant existing code:
- Where does related data live?
- What's the current architecture for this area?
- Are there existing APIs or services to leverage?
- What patterns are used for similar features?

### 2. Assumption Verification
For each assumption from Phase 1:
- Find evidence confirming or refuting it
- Document the source (file:line)
- Update understanding if assumptions were wrong

### 3. Technical Research
Investigate external factors:
- Library/framework capabilities
- API specifications
- Performance characteristics
- Rate limits, pagination, caching

### 4. Pattern Recognition
Identify conventions to follow:
- Code style and structure
- Error handling patterns
- Testing approaches
- Naming conventions

### 5. Dependency Mapping
Understand what this feature touches:
- Which files will need changes?
- What systems integrate with this area?
- Are there downstream effects to consider?

## Delegation to Explorer Agent

```
@explorer Research phase for [feature description]

Context: We need to implement [brief description]

Requirements from understand phase:
- [Requirement 1]
- [Requirement 2]

Assumptions to verify:
- [Assumption 1]
- [Assumption 2]

Questions to answer:
- Where does [X] data live?
- How does [Y] currently work?
- What patterns are used for [Z]?

Expected output: Research notes with file:line references
```

## Output

Create `research-notes.md` in the story directory (`docs/stories/<story-slug>/research-notes.md`):

```markdown
# Research Notes: [Feature Name]

## Relevant Code Locations

### [Area 1]
- `path/to/file.ts:45-67` - Description
- `path/to/other.ts:12` - Description

### [Area 2]
- `path/to/file.ts:100` - Description

## Verified Assumptions
- [x] Assumption 1 - Confirmed at `file:line`
- [ ] Assumption 2 - REFUTED: Actually [finding]

## Patterns to Follow
- Error handling: [pattern with example location]
- API responses: [pattern with example location]
- Testing: [pattern with example location]

## Dependencies & Constraints
- [Dependency 1]: [Details]
- [Constraint 1]: [Details]

## External Research
- [Library/API]: [Findings]

## Open Questions Remaining
- [ ] Question 1
- [ ] Question 2

## Recommendations for Design
- Consider using [X] based on [finding]
- Follow pattern from [location]
- Be aware of [constraint]
```

## Completion Criteria

- [ ] All areas of codebase that will be modified are identified
- [ ] Assumptions from Phase 1 are verified or refuted
- [ ] Existing patterns are documented with examples
- [ ] Dependencies and constraints are understood
- [ ] Research notes are saved as an artifact
- [ ] No blocking questions remain

## Common Pitfalls

1. **Shallow Search** - Only looking at obvious locations
2. **Pattern Ignorance** - Not studying how similar features work
3. **Assumption Persistence** - Keeping assumptions despite contradicting evidence
4. **Over-Research** - Exploring beyond what's needed for the task

## Next Phase
Proceed to Phase 3: Scope when criteria are met.
