#!/bin/bash
#
# Autonomous Loop Orchestrator (Ralph Wiggum Style)
#
# This script implements the "Ralph Playbook" pattern for autonomous AI-assisted
# development. Each iteration:
#   1. Spawns a fresh OpenCode context (avoiding context pollution)
#   2. Loads only the task file and relevant context
#   3. Executes ONE task
#   4. Runs validation (tests/lint as backpressure)
#   5. Updates task status
#   6. Loops until complete
#
# Usage:
#   ./loop.sh [story-slug]
#   ./loop.sh                    # Uses most recent story
#   ./loop.sh add-authentication # Uses specific story
#
# Environment Variables:
#   OPENCODE_BIN    - Path to OpenCode CLI (default: opencode)
#   SKIP_VALIDATION - Set to 1 to skip test/lint validation
#   DRY_RUN         - Set to 1 to print commands without executing
#   MAX_ITERATIONS  - Maximum loop iterations (default: 50, safety limit)
#   CONTEXT_FILES   - Additional files to include (space-separated)
#
# The "Ralph Insight": Fresh context + tight task scope = maximum "smart zone" utilization
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORIES_DIR="docs/stories"

# Configuration
OPENCODE_BIN="${OPENCODE_BIN:-opencode}"
MAX_ITERATIONS="${MAX_ITERATIONS:-50}"
DRY_RUN="${DRY_RUN:-0}"
SKIP_VALIDATION="${SKIP_VALIDATION:-0}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_task() { echo -e "${CYAN}[TASK]${NC} $1"; }

# Find story directory
find_story_dir() {
    local slug="$1"

    if [ -n "$slug" ] && [ -d "$STORIES_DIR/$slug" ]; then
        echo "$STORIES_DIR/$slug"
        return
    fi

    # Find most recently modified story
    if [ -d "$STORIES_DIR" ]; then
        local latest
        latest=$(find "$STORIES_DIR" -name "workflow-state.json" -type f 2>/dev/null | \
            xargs ls -t 2>/dev/null | head -1)
        if [ -n "$latest" ]; then
            dirname "$latest"
            return
        fi
    fi

    echo ""
}

# Check if we're in the implement phase
check_implement_phase() {
    local state_file="$1"
    local phase
    phase=$(jq -r '.currentPhase // "unknown"' "$state_file" 2>/dev/null)

    if [ "$phase" != "implement" ]; then
        log_error "Current phase is '$phase', not 'implement'"
        log_info "The autonomous loop runs during the implement phase."
        log_info "Use '/phase implement' to enter implementation."
        return 1
    fi
    return 0
}

# Build the prompt for Claude
build_prompt() {
    local task_id="$1"
    local task_title="$2"
    local task_description="$3"
    local task_files="$4"
    local task_criteria="$5"
    local story_dir="$6"

    cat <<EOF
# Autonomous Implementation Task

You are executing a single task from an implementation plan. Focus ONLY on this task.

## Current Task: $task_id - $task_title

**Description:**
$task_description

**Files to modify:**
$task_files

**Completion Criteria:**
$task_criteria

## Instructions

1. Implement ONLY what this task requires - no more, no less
2. Write tests FIRST if the task involves new functionality (TDD)
3. Ensure all existing tests still pass
4. When complete, the task criteria above should all be satisfied

## Context Files

The following files have been loaded for context:
- Task breakdown: $story_dir/tasks.md
- Design document: $story_dir/design.md (if exists)
- Research notes: $story_dir/research-notes.md (if exists)

## After Completion

When you've completed the task:
1. Verify the completion criteria are met
2. Run any relevant tests
3. Summarize what was done

Do NOT move on to other tasks. Focus exclusively on: **$task_title**
EOF
}

# Main loop
main() {
    local story_slug="$1"
    local story_dir
    story_dir=$(find_story_dir "$story_slug")

    if [ -z "$story_dir" ] || [ ! -d "$story_dir" ]; then
        log_error "No story found. Start a workflow with '/story'"
        exit 1
    fi

    local state_file="$story_dir/workflow-state.json"
    local tasks_file="$story_dir/tasks.md"

    if [ ! -f "$state_file" ]; then
        log_error "Workflow state not found: $state_file"
        exit 1
    fi

    if [ ! -f "$tasks_file" ]; then
        log_error "Tasks file not found: $tasks_file"
        log_info "Complete the decompose phase to generate tasks."
        exit 1
    fi

    # Verify we're in implement phase
    if ! check_implement_phase "$state_file"; then
        exit 1
    fi

    local story_name
    story_name=$(jq -r '.story // "unknown"' "$state_file")
    local slug
    slug=$(jq -r '.slug // "unknown"' "$state_file")

    log_info "Starting autonomous loop for: $story_name"
    log_info "Story directory: $story_dir"
    log_info "Max iterations: $MAX_ITERATIONS"
    echo ""

    local iteration=0
    local completed=0
    local failed=0

    while [ $iteration -lt $MAX_ITERATIONS ]; do
        iteration=$((iteration + 1))

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Loop iteration $iteration of $MAX_ITERATIONS"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        # Get next task
        local next_task
        next_task=$("$SCRIPT_DIR/next-task.sh" "$tasks_file")

        if [ -z "$next_task" ] || [ "$next_task" = "null" ]; then
            log_success "All tasks completed!"
            break
        fi

        # Parse task JSON
        local task_id task_title task_description task_files task_criteria
        task_id=$(echo "$next_task" | jq -r '.id // "unknown"')
        task_title=$(echo "$next_task" | jq -r '.title // "unknown"')
        task_description=$(echo "$next_task" | jq -r '.description // ""')
        task_files=$(echo "$next_task" | jq -r '.files // ""')
        task_criteria=$(echo "$next_task" | jq -r '.criteria // ""')

        log_task "Task $task_id: $task_title"

        # Mark task as in-progress
        "$SCRIPT_DIR/mark-complete.sh" "$tasks_file" "$task_id" "in_progress"

        # Build prompt
        local prompt
        prompt=$(build_prompt "$task_id" "$task_title" "$task_description" "$task_files" "$task_criteria" "$story_dir")

        # Build context file list
        local context_args=()
        context_args+=("--print" "$tasks_file")
        [ -f "$story_dir/design.md" ] && context_args+=("--print" "$story_dir/design.md")
        [ -f "$story_dir/research-notes.md" ] && context_args+=("--print" "$story_dir/research-notes.md")

        # Add any additional context files
        if [ -n "$CONTEXT_FILES" ]; then
            for cf in $CONTEXT_FILES; do
                [ -f "$cf" ] && context_args+=("--print" "$cf")
            done
        fi

        if [ "$DRY_RUN" = "1" ]; then
            log_info "[DRY RUN] Would execute:"
            echo "$OPENCODE_BIN ${context_args[*]} --prompt \"...\""
            "$SCRIPT_DIR/mark-complete.sh" "$tasks_file" "$task_id" "complete"
            completed=$((completed + 1))
            continue
        fi

        # Execute OpenCode with fresh context
        log_info "Spawning fresh OpenCode context..."

        if $OPENCODE_BIN "${context_args[@]}" --prompt "$prompt"; then
            log_success "Task execution completed"

            # Run validation if not skipped
            if [ "$SKIP_VALIDATION" != "1" ]; then
                log_info "Running validation..."
                if "$SCRIPT_DIR/run-validation.sh"; then
                    log_success "Validation passed"
                    "$SCRIPT_DIR/mark-complete.sh" "$tasks_file" "$task_id" "complete"
                    completed=$((completed + 1))
                else
                    log_error "Validation failed - task remains in progress"
                    log_warn "Fix the issues and re-run the loop"
                    failed=$((failed + 1))
                    # Don't mark complete, leave as in_progress for retry
                fi
            else
                log_warn "Validation skipped (SKIP_VALIDATION=1)"
                "$SCRIPT_DIR/mark-complete.sh" "$tasks_file" "$task_id" "complete"
                completed=$((completed + 1))
            fi
        else
            log_error "Task execution failed"
            failed=$((failed + 1))
            # Leave task as in_progress
        fi

        # Brief pause between iterations
        sleep 1
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Loop Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Iterations: $iteration"
    echo "  Completed:  $completed"
    echo "  Failed:     $failed"

    # Check if all tasks done
    local remaining
    remaining=$("$SCRIPT_DIR/next-task.sh" "$tasks_file" --count 2>/dev/null || echo "0")

    if [ "$remaining" = "0" ]; then
        log_success "All tasks completed! Ready for validation phase."
        log_info "Run '/phase validate' to proceed."
    else
        log_warn "$remaining tasks remaining"
    fi
}

# Show help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<EOF
Autonomous Loop Orchestrator (Ralph Wiggum Style)

Usage:
  ./loop.sh [story-slug]

Options:
  -h, --help    Show this help

Environment Variables:
  OPENCODE_BIN    Path to OpenCode CLI (default: opencode)
  SKIP_VALIDATION Set to 1 to skip test/lint validation
  DRY_RUN         Set to 1 to print commands without executing
  MAX_ITERATIONS  Maximum loop iterations (default: 50)
  CONTEXT_FILES   Additional files to include (space-separated)

Examples:
  ./loop.sh                           # Run on most recent story
  ./loop.sh add-authentication        # Run on specific story
  DRY_RUN=1 ./loop.sh                 # Preview without executing
  SKIP_VALIDATION=1 ./loop.sh         # Skip tests between tasks
  MAX_ITERATIONS=10 ./loop.sh         # Limit to 10 tasks

The Loop Pattern:
  1. Fresh context window (avoid pollution)
  2. Load ONLY task file + relevant context
  3. Execute ONE task
  4. Run validation (backpressure)
  5. Update task status
  6. Repeat
EOF
    exit 0
fi

main "$1"
