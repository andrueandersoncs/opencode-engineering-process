#!/bin/bash
#
# Run Validation (Backpressure Gate)
#
# Runs tests and linting to validate task completion.
# This provides "backpressure" - constraining the LLM's non-determinism
# through deterministic validation.
#
# Usage:
#   ./run-validation.sh [--quick]
#
# Options:
#   --quick   Run only fast checks (lint, typecheck) without full test suite
#
# Environment Variables:
#   TEST_CMD      - Custom test command (default: auto-detected)
#   LINT_CMD      - Custom lint command (default: auto-detected)
#   TYPECHECK_CMD - Custom typecheck command (default: auto-detected)
#   SKIP_TESTS    - Set to 1 to skip tests
#   SKIP_LINT     - Set to 1 to skip linting
#   SKIP_TYPES    - Set to 1 to skip type checking
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation failed
#

set -e

QUICK_MODE=0
if [ "$1" = "--quick" ]; then
    QUICK_MODE=1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log_run() { echo -e "[RUN] $1"; }

FAILED=0

# Auto-detect project type and available commands
detect_commands() {
    # Node.js / npm / yarn / pnpm / bun
    if [ -f "package.json" ]; then
        # Detect package manager
        if [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
            PKG_MGR="bun"
        elif [ -f "pnpm-lock.yaml" ]; then
            PKG_MGR="pnpm"
        elif [ -f "yarn.lock" ]; then
            PKG_MGR="yarn"
        else
            PKG_MGR="npm"
        fi

        # Check for scripts in package.json
        if [ -z "$TEST_CMD" ]; then
            if jq -e '.scripts.test' package.json >/dev/null 2>&1; then
                TEST_CMD="$PKG_MGR run test"
            elif jq -e '.scripts["test:unit"]' package.json >/dev/null 2>&1; then
                TEST_CMD="$PKG_MGR run test:unit"
            fi
        fi

        if [ -z "$LINT_CMD" ]; then
            if jq -e '.scripts.lint' package.json >/dev/null 2>&1; then
                LINT_CMD="$PKG_MGR run lint"
            elif jq -e '.scripts["lint:check"]' package.json >/dev/null 2>&1; then
                LINT_CMD="$PKG_MGR run lint:check"
            fi
        fi

        if [ -z "$TYPECHECK_CMD" ]; then
            if jq -e '.scripts.typecheck' package.json >/dev/null 2>&1; then
                TYPECHECK_CMD="$PKG_MGR run typecheck"
            elif jq -e '.scripts["type-check"]' package.json >/dev/null 2>&1; then
                TYPECHECK_CMD="$PKG_MGR run type-check"
            elif jq -e '.scripts.tsc' package.json >/dev/null 2>&1; then
                TYPECHECK_CMD="$PKG_MGR run tsc"
            elif [ -f "tsconfig.json" ]; then
                TYPECHECK_CMD="$PKG_MGR exec tsc --noEmit"
            fi
        fi
    fi

    # Python
    if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        if [ -z "$TEST_CMD" ]; then
            if command -v pytest >/dev/null 2>&1; then
                TEST_CMD="pytest"
            elif [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null; then
                TEST_CMD="python -m pytest"
            fi
        fi

        if [ -z "$LINT_CMD" ]; then
            if command -v ruff >/dev/null 2>&1; then
                LINT_CMD="ruff check ."
            elif command -v flake8 >/dev/null 2>&1; then
                LINT_CMD="flake8"
            fi
        fi

        if [ -z "$TYPECHECK_CMD" ]; then
            if command -v mypy >/dev/null 2>&1; then
                TYPECHECK_CMD="mypy ."
            elif command -v pyright >/dev/null 2>&1; then
                TYPECHECK_CMD="pyright"
            fi
        fi
    fi

    # Go
    if [ -f "go.mod" ]; then
        [ -z "$TEST_CMD" ] && TEST_CMD="go test ./..."
        [ -z "$LINT_CMD" ] && command -v golangci-lint >/dev/null 2>&1 && LINT_CMD="golangci-lint run"
        [ -z "$TYPECHECK_CMD" ] && TYPECHECK_CMD="go build ./..."
    fi

    # Rust
    if [ -f "Cargo.toml" ]; then
        [ -z "$TEST_CMD" ] && TEST_CMD="cargo test"
        [ -z "$LINT_CMD" ] && LINT_CMD="cargo clippy -- -D warnings"
        [ -z "$TYPECHECK_CMD" ] && TYPECHECK_CMD="cargo check"
    fi

    # Makefile targets
    if [ -f "Makefile" ]; then
        [ -z "$TEST_CMD" ] && grep -q "^test:" Makefile && TEST_CMD="make test"
        [ -z "$LINT_CMD" ] && grep -q "^lint:" Makefile && LINT_CMD="make lint"
        [ -z "$TYPECHECK_CMD" ] && grep -q "^typecheck:" Makefile && TYPECHECK_CMD="make typecheck"
    fi
}

detect_commands

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Running Validation (Backpressure Gate)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Type checking
if [ "$SKIP_TYPES" != "1" ] && [ -n "$TYPECHECK_CMD" ]; then
    log_run "Type check: $TYPECHECK_CMD"
    if eval "$TYPECHECK_CMD"; then
        log_pass "Type check passed"
    else
        log_fail "Type check failed"
        FAILED=1
    fi
elif [ -z "$TYPECHECK_CMD" ]; then
    log_skip "Type check (no command detected)"
else
    log_skip "Type check (SKIP_TYPES=1)"
fi

# Linting
if [ "$SKIP_LINT" != "1" ] && [ -n "$LINT_CMD" ]; then
    log_run "Lint: $LINT_CMD"
    if eval "$LINT_CMD"; then
        log_pass "Lint passed"
    else
        log_fail "Lint failed"
        FAILED=1
    fi
elif [ -z "$LINT_CMD" ]; then
    log_skip "Lint (no command detected)"
else
    log_skip "Lint (SKIP_LINT=1)"
fi

# Tests (skip in quick mode)
if [ "$QUICK_MODE" = "1" ]; then
    log_skip "Tests (--quick mode)"
elif [ "$SKIP_TESTS" != "1" ] && [ -n "$TEST_CMD" ]; then
    log_run "Tests: $TEST_CMD"
    if eval "$TEST_CMD"; then
        log_pass "Tests passed"
    else
        log_fail "Tests failed"
        FAILED=1
    fi
elif [ -z "$TEST_CMD" ]; then
    log_skip "Tests (no command detected)"
else
    log_skip "Tests (SKIP_TESTS=1)"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAILED -eq 1 ]; then
    echo -e "${RED}Validation FAILED${NC}"
    echo "Fix the issues above before proceeding."
    exit 1
else
    echo -e "${GREEN}Validation PASSED${NC}"
    exit 0
fi
