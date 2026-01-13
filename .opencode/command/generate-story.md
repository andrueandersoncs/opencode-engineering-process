---
description: Generate detailed user stories with assumption-first approach
---

# Generate User Story

Generates a comprehensive, implementation-ready user story from minimal input. The agent does the heavy lifting upfront—making reasonable assumptions, researching context, and producing complete artifacts—then prompts for verification.

## Input

$ARGUMENTS - One of:
- A brief description of the feature or problem (e.g., "add dark mode toggle")
- A GitHub issue URL
- A support ticket or bug report
- Raw user feedback or interview notes
- A vague business request

## Process

### Phase 1: Discovery & Assumption Generation

1. **Parse the input** to extract:
   - Core problem or need
   - Mentioned user roles
   - Implied constraints
   - Any explicit requirements

2. **Delegate to @story-generator** with:
   ```
   @story-generator Research and generate a complete user story.

   Raw Input:
   $ARGUMENTS

   Instructions:
   1. Explore the codebase to understand existing patterns, user roles, and domain context
   2. Make reasonable assumptions about user needs, edge cases, and acceptance criteria
   3. Generate the complete user story artifact
   4. Document all assumptions made

   Expected output: Complete user story at docs/stories/drafts/<story-slug>/user-story.md
   ```

3. **Wait for agent completion** - The agent will:
   - Research the codebase for context
   - Identify relevant user roles from existing code
   - Infer acceptance criteria from similar features
   - Generate testable scenarios
   - Document edge cases
   - Create the full user story document

### Phase 2: Verification Prompt

After artifact generation, present the user with a structured verification:

```markdown
## User Story Generated: [Story Title]

I've generated a complete user story based on your input. Here's a summary:

### Core Story
> As a [role], I want [capability] so that [benefit].

### Key Assumptions Made
1. [Assumption 1] - [Rationale]
2. [Assumption 2] - [Rationale]
3. [Assumption 3] - [Rationale]

### Acceptance Criteria (Generated)
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

### Questions Requiring Your Input
1. [Question about unclear requirement]
2. [Question about priority/scope]

**Full artifact:** `docs/stories/drafts/<story-slug>/user-story.md`

---

Please review and let me know:
- Which assumptions are correct? Which need adjustment?
- Are there missing acceptance criteria?
- Should any scope be added or removed?
```

### Phase 3: Refinement

Based on user feedback:
1. Update the user story document with corrections
2. Re-run verification if significant changes
3. Once approved, move from `drafts/` to active story directory

## Output Structure

Creates directory: `docs/stories/drafts/<story-slug>/`

```
<story-slug>/
├── user-story.md          # Complete user story document
├── assumptions.md         # Documented assumptions with rationale
├── research-context.md    # Codebase research findings
└── generation-state.json  # Tracking metadata
```

## Usage Examples

```
/generate-story add user authentication
/generate-story https://github.com/org/repo/issues/42
/generate-story "Users are complaining they can't find the export button"
/generate-story "We need better mobile support"
```

## Key Principles

1. **Assume first, verify later** - Don't ask clarifying questions upfront; generate artifacts with documented assumptions
2. **Research before assuming** - Use codebase context to make informed assumptions
3. **Make verification easy** - Present assumptions clearly so users can quickly approve or correct
4. **Preserve the "why"** - Always include the benefit clause in user stories
5. **Generate testable criteria** - Every acceptance criterion should be verifiable
