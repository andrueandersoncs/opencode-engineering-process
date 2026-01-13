#!/bin/bash
#
# Phase Gate Validation Script
# Validates phase transitions and enforces workflow constraints
#
# Usage:
#   phase-gate.sh [action] [story-slug] [target-phase]
#
# Actions:
#   pre-write     - Validate before write/edit operations
#   check         - Display current phase status
#   validate      - Validate current phase completion
#   list          - List all stories
#   preconditions - Check preconditions for a phase transition
#
# If story-slug is not provided, uses the most recently modified story.
#

set -e

ACTION="${1:-check}"
STORY_SLUG="${2:-}"
STORIES_DIR="docs/stories"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Read stdin for hook input (if provided)
if [ -t 0 ]; then
    INPUT=""
else
    INPUT=$(cat)
fi

# Find the most recently modified story if no slug provided
find_active_story() {
    if [ -n "$STORY_SLUG" ]; then
        echo "$STORIES_DIR/$STORY_SLUG"
        return
    fi

    # Find most recently modified workflow-state.json
    if [ -d "$STORIES_DIR" ]; then
        LATEST=$(find "$STORIES_DIR" -name "workflow-state.json" -type f 2>/dev/null | \
            xargs ls -t 2>/dev/null | head -1)
        if [ -n "$LATEST" ]; then
            dirname "$LATEST"
            return
        fi
    fi

    echo ""
}

STORY_DIR=$(find_active_story)
WORKFLOW_STATE="$STORY_DIR/workflow-state.json"

# Handle list action separately (doesn't need active story)
if [ "$ACTION" = "list" ]; then
    echo "Engineering Process Stories"
    echo "==========================="
    if [ -d "$STORIES_DIR" ]; then
        for state_file in "$STORIES_DIR"/*/workflow-state.json; do
            if [ -f "$state_file" ]; then
                DIR=$(dirname "$state_file")
                SLUG=$(basename "$DIR")
                STORY=$(jq -r '.story // "unknown"' "$state_file" 2>/dev/null || echo "unknown")
                PHASE=$(jq -r '.currentPhase // "unknown"' "$state_file" 2>/dev/null || echo "unknown")
                echo "  $SLUG: $STORY (phase: $PHASE)"
            fi
        done
    else
        echo "  No stories found"
    fi
    exit 0
fi

# Check if we're in a workflow
if [ -z "$STORY_DIR" ] || [ ! -f "$WORKFLOW_STATE" ]; then
    # No workflow active, allow all operations
    exit 0
fi

# Parse workflow state
CURRENT_PHASE=$(jq -r '.currentPhase // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || echo "unknown")
COMPLETED_PHASES=$(jq -r '.completedPhases // [] | join(",")' "$WORKFLOW_STATE" 2>/dev/null || echo "")
STORY=$(jq -r '.story // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || echo "unknown")
SLUG=$(jq -r '.slug // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || basename "$STORY_DIR")

# Helper function to check if phase is completed
phase_completed() {
    local phase="$1"
    echo "$COMPLETED_PHASES" | grep -q "$phase"
}

# Helper function to check preconditions
check_precondition() {
    local description="$1"
    local test_cmd="$2"
    if eval "$test_cmd" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $description" >&2
        return 0
    else
        echo -e "  ${RED}✗${NC} $description" >&2
        return 1
    fi
}

# Helper function to check for unresolved contradictions
check_no_unresolved_contradictions() {
    local file="$1"
    if [ -f "$file" ]; then
        if grep -qi "UNRESOLVED" "$file" 2>/dev/null; then
            return 1
        fi
    fi
    return 0
}

case "$ACTION" in
    "preconditions")
        # Check preconditions for a target phase
        TARGET_PHASE="${3:-$CURRENT_PHASE}"
        echo -e "${BLUE}Checking preconditions for phase: ${YELLOW}$TARGET_PHASE${NC}"
        echo ""
        PRECONDITIONS_MET=true

        case "$TARGET_PHASE" in
            "research")
                echo "Research phase preconditions:"
                check_precondition "Requirements documented in understand phase" "true" || PRECONDITIONS_MET=false
                ;;
            "scope")
                echo "Scope phase preconditions:"
                check_precondition "Research notes exist" "test -f '$STORY_DIR/research-notes.md'" || PRECONDITIONS_MET=false
                check_precondition "No unresolved contradictions" "check_no_unresolved_contradictions '$STORY_DIR/research-notes.md'" || PRECONDITIONS_MET=false
                check_precondition "Ontology check completed" "grep -q 'Ontology Check' '$STORY_DIR/research-notes.md'" || PRECONDITIONS_MET=false
                ;;
            "design")
                echo "Design phase preconditions:"
                check_precondition "Research notes exist" "test -f '$STORY_DIR/research-notes.md'" || PRECONDITIONS_MET=false
                check_precondition "Scope defined" "true" || PRECONDITIONS_MET=false
                check_precondition "No unresolved contradictions" "check_no_unresolved_contradictions '$STORY_DIR/research-notes.md'" || PRECONDITIONS_MET=false
                ;;
            "decompose")
                echo "Decompose phase preconditions:"
                check_precondition "Design document exists" "test -f '$STORY_DIR/design.md'" || PRECONDITIONS_MET=false
                check_precondition "Test architecture defined" "grep -qi 'test.*architecture\|e2e.*test' '$STORY_DIR/design.md'" || PRECONDITIONS_MET=false
                ;;
            "implement")
                echo "Implement phase preconditions:"
                check_precondition "Design document exists" "test -f '$STORY_DIR/design.md'" || PRECONDITIONS_MET=false
                check_precondition "Task breakdown exists" "test -f '$STORY_DIR/tasks.md'" || PRECONDITIONS_MET=false
                check_precondition "Tasks have test references" "grep -qi 'test:' '$STORY_DIR/tasks.md'" || PRECONDITIONS_MET=false
                check_precondition "No unresolved contradictions" "check_no_unresolved_contradictions '$STORY_DIR/research-notes.md'" || PRECONDITIONS_MET=false
                ;;
            "validate")
                echo "Validate phase preconditions:"
                check_precondition "Task breakdown exists" "test -f '$STORY_DIR/tasks.md'" || PRECONDITIONS_MET=false
                check_precondition "Implementation tasks complete" "! grep -q '^\- \[ \].*Task [0-9]' '$STORY_DIR/tasks.md' 2>/dev/null" || PRECONDITIONS_MET=false
                ;;
            "deploy")
                echo "Deploy phase preconditions:"
                check_precondition "Validation phase complete" "echo '$COMPLETED_PHASES' | grep -q 'validate'" || PRECONDITIONS_MET=false
                ;;
        esac

        if [ "$PRECONDITIONS_MET" = true ]; then
            echo ""
            echo -e "${GREEN}All preconditions met for $TARGET_PHASE phase${NC}"
            exit 0
        else
            echo ""
            echo -e "${RED}Some preconditions not met. Address issues before proceeding.${NC}"
            exit 1
        fi
        ;;

    "pre-write")
        # Validate before write/edit operations

        # Block writes during understand phase
        if [ "$CURRENT_PHASE" = "understand" ]; then
            echo "Phase gate: In 'understand' phase - file modifications not expected yet." >&2
            echo "Tip: Complete requirements analysis before modifying files." >&2
            # Warning only, don't block
            exit 0
        fi

        # Block writes during research phase (explorer agent should be read-only)
        if [ "$CURRENT_PHASE" = "research" ]; then
            echo "Phase gate: In 'research' phase - file modifications should wait." >&2
            echo "Tip: Complete research and move to design phase first." >&2
            # Warning only, don't block
            exit 0
        fi

        # Warn if writing during scope phase
        if [ "$CURRENT_PHASE" = "scope" ]; then
            echo "Phase gate: In 'scope' phase - ensure scope is defined before implementing." >&2
            exit 0
        fi

        # Require design doc before implementation
        if [ "$CURRENT_PHASE" = "implement" ]; then
            DESIGN_DOC="$STORY_DIR/design.md"
            if [ ! -f "$DESIGN_DOC" ]; then
                echo "Phase gate: Design document not found at: $DESIGN_DOC" >&2
                echo "Tip: Complete the design phase before implementing." >&2
                # Warning only
                exit 0
            fi
        fi

        # All checks passed
        exit 0
        ;;

    "check")
        # Display current phase status
        echo "Engineering Process Status"
        echo "=========================="
        echo "Story: $STORY"
        echo "Slug: $SLUG"
        echo "Directory: $STORY_DIR"
        echo "Current Phase: $CURRENT_PHASE"
        echo "Completed: $COMPLETED_PHASES"

        # Show artifacts
        echo "Artifacts:"
        [ -f "$STORY_DIR/research-notes.md" ] && echo "  - research: $STORY_DIR/research-notes.md"
        [ -f "$STORY_DIR/design.md" ] && echo "  - design: $STORY_DIR/design.md"
        [ -f "$STORY_DIR/tasks.md" ] && echo "  - tasks: $STORY_DIR/tasks.md"

        exit 0
        ;;

    "validate")
        # Validate current phase completion
        echo "Validating phase: $CURRENT_PHASE (story: $SLUG)"

        case "$CURRENT_PHASE" in
            "understand")
                echo "Understand phase validation:"
                echo "  - Requirements should be documented"
                echo "  - Ambiguities should be resolved"
                ;;
            "research")
                if [ -f "$STORY_DIR/research-notes.md" ]; then
                    echo "  [OK] Research notes exist: $STORY_DIR/research-notes.md"
                else
                    echo "  [WARN] Research notes not found"
                fi
                ;;
            "design")
                if [ -f "$STORY_DIR/design.md" ]; then
                    echo "  [OK] Design document exists: $STORY_DIR/design.md"
                else
                    echo "  [WARN] Design document not found"
                fi
                ;;
            "implement")
                if [ -f "$STORY_DIR/tasks.md" ]; then
                    echo "  [OK] Task breakdown exists: $STORY_DIR/tasks.md"
                    # Check for incomplete tasks
                    INCOMPLETE=$(grep -c '^\- \[ \]' "$STORY_DIR/tasks.md" 2>/dev/null || echo "0")
                    echo "  [INFO] Incomplete tasks: $INCOMPLETE"
                else
                    echo "  [WARN] Task breakdown not found"
                fi
                ;;
            "validate")
                echo "  - Ensure code review is complete"
                echo "  - Ensure all tests pass"
                ;;
            "deploy")
                echo "  - Ensure deployment is successful"
                echo "  - Ensure monitoring is in place"
                ;;
        esac

        exit 0
        ;;

    *)
        echo "Unknown action: $ACTION" >&2
        echo "Usage: phase-gate.sh [pre-write|check|validate|list|preconditions] [story-slug] [target-phase]" >&2
        exit 1
        ;;
esac
