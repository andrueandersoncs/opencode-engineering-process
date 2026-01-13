#!/bin/bash
#
# Mark Task Complete/In-Progress
#
# Updates the status of a task in tasks.md
#
# Usage:
#   ./mark-complete.sh <tasks-file> <task-id> [status]
#   ./mark-complete.sh docs/stories/auth/tasks.md 1.1 complete
#   ./mark-complete.sh docs/stories/auth/tasks.md 1.1 in_progress
#
# Status options:
#   complete    - Mark as [x] (default)
#   in_progress - Mark as [~]
#   incomplete  - Mark as [ ]
#   blocked     - Mark as [!]
#

set -e

TASKS_FILE="$1"
TASK_ID="$2"
STATUS="${3:-complete}"

if [ -z "$TASKS_FILE" ] || [ -z "$TASK_ID" ]; then
    echo "Usage: mark-complete.sh <tasks-file> <task-id> [complete|in_progress|incomplete|blocked]" >&2
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo "Error: Tasks file not found: $TASKS_FILE" >&2
    exit 1
fi

# Determine the status character
case "$STATUS" in
    "complete"|"done"|"x")
        NEW_STATUS="x"
        STATUS_NAME="complete"
        ;;
    "in_progress"|"progress"|"~")
        NEW_STATUS="~"
        STATUS_NAME="in progress"
        ;;
    "incomplete"|"todo"|" ")
        NEW_STATUS=" "
        STATUS_NAME="incomplete"
        ;;
    "blocked"|"!")
        NEW_STATUS="!"
        STATUS_NAME="blocked"
        ;;
    *)
        echo "Error: Unknown status '$STATUS'" >&2
        echo "Valid: complete, in_progress, incomplete, blocked" >&2
        exit 1
        ;;
esac

# Create a backup
cp "$TASKS_FILE" "$TASKS_FILE.bak"

# Update the task status
# Handle both formats:
# Format 1: #### Task 1.1: Title (status tracked separately or via Completion Criteria checkboxes)
# Format 2: - [ ] **Task 1.1**: Title

UPDATED=0

# For Format 2 (inline checkbox)
if grep -q "\- \[.\] \*\*Task $TASK_ID\*\*" "$TASKS_FILE"; then
    sed -i.tmp "s/\- \[.\] \*\*Task $TASK_ID\*\*/- [$NEW_STATUS] **Task $TASK_ID**/" "$TASKS_FILE"
    UPDATED=1
fi

# For Format 1 (we'll add a status marker comment or update Progress Tracking table)
if [ $UPDATED -eq 0 ] && grep -q "#### Task $TASK_ID:" "$TASKS_FILE"; then
    # Check if there's already a status line after the task header
    if grep -A1 "#### Task $TASK_ID:" "$TASKS_FILE" | grep -q "^\*\*Status\*\*:"; then
        sed -i.tmp "/#### Task $TASK_ID:/,/^\*\*Status\*\*:/{s/^\*\*Status\*\*:.*/\*\*Status\*\*: $STATUS_NAME/}" "$TASKS_FILE"
    else
        # Add status line after task header
        sed -i.tmp "/#### Task $TASK_ID:/a\\
**Status**: $STATUS_NAME
" "$TASKS_FILE"
    fi
    UPDATED=1
fi

# Clean up temp file
rm -f "$TASKS_FILE.tmp"

if [ $UPDATED -eq 1 ]; then
    echo "Task $TASK_ID marked as $STATUS_NAME"

    # Update the Progress Tracking table if it exists
    if grep -q "^| Phase" "$TASKS_FILE"; then
        # Count tasks in each status
        TOTAL=$(grep -cE '(#### Task [0-9]+\.[0-9]+:|\- \[.\] \*\*Task)' "$TASKS_FILE" || echo "0")
        COMPLETE=$(grep -cE '(\- \[x\] \*\*Task|\*\*Status\*\*: complete)' "$TASKS_FILE" || echo "0")
        PERCENT=$((COMPLETE * 100 / TOTAL))

        echo "Progress: $COMPLETE/$TOTAL tasks complete ($PERCENT%)"
    fi
else
    echo "Warning: Task $TASK_ID not found in $TASKS_FILE" >&2
    # Restore backup
    mv "$TASKS_FILE.bak" "$TASKS_FILE"
    exit 1
fi

# Remove backup on success
rm -f "$TASKS_FILE.bak"
