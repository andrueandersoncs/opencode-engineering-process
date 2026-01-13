#!/bin/bash
#
# Post-Write Hook Script
# Runs after file write/edit operations
#
# Can be extended to:
# - Run linters/formatters
# - Update documentation
# - Trigger builds
# - Log changes
#

set -e

# Read hook input from stdin
if [ -t 0 ]; then
    INPUT=""
else
    INPUT=$(cat)
fi

# Extract file path from hook input (if available)
FILE_PATH=""
if [ -n "$INPUT" ]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")
fi

# Skip if no file path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Get file extension
EXTENSION="${FILE_PATH##*.}"

# Optional: Run formatters based on file type
# Uncomment and customize as needed

# case "$EXTENSION" in
#     "ts"|"tsx"|"js"|"jsx")
#         # Run Prettier for TypeScript/JavaScript
#         if command -v npx &> /dev/null && [ -f "package.json" ]; then
#             npx prettier --write "$FILE_PATH" 2>/dev/null || true
#         fi
#         ;;
#     "py")
#         # Run Black for Python
#         if command -v black &> /dev/null; then
#             black "$FILE_PATH" 2>/dev/null || true
#         fi
#         ;;
#     "go")
#         # Run gofmt for Go
#         if command -v gofmt &> /dev/null; then
#             gofmt -w "$FILE_PATH" 2>/dev/null || true
#         fi
#         ;;
#     "rs")
#         # Run rustfmt for Rust
#         if command -v rustfmt &> /dev/null; then
#             rustfmt "$FILE_PATH" 2>/dev/null || true
#         fi
#         ;;
# esac

# Log the write operation (optional)
# echo "[$(date -Iseconds)] Modified: $FILE_PATH" >> .claude/write-log.txt

# Success
exit 0
