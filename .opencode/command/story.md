---
description: Start a structured engineering workflow for a user story, issue, or task
---

# Engineering Process: Story Workflow

You are starting a structured engineering workflow for a user story or task.

## Input
**Story/Issue**: $ARGUMENTS

This can be:
- A GitHub/GitLab issue URL
- An issue number (e.g., #123)
- A plain text description of the task

## Initialization Steps

1. **Parse the input** to understand what work is being requested

2. **Generate a story slug** from the input:
   - From title: "Add user authentication" → `add-user-authentication`
   - From issue: "#123" or issue URL → `issue-123`
   - Use lowercase, hyphens for spaces, remove special characters

3. **Create story directory** in the target project:
   ```bash
   mkdir -p docs/stories/<story-slug>
   ```

4. **Create workflow state** at `docs/stories/<story-slug>/workflow-state.json`:
   ```json
   {
     "story": "<parsed story description>",
     "slug": "<story-slug>",
     "source": "<issue URL or 'direct'>",
     "currentPhase": "understand",
     "completedPhases": [],
     "startedAt": "<ISO timestamp>"
   }
   ```

5. **Begin the engineering process** by reading `instructions/ENGINEERING_PROCESS.md`

## Workflow Overview

The process will guide you through these phases:
1. **Understand** - Comprehend requirements, identify gaps
2. **Research** - Explore codebase, verify assumptions (use `@explorer`)
3. **Scope** - Define boundaries, minimal implementation
4. **Design** - Architecture decisions, document approach (use `@architect`)
5. **Decompose** - Break into implementable tasks (use `@architect`)
6. **Implement** - Write code and tests (use `@implementer`)
7. **Validate** - Review, test, verify criteria (use `@reviewer`)
8. **Deploy** - Release and monitor (use `@implementer`)

Each phase has:
- Specific activities and outputs
- A specialized agent when needed
- Validation gates before proceeding

## Begin

Start with Phase 1: Understand. Read the phase details from `instructions/phases/1-understand.md` and work through the activities.
