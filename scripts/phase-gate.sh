#!/bin/bash
#
# Phase Gate Validation Script for OpenCode Engineering Process
# Validates phase transitions and enforces workflow constraints
#
# Usage:
#   phase-gate.sh [action] [story-slug]
#
# Actions:
#   check      - Display current phase status
#   validate   - Validate current phase completion
#   list       - List all stories
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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo -e "${BLUE}Engineering Process Stories${NC}"
    echo "==========================="
    if [ -d "$STORIES_DIR" ]; then
        for state_file in "$STORIES_DIR"/*/workflow-state.json; do
            if [ -f "$state_file" ]; then
                DIR=$(dirname "$state_file")
                SLUG=$(basename "$DIR")
                STORY=$(jq -r '.story // "unknown"' "$state_file" 2>/dev/null || echo "unknown")
                PHASE=$(jq -r '.currentPhase // "unknown"' "$state_file" 2>/dev/null || echo "unknown")
                echo -e "  ${GREEN}$SLUG${NC}: $STORY (phase: ${YELLOW}$PHASE${NC})"
            fi
        done
    else
        echo "  No stories found"
    fi
    exit 0
fi

# Check if we're in a workflow
if [ -z "$STORY_DIR" ] || [ ! -f "$WORKFLOW_STATE" ]; then
    echo -e "${YELLOW}No active workflow found${NC}"
    echo "Start a workflow with: /story <description or issue URL>"
    exit 0
fi

# Parse workflow state
CURRENT_PHASE=$(jq -r '.currentPhase // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || echo "unknown")
COMPLETED_PHASES=$(jq -r '.completedPhases // [] | join(", ")' "$WORKFLOW_STATE" 2>/dev/null || echo "")
STORY=$(jq -r '.story // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || echo "unknown")
SLUG=$(jq -r '.slug // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || basename "$STORY_DIR")
STARTED_AT=$(jq -r '.startedAt // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || echo "unknown")

case "$ACTION" in
    "check")
        # Display current phase status
        echo -e "${BLUE}Engineering Process Status${NC}"
        echo "=========================="
        echo -e "Story:     ${GREEN}$STORY${NC}"
        echo -e "Slug:      $SLUG"
        echo -e "Directory: $STORY_DIR"
        echo -e "Phase:     ${YELLOW}$CURRENT_PHASE${NC}"
        echo -e "Completed: $COMPLETED_PHASES"
        echo -e "Started:   $STARTED_AT"
        echo ""

        # Show artifacts
        echo -e "${BLUE}Artifacts:${NC}"
        [ -f "$STORY_DIR/research-notes.md" ] && echo -e "  ${GREEN}✓${NC} research-notes.md"
        [ -f "$STORY_DIR/design.md" ] && echo -e "  ${GREEN}✓${NC} design.md"
        [ -f "$STORY_DIR/tasks.md" ] && echo -e "  ${GREEN}✓${NC} tasks.md"

        [ ! -f "$STORY_DIR/research-notes.md" ] && [ "$CURRENT_PHASE" != "understand" ] && echo -e "  ${RED}✗${NC} research-notes.md (missing)"
        [ ! -f "$STORY_DIR/design.md" ] && [ "$CURRENT_PHASE" = "implement" -o "$CURRENT_PHASE" = "validate" -o "$CURRENT_PHASE" = "deploy" ] && echo -e "  ${RED}✗${NC} design.md (missing)"
        [ ! -f "$STORY_DIR/tasks.md" ] && [ "$CURRENT_PHASE" = "implement" -o "$CURRENT_PHASE" = "validate" -o "$CURRENT_PHASE" = "deploy" ] && echo -e "  ${RED}✗${NC} tasks.md (missing)"

        exit 0
        ;;

    "validate")
        # Validate current phase completion
        echo -e "${BLUE}Validating phase: ${YELLOW}$CURRENT_PHASE${NC} (story: $SLUG)"
        echo ""

        case "$CURRENT_PHASE" in
            "understand")
                echo "Understand phase validation:"
                echo -e "  ${YELLOW}•${NC} Requirements should be documented"
                echo -e "  ${YELLOW}•${NC} Ambiguities should be resolved"
                echo -e "  ${YELLOW}•${NC} Assumptions should be listed"
                ;;
            "research")
                echo "Research phase validation:"
                if [ -f "$STORY_DIR/research-notes.md" ]; then
                    echo -e "  ${GREEN}✓${NC} Research notes exist"
                else
                    echo -e "  ${RED}✗${NC} Research notes not found"
                fi
                ;;
            "scope")
                echo "Scope phase validation:"
                echo -e "  ${YELLOW}•${NC} In-scope items should be defined"
                echo -e "  ${YELLOW}•${NC} Out-of-scope items should be listed"
                echo -e "  ${YELLOW}•${NC} Minimal viable implementation identified"
                ;;
            "design")
                echo "Design phase validation:"
                if [ -f "$STORY_DIR/design.md" ]; then
                    echo -e "  ${GREEN}✓${NC} Design document exists"
                else
                    echo -e "  ${RED}✗${NC} Design document not found"
                fi
                ;;
            "decompose")
                echo "Decompose phase validation:"
                if [ -f "$STORY_DIR/tasks.md" ]; then
                    echo -e "  ${GREEN}✓${NC} Task breakdown exists"
                else
                    echo -e "  ${RED}✗${NC} Task breakdown not found"
                fi
                ;;
            "implement")
                echo "Implement phase validation:"
                if [ -f "$STORY_DIR/tasks.md" ]; then
                    echo -e "  ${GREEN}✓${NC} Task breakdown exists"
                    # Check for incomplete tasks
                    INCOMPLETE=$(grep -c '^\- \[ \]' "$STORY_DIR/tasks.md" 2>/dev/null || echo "0")
                    COMPLETE=$(grep -c '^\- \[x\]' "$STORY_DIR/tasks.md" 2>/dev/null || echo "0")
                    echo -e "  ${BLUE}ℹ${NC} Tasks complete: $COMPLETE"
                    echo -e "  ${BLUE}ℹ${NC} Tasks remaining: $INCOMPLETE"
                else
                    echo -e "  ${RED}✗${NC} Task breakdown not found"
                fi
                ;;
            "validate")
                echo "Validate phase checks:"
                echo -e "  ${YELLOW}•${NC} Ensure code review is complete"
                echo -e "  ${YELLOW}•${NC} Ensure all tests pass"
                echo -e "  ${YELLOW}•${NC} Verify acceptance criteria"
                ;;
            "deploy")
                echo "Deploy phase checks:"
                echo -e "  ${YELLOW}•${NC} Ensure deployment is successful"
                echo -e "  ${YELLOW}•${NC} Ensure monitoring is in place"
                echo -e "  ${YELLOW}•${NC} Notify stakeholders"
                ;;
            "complete")
                echo -e "${GREEN}Workflow is complete!${NC}"
                ;;
        esac

        exit 0
        ;;

    *)
        echo "Unknown action: $ACTION" >&2
        echo "Usage: phase-gate.sh [check|validate|list] [story-slug]" >&2
        exit 1
        ;;
esac
