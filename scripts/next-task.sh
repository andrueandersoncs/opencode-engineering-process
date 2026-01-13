#!/bin/bash
#
# Next Task Extractor
#
# Parses tasks.md and returns the next incomplete task as JSON.
# Respects task dependencies - only returns tasks whose dependencies are complete.
#
# Usage:
#   ./next-task.sh <tasks-file>
#   ./next-task.sh <tasks-file> --count   # Just return count of remaining tasks
#   ./next-task.sh <tasks-file> --all     # Return all incomplete tasks
#
# Output (JSON):
#   {
#     "id": "1.1",
#     "title": "Create user model",
#     "description": "Set up the User model with required fields",
#     "files": "src/models/user.ts",
#     "criteria": "- Model has id, email, password fields\n- TypeScript types defined",
#     "dependencies": "none"
#   }
#
# Task Status Legend (from tasks.md):
#   - [ ]  - Not started (incomplete)
#   - [~]  - In progress
#   - [x]  - Complete
#   - [!]  - Blocked
#

set -e

TASKS_FILE="$1"
MODE="${2:-next}"

if [ -z "$TASKS_FILE" ] || [ ! -f "$TASKS_FILE" ]; then
    echo "Usage: next-task.sh <tasks-file> [--count|--all]" >&2
    exit 1
fi

# Parse the tasks file and extract task information
# This handles both task formats:
# Format 1: #### Task 1.1: Title
# Format 2: - [ ] **Task 1.1**: Title

parse_tasks() {
    local file="$1"
    local in_task=0
    local task_id=""
    local task_title=""
    local task_status=""
    local task_description=""
    local task_files=""
    local task_criteria=""
    local task_dependencies=""
    local current_section=""

    while IFS= read -r line || [ -n "$line" ]; do
        # Check for task header (Format 1: #### Task X.X: Title)
        if [[ "$line" =~ ^####[[:space:]]+Task[[:space:]]+([0-9]+\.[0-9]+):[[:space:]]*(.+)$ ]]; then
            # Output previous task if exists
            if [ -n "$task_id" ]; then
                output_task
            fi

            task_id="${BASH_REMATCH[1]}"
            task_title="${BASH_REMATCH[2]}"
            task_status="incomplete"
            task_description=""
            task_files=""
            task_criteria=""
            task_dependencies=""
            current_section=""
            in_task=1
            continue
        fi

        # Check for task item (Format 2: - [ ] **Task X.X**: Title)
        if [[ "$line" =~ ^-[[:space:]]*\[([[:space:]x~!])\][[:space:]]*\*\*Task[[:space:]]+([0-9]+\.[0-9]+)\*\*:[[:space:]]*(.+)$ ]]; then
            # Output previous task if exists
            if [ -n "$task_id" ]; then
                output_task
            fi

            local status_char="${BASH_REMATCH[1]}"
            task_id="${BASH_REMATCH[2]}"
            task_title="${BASH_REMATCH[3]}"

            case "$status_char" in
                " ") task_status="incomplete" ;;
                "x") task_status="complete" ;;
                "~") task_status="in_progress" ;;
                "!") task_status="blocked" ;;
            esac

            task_description=""
            task_files=""
            task_criteria=""
            task_dependencies=""
            current_section=""
            in_task=1
            continue
        fi

        # If we're in a task, parse its sections
        if [ $in_task -eq 1 ]; then
            # Check for section headers
            if [[ "$line" =~ ^\*\*Description\*\*: ]] || [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\*\*Description\*\*: ]]; then
                current_section="description"
                task_description="${line#*: }"
                continue
            elif [[ "$line" =~ ^\*\*Files\*\*: ]] || [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\*\*Files\*\*: ]]; then
                current_section="files"
                task_files="${line#*: }"
                continue
            elif [[ "$line" =~ ^\*\*Done[[:space:]]when\*\*: ]] || [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\*\*Done[[:space:]]when\*\*: ]]; then
                current_section="criteria"
                task_criteria="${line#*: }"
                continue
            elif [[ "$line" =~ ^\*\*Completion[[:space:]]Criteria\*\*: ]]; then
                current_section="criteria"
                continue
            elif [[ "$line" =~ ^\*\*Dependencies\*\*: ]] || [[ "$line" =~ ^\*\*Depends[[:space:]]on\*\*: ]] || [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\*\*Depends[[:space:]]on\*\*: ]]; then
                current_section="dependencies"
                task_dependencies="${line#*: }"
                continue
            elif [[ "$line" =~ ^\*\*Tests\*\*: ]] || [[ "$line" =~ ^\*\*Notes\*\*: ]]; then
                current_section="other"
                continue
            fi

            # Check for next task or section break
            if [[ "$line" =~ ^---$ ]] || [[ "$line" =~ ^###[[:space:]] ]]; then
                in_task=0
                continue
            fi

            # Append to current section (for multi-line content)
            if [ -n "$current_section" ]; then
                case "$current_section" in
                    "description")
                        [ -n "$task_description" ] && task_description="$task_description\n$line" || task_description="$line"
                        ;;
                    "files")
                        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\` ]] || [[ "$line" =~ ^[[:space:]]*\` ]]; then
                            local file_entry="${line#*\`}"
                            file_entry="${file_entry%%\`*}"
                            [ -n "$task_files" ] && task_files="$task_files, $file_entry" || task_files="$file_entry"
                        fi
                        ;;
                    "criteria")
                        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[ ]]; then
                            [ -n "$task_criteria" ] && task_criteria="$task_criteria\n$line" || task_criteria="$line"
                        fi
                        ;;
                esac
            fi
        fi
    done < "$file"

    # Output last task
    if [ -n "$task_id" ]; then
        output_task
    fi
}

output_task() {
    # Escape for JSON
    local escaped_title escaped_desc escaped_files escaped_criteria escaped_deps
    escaped_title=$(echo "$task_title" | sed 's/\\/\\\\/g; s/"/\\"/g')
    escaped_desc=$(echo -e "$task_description" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')
    escaped_files=$(echo "$task_files" | sed 's/\\/\\\\/g; s/"/\\"/g')
    escaped_criteria=$(echo -e "$task_criteria" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' '|')
    escaped_deps=$(echo "$task_dependencies" | sed 's/\\/\\\\/g; s/"/\\"/g')

    echo "{\"id\":\"$task_id\",\"title\":\"$escaped_title\",\"status\":\"$task_status\",\"description\":\"$escaped_desc\",\"files\":\"$escaped_files\",\"criteria\":\"$escaped_criteria\",\"dependencies\":\"$escaped_deps\"}"
}

# Get all tasks as JSON array
get_all_tasks() {
    echo "["
    local first=1
    while IFS= read -r task; do
        if [ $first -eq 1 ]; then
            first=0
        else
            echo ","
        fi
        echo "$task"
    done < <(parse_tasks "$TASKS_FILE")
    echo "]"
}

# Get completed task IDs
get_completed_ids() {
    parse_tasks "$TASKS_FILE" | jq -r 'select(.status == "complete") | .id'
}

# Check if dependencies are satisfied
deps_satisfied() {
    local deps="$1"
    local completed_ids="$2"

    # No dependencies or "none" means satisfied
    if [ -z "$deps" ] || [ "$deps" = "none" ] || [ "$deps" = "None" ]; then
        return 0
    fi

    # Extract task IDs from dependency string (e.g., "Task 1.1, 1.2" or "1.1, 1.2")
    local dep_ids
    dep_ids=$(echo "$deps" | grep -oE '[0-9]+\.[0-9]+' || true)

    for dep_id in $dep_ids; do
        if ! echo "$completed_ids" | grep -q "^$dep_id$"; then
            return 1
        fi
    done

    return 0
}

# Main logic
case "$MODE" in
    "--count")
        parse_tasks "$TASKS_FILE" | jq -r 'select(.status == "incomplete" or .status == "in_progress") | .id' | wc -l | tr -d ' '
        ;;
    "--all")
        get_all_tasks
        ;;
    *)
        # Get next available task (incomplete with satisfied dependencies)
        completed_ids=$(get_completed_ids)

        # First, check for in_progress tasks (resume those first)
        in_progress=$(parse_tasks "$TASKS_FILE" | jq -r 'select(.status == "in_progress")' | head -1)
        if [ -n "$in_progress" ]; then
            echo "$in_progress"
            exit 0
        fi

        # Then find next incomplete task with satisfied dependencies
        while IFS= read -r task; do
            status=$(echo "$task" | jq -r '.status')
            deps=$(echo "$task" | jq -r '.dependencies')

            if [ "$status" = "incomplete" ]; then
                if deps_satisfied "$deps" "$completed_ids"; then
                    echo "$task"
                    exit 0
                fi
            fi
        done < <(parse_tasks "$TASKS_FILE")

        # No tasks available
        echo ""
        ;;
esac
