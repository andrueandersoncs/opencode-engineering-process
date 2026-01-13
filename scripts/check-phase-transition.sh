#!/bin/bash
#
# Phase Transition Check
# Triggered after Write operations to detect workflow artifact changes
# and validate phase completion criteria
#
# This script:
# 1. Detects if a workflow artifact was written
# 2. Validates the current phase completion criteria
# 3. Checks preconditions for the next phase
# 4. Reports validation results to guide auto-advance decisions
#

# Read stdin for hook input (file path that was written)
if [ -t 0 ]; then
    INPUT=""
else
    INPUT=$(cat)
fi

# Extract file path from hook input (JSON format)
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null)

# If no file path from JSON, check if it's raw path
if [ -z "$FILE_PATH" ] && [ -n "$INPUT" ]; then
    FILE_PATH="$INPUT"
fi

# Bail if no file path
[ -z "$FILE_PATH" ] && exit 0

STORIES_DIR="docs/stories"
SCRIPT_DIR="$(dirname "$0")"

# Check if this is a workflow artifact
is_workflow_artifact() {
    local file="$1"
    case "$file" in
        */workflow-state.json) return 0 ;;
        */research-notes.md) return 0 ;;
        */design.md) return 0 ;;
        */tasks.md) return 0 ;;
        *) return 1 ;;
    esac
}

# Get story directory from file path
get_story_dir() {
    local file="$1"
    if [[ "$file" == *"$STORIES_DIR"* ]]; then
        # Extract story directory (docs/stories/SLUG)
        echo "$file" | sed -E "s|(.*/docs/stories/[^/]+).*|\1|"
    fi
}

# Only process workflow artifacts
if ! is_workflow_artifact "$FILE_PATH"; then
    exit 0
fi

STORY_DIR=$(get_story_dir "$FILE_PATH")
[ -z "$STORY_DIR" ] && exit 0

WORKFLOW_STATE="$STORY_DIR/workflow-state.json"
[ ! -f "$WORKFLOW_STATE" ] && exit 0

# Get current phase
CURRENT_PHASE=$(jq -r '.currentPhase // "unknown"' "$WORKFLOW_STATE" 2>/dev/null)
STORY_SLUG=$(basename "$STORY_DIR")

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Determine which artifact was written and what phase it relates to
WRITTEN_ARTIFACT=$(basename "$FILE_PATH")
case "$WRITTEN_ARTIFACT" in
    "research-notes.md")
        ARTIFACT_PHASE="research"
        ;;
    "design.md")
        ARTIFACT_PHASE="design"
        ;;
    "tasks.md")
        ARTIFACT_PHASE="decompose"
        ;;
    "workflow-state.json")
        # State file updated - check if phase changed
        ARTIFACT_PHASE="$CURRENT_PHASE"
        ;;
    *)
        exit 0
        ;;
esac

echo "" >&2
echo -e "${BLUE}━━━ Phase Validation ━━━${NC}" >&2
echo -e "Story: ${GREEN}$STORY_SLUG${NC}" >&2
echo -e "Current Phase: ${YELLOW}$CURRENT_PHASE${NC}" >&2
echo -e "Artifact Written: $WRITTEN_ARTIFACT" >&2
echo "" >&2

# Run validation for current phase
if [ -x "$SCRIPT_DIR/validate-criteria.sh" ]; then
    VALIDATION_RESULT=$("$SCRIPT_DIR/validate-criteria.sh" "$CURRENT_PHASE" "$STORY_SLUG" 2>/dev/null)
    VALIDATION_EXIT=$?

    # Parse validation result
    STATUS=$(echo "$VALIDATION_RESULT" | jq -r '.status // "UNKNOWN"' 2>/dev/null)
    RECOMMENDATION=$(echo "$VALIDATION_RESULT" | jq -r '.recommendation // "UNKNOWN"' 2>/dev/null)
    MESSAGE=$(echo "$VALIDATION_RESULT" | jq -r '.message // ""' 2>/dev/null)
    NEXT_PHASE=$(echo "$VALIDATION_RESULT" | jq -r '.nextPhase // ""' 2>/dev/null)

    # Display criteria results
    echo -e "${BLUE}Validation Criteria:${NC}" >&2
    echo "$VALIDATION_RESULT" | jq -r '.criteria[]? | "  " + (if .status == "PASS" then "✓" else "✗" end) + " " + .name' 2>/dev/null >&2

    echo "" >&2

    case "$STATUS" in
        "PASS")
            echo -e "${GREEN}✓ All criteria met${NC}" >&2
            echo -e "Recommendation: ${GREEN}$RECOMMENDATION${NC}" >&2
            if [ -n "$NEXT_PHASE" ] && [ "$NEXT_PHASE" != "null" ]; then
                echo -e "Next Phase: ${YELLOW}$NEXT_PHASE${NC}" >&2

                # Check preconditions for next phase
                echo "" >&2
                echo -e "${BLUE}Checking preconditions for $NEXT_PHASE...${NC}" >&2
                if "$SCRIPT_DIR/phase-gate.sh" preconditions "$STORY_SLUG" "$NEXT_PHASE" >/dev/null 2>&1; then
                    echo -e "${GREEN}✓ Preconditions met - ready to advance${NC}" >&2
                else
                    echo -e "${YELLOW}⚠ Some preconditions may need attention${NC}" >&2
                fi
            fi
            ;;
        "WARN")
            echo -e "${YELLOW}⚠ Minor issues found${NC}" >&2
            echo -e "Recommendation: ${YELLOW}$RECOMMENDATION${NC}" >&2
            echo -e "Message: $MESSAGE" >&2
            ;;
        "FAIL")
            echo -e "${RED}✗ Criteria not met${NC}" >&2
            echo -e "Recommendation: ${RED}$RECOMMENDATION${NC}" >&2
            echo -e "Message: $MESSAGE" >&2
            ;;
    esac
else
    echo -e "${YELLOW}⚠ Validation script not found${NC}" >&2
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
echo "" >&2

# Always exit 0 to not block writes
exit 0
