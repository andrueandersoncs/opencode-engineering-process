#!/bin/bash
#
# Phase Validation Criteria Script
# Machine-parseable validation for phase completion
#
# Usage:
#   validate-criteria.sh [phase] [story-slug]
#
# Output: JSON with validation results
#
# Exit codes:
#   0 - All criteria pass (AUTO_ADVANCE)
#   1 - Critical criteria fail (BLOCK)
#   2 - Minor criteria fail (WARN_AND_ADVANCE)
#

set -e

PHASE="${1:-}"
STORY_SLUG="${2:-}"
STORIES_DIR="docs/stories"

# Find active story if not specified
find_active_story() {
    if [ -n "$STORY_SLUG" ]; then
        echo "$STORIES_DIR/$STORY_SLUG"
        return
    fi

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

# Initialize results
RESULTS='{"phase":"","status":"PASS","criteria":[],"recommendation":"AUTO_ADVANCE","message":""}'
CRITERIA='[]'
HAS_CRITICAL_FAIL=false
HAS_MINOR_FAIL=false

# Helper: Add criterion result
add_criterion() {
    local name="$1"
    local status="$2"
    local evidence="$3"
    local blocking="${4:-false}"
    local reason="${5:-}"

    local criterion
    if [ "$status" = "PASS" ]; then
        criterion=$(jq -n --arg name "$name" --arg status "$status" --arg evidence "$evidence" \
            '{name: $name, status: $status, evidence: $evidence}')
    else
        criterion=$(jq -n --arg name "$name" --arg status "$status" --arg reason "$reason" --argjson blocking "$blocking" \
            '{name: $name, status: $status, reason: $reason, blocking: $blocking}')
        if [ "$blocking" = "true" ]; then
            HAS_CRITICAL_FAIL=true
        else
            HAS_MINOR_FAIL=true
        fi
    fi

    CRITERIA=$(echo "$CRITERIA" | jq ". + [$criterion]")
}

# Helper: Check file exists
check_file_exists() {
    local file="$1"
    local name="$2"
    local blocking="${3:-true}"

    if [ -f "$file" ]; then
        add_criterion "$name" "PASS" "$file"
        return 0
    else
        add_criterion "$name" "FAIL" "" "$blocking" "File not found: $file"
        return 1
    fi
}

# Helper: Check file contains section
check_file_contains() {
    local file="$1"
    local pattern="$2"
    local name="$3"
    local blocking="${4:-true}"

    if [ -f "$file" ] && grep -qi "$pattern" "$file" 2>/dev/null; then
        add_criterion "$name" "PASS" "Found in $file"
        return 0
    else
        add_criterion "$name" "FAIL" "" "$blocking" "Pattern '$pattern' not found in $file"
        return 1
    fi
}

# Helper: Check file does NOT contain pattern
check_file_not_contains() {
    local file="$1"
    local pattern="$2"
    local name="$3"
    local blocking="${4:-true}"

    if [ ! -f "$file" ] || ! grep -qi "$pattern" "$file" 2>/dev/null; then
        add_criterion "$name" "PASS" "Pattern not found (good)"
        return 0
    else
        add_criterion "$name" "FAIL" "" "$blocking" "Found prohibited pattern '$pattern' in $file"
        return 1
    fi
}

# No workflow active
if [ -z "$STORY_DIR" ] || [ ! -f "$WORKFLOW_STATE" ]; then
    echo '{"phase":"none","status":"SKIP","criteria":[],"recommendation":"NO_WORKFLOW","message":"No active workflow found"}'
    exit 0
fi

# Get current phase if not specified
if [ -z "$PHASE" ]; then
    PHASE=$(jq -r '.currentPhase // "unknown"' "$WORKFLOW_STATE" 2>/dev/null)
fi

# Validate based on phase
case "$PHASE" in
    "understand")
        # Phase 1: Cannot auto-advance - requires user confirmation
        add_criterion "User confirmation required" "WARN" "" "false" "Understand phase requires user to confirm acceptance criteria"
        HAS_CRITICAL_FAIL=true  # Force block
        ;;

    "research")
        # Phase 2: Research validation
        check_file_exists "$STORY_DIR/research-notes.md" "research-notes.md exists" "true"
        check_file_contains "$STORY_DIR/research-notes.md" "## Relevant Code Locations\|## Code Locations\|## Codebase" \
            "Relevant code locations documented" "true"
        check_file_contains "$STORY_DIR/research-notes.md" "## Test\|test infrastructure\|testing" \
            "Test infrastructure documented" "true"
        check_file_not_contains "$STORY_DIR/research-notes.md" "UNRESOLVED" \
            "No unresolved contradictions" "true"
        ;;

    "scope")
        # Phase 3: Scope validation
        check_file_exists "$STORY_DIR/research-notes.md" "Research phase complete" "true"

        # Check for scope definition in workflow state or research notes
        if jq -e '.scope' "$WORKFLOW_STATE" >/dev/null 2>&1; then
            add_criterion "Scope defined" "PASS" "In workflow-state.json"
        elif grep -qi "## Scope\|## In.Scope\|### In.Scope" "$STORY_DIR/research-notes.md" 2>/dev/null; then
            add_criterion "Scope defined" "PASS" "In research-notes.md"
        else
            add_criterion "Scope defined" "FAIL" "" "false" "Scope not formally documented"
        fi

        # Check for test scope
        check_file_contains "$STORY_DIR/research-notes.md" "test scope\|required.*test\|e2e.*test" \
            "Test scope defined" "true"
        ;;

    "design")
        # Phase 4: Design validation
        check_file_exists "$STORY_DIR/design.md" "design.md exists" "true"
        check_file_not_contains "$STORY_DIR/design.md" "STUCK\|ACTION REQUIRED\|TODO.*BLOCKING" \
            "No stuck points in design" "true"
        check_file_contains "$STORY_DIR/design.md" "test.*architecture\|## Test\|testing strategy" \
            "Test architecture defined" "true"
        check_file_not_contains "$STORY_DIR/design.md" "Open Question.*BLOCKING\|BLOCKING.*question" \
            "No blocking open questions" "true"
        ;;

    "decompose")
        # Phase 5: Decompose validation
        check_file_exists "$STORY_DIR/tasks.md" "tasks.md exists" "true"
        check_file_contains "$STORY_DIR/tasks.md" "e2e\|E2E\|end.to.end" \
            "E2E test task present" "true"
        check_file_contains "$STORY_DIR/tasks.md" "completion criteria\|done when\|complete when" \
            "Tasks have completion criteria" "false"

        # Check first task references tests
        if head -30 "$STORY_DIR/tasks.md" 2>/dev/null | grep -qi "test"; then
            add_criterion "First tasks reference tests" "PASS" "Test references in initial tasks"
        else
            add_criterion "First tasks reference tests" "FAIL" "" "false" "Consider adding test tasks early"
        fi
        ;;

    "implement")
        # Phase 6: Implementation validation
        check_file_exists "$STORY_DIR/tasks.md" "Task breakdown exists" "true"

        # Check all tasks complete
        INCOMPLETE=$(grep -c '^\s*- \[ \]' "$STORY_DIR/tasks.md" 2>/dev/null || echo "0")
        COMPLETE=$(grep -c '^\s*- \[x\]' "$STORY_DIR/tasks.md" 2>/dev/null || echo "0")

        if [ "$INCOMPLETE" = "0" ] && [ "$COMPLETE" -gt "0" ]; then
            add_criterion "All tasks complete" "PASS" "$COMPLETE tasks completed"
        else
            add_criterion "All tasks complete" "FAIL" "" "true" "$INCOMPLETE tasks remaining"
        fi

        # Check for test files (look in common test directories)
        if find . -path "*/tests/*" -name "*.spec.*" -o -path "*/tests/*" -name "*.test.*" \
           -o -path "*/__tests__/*" -name "*.test.*" 2>/dev/null | head -1 | grep -q .; then
            add_criterion "Test files exist" "PASS" "Found test files"
        else
            add_criterion "Test files exist" "FAIL" "" "true" "No test files found"
        fi

        # Check for FIXME/HACK/XXX comments in recently changed files
        # (This is a simplified check - could be enhanced with git diff)
        if git diff --name-only HEAD~5 2>/dev/null | xargs grep -l "FIXME\|HACK\|XXX" 2>/dev/null | head -1 | grep -q .; then
            add_criterion "No FIXME/HACK/XXX comments" "FAIL" "" "false" "Found TODO markers in changed files"
        else
            add_criterion "No FIXME/HACK/XXX comments" "PASS" "Clean"
        fi
        ;;

    "validate")
        # Phase 7: Validation criteria
        # Run tests if available
        if [ -f "package.json" ]; then
            if npm test --if-present 2>/dev/null; then
                add_criterion "Tests pass" "PASS" "npm test succeeded"
            else
                add_criterion "Tests pass" "FAIL" "" "true" "npm test failed"
            fi
        else
            add_criterion "Tests pass" "WARN" "" "false" "No package.json - manual verification needed"
        fi

        # Check for review completion marker
        if [ -f "$STORY_DIR/review.md" ] || grep -qi "review.*complete\|approved" "$STORY_DIR/tasks.md" 2>/dev/null; then
            add_criterion "Code review complete" "PASS" "Review documented"
        else
            add_criterion "Code review complete" "FAIL" "" "false" "No review documentation found"
        fi
        ;;

    "deploy")
        # Phase 8: Cannot auto-advance to production
        add_criterion "User authorization required" "WARN" "" "false" "Production deployment requires explicit user authorization"
        HAS_CRITICAL_FAIL=true  # Force block for production
        ;;

    "complete")
        add_criterion "Workflow complete" "PASS" "All phases done"
        ;;

    *)
        add_criterion "Unknown phase" "FAIL" "" "true" "Phase '$PHASE' not recognized"
        ;;
esac

# Determine recommendation
if [ "$HAS_CRITICAL_FAIL" = "true" ]; then
    STATUS="FAIL"
    RECOMMENDATION="BLOCK"
    MESSAGE="Critical criteria not met. Address issues before proceeding."
    EXIT_CODE=1
elif [ "$HAS_MINOR_FAIL" = "true" ]; then
    STATUS="WARN"
    RECOMMENDATION="WARN_AND_ADVANCE"
    MESSAGE="Minor issues found. Proceeding with warnings."
    EXIT_CODE=2
else
    STATUS="PASS"
    RECOMMENDATION="AUTO_ADVANCE"
    MESSAGE="All criteria met. Ready to proceed."
    EXIT_CODE=0
fi

# Get next phase
declare -A NEXT_PHASE
NEXT_PHASE[understand]="research"
NEXT_PHASE[research]="scope"
NEXT_PHASE[scope]="design"
NEXT_PHASE[design]="decompose"
NEXT_PHASE[decompose]="implement"
NEXT_PHASE[implement]="validate"
NEXT_PHASE[validate]="deploy"
NEXT_PHASE[deploy]="complete"

NEXT="${NEXT_PHASE[$PHASE]:-complete}"

# Output JSON
jq -n \
    --arg phase "$PHASE" \
    --arg status "$STATUS" \
    --argjson criteria "$CRITERIA" \
    --arg recommendation "$RECOMMENDATION" \
    --arg nextPhase "$NEXT" \
    --arg message "$MESSAGE" \
    '{
        phase: $phase,
        status: $status,
        criteria: $criteria,
        recommendation: $recommendation,
        nextPhase: $nextPhase,
        message: $message
    }'

exit $EXIT_CODE
