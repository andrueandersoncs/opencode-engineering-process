#!/bin/bash
#
# Completion Check Script
# Validates workflow completion before allowing Claude to stop
#
# This hook runs on the Stop event and can:
# - Warn about incomplete phases
# - Remind about missing artifacts
# - Block stopping if critical items are missing
#

set -e

WORKFLOW_STATE=".claude/workflow-state.json"

# Read hook input from stdin
if [ -t 0 ]; then
    INPUT=""
else
    INPUT=$(cat)
fi

# If no workflow state, allow stop without warnings
if [ ! -f "$WORKFLOW_STATE" ]; then
    exit 0
fi

# Parse workflow state
CURRENT_PHASE=$(jq -r '.currentPhase // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || echo "unknown")
COMPLETED_PHASES=$(jq -r '.completedPhases // []' "$WORKFLOW_STATE" 2>/dev/null || echo "[]")
STORY=$(jq -r '.story // "unknown"' "$WORKFLOW_STATE" 2>/dev/null || echo "unknown")

# If workflow is complete, allow stop
if [ "$CURRENT_PHASE" = "complete" ]; then
    exit 0
fi

# If in deploy phase and validation is complete, allow stop
if [ "$CURRENT_PHASE" = "deploy" ]; then
    VALIDATE_COMPLETE=$(echo "$COMPLETED_PHASES" | jq 'contains(["validate"])' 2>/dev/null || echo "false")
    if [ "$VALIDATE_COMPLETE" = "true" ]; then
        exit 0
    fi
fi

# Build warning message for incomplete workflow
WARNING=""

case "$CURRENT_PHASE" in
    "understand")
        WARNING="Workflow is in 'understand' phase. Requirements may not be fully captured."
        ;;
    "research")
        WARNING="Workflow is in 'research' phase. Codebase exploration may be incomplete."
        ;;
    "scope")
        WARNING="Workflow is in 'scope' phase. Boundaries may not be fully defined."
        ;;
    "design")
        WARNING="Workflow is in 'design' phase. Solution design may be incomplete."
        ;;
    "decompose")
        WARNING="Workflow is in 'decompose' phase. Task breakdown may be incomplete."
        ;;
    "implement")
        WARNING="Workflow is in 'implement' phase. Implementation may be incomplete."
        ;;
    "validate")
        WARNING="Workflow is in 'validate' phase. Validation may be incomplete."
        ;;
    *)
        WARNING="Workflow is in '$CURRENT_PHASE' phase."
        ;;
esac

# Output JSON to add system message (warning, not blocking)
cat << EOF
{
  "continue": true,
  "systemMessage": "Engineering Process: $WARNING Use /engineering-process:checkpoint to verify status before stopping."
}
EOF

exit 0
