#!/bin/bash
#
# Load Issue Script
# Fetches issue content from GitHub/GitLab and formats it for the workflow
#
# Usage:
#   load-issue.sh <issue-url-or-number>
#
# Supports:
#   - GitHub issues: https://github.com/owner/repo/issues/123 or #123
#   - GitLab issues: https://gitlab.com/owner/repo/-/issues/123
#

set -e

INPUT="$1"

# Check if gh CLI is available
HAS_GH=$(command -v gh &> /dev/null && echo "true" || echo "false")

# Check if glab CLI is available
HAS_GLAB=$(command -v glab &> /dev/null && echo "true" || echo "false")

# Parse input to determine issue type and details
parse_github_url() {
    local url="$1"
    # Extract owner, repo, and issue number from GitHub URL
    if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/issues/([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
        return 0
    fi
    return 1
}

parse_gitlab_url() {
    local url="$1"
    # Extract project path and issue number from GitLab URL
    if [[ "$url" =~ gitlab\.com/(.+)/-/issues/([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

# Try to fetch GitHub issue
fetch_github_issue() {
    local repo="$1"
    local issue_num="$2"

    if [ "$HAS_GH" = "false" ]; then
        echo "GitHub CLI (gh) not available. Install with: brew install gh" >&2
        return 1
    fi

    # Fetch issue details
    gh issue view "$issue_num" --repo "$repo" --json title,body,labels,assignees,state 2>/dev/null
}

# Try to fetch GitLab issue
fetch_gitlab_issue() {
    local project="$1"
    local issue_num="$2"

    if [ "$HAS_GLAB" = "false" ]; then
        echo "GitLab CLI (glab) not available. Install with: brew install glab" >&2
        return 1
    fi

    # Fetch issue details
    glab issue view "$issue_num" --repo "$project" --output json 2>/dev/null
}

# Main logic
if [ -z "$INPUT" ]; then
    echo "Usage: load-issue.sh <issue-url-or-number>" >&2
    exit 1
fi

# Check for GitHub URL
if GITHUB_PARSED=$(parse_github_url "$INPUT"); then
    read -r REPO ISSUE_NUM <<< "$GITHUB_PARSED"
    echo "Fetching GitHub issue #$ISSUE_NUM from $REPO..."
    if ISSUE_DATA=$(fetch_github_issue "$REPO" "$ISSUE_NUM"); then
        echo "$ISSUE_DATA"
        exit 0
    fi
fi

# Check for GitLab URL
if GITLAB_PARSED=$(parse_gitlab_url "$INPUT"); then
    read -r PROJECT ISSUE_NUM <<< "$GITLAB_PARSED"
    echo "Fetching GitLab issue #$ISSUE_NUM from $PROJECT..."
    if ISSUE_DATA=$(fetch_gitlab_issue "$PROJECT" "$ISSUE_NUM"); then
        echo "$ISSUE_DATA"
        exit 0
    fi
fi

# Check for bare issue number (assumes current repo)
if [[ "$INPUT" =~ ^#?([0-9]+)$ ]]; then
    ISSUE_NUM="${BASH_REMATCH[1]}"

    # Try GitHub first
    if [ "$HAS_GH" = "true" ]; then
        if ISSUE_DATA=$(gh issue view "$ISSUE_NUM" --json title,body,labels,assignees,state 2>/dev/null); then
            echo "$ISSUE_DATA"
            exit 0
        fi
    fi

    # Try GitLab
    if [ "$HAS_GLAB" = "true" ]; then
        if ISSUE_DATA=$(glab issue view "$ISSUE_NUM" --output json 2>/dev/null); then
            echo "$ISSUE_DATA"
            exit 0
        fi
    fi

    echo "Could not fetch issue #$ISSUE_NUM from current repository." >&2
    echo "Ensure you're in a git repository with a configured remote." >&2
    exit 1
fi

# Input is not a recognized URL or issue number
# Treat as plain text description
echo "Input does not appear to be an issue URL or number."
echo "Treating as plain text story description."
echo ""
echo "Story: $INPUT"

exit 0
