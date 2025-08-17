#!/bin/bash

# 🔐 Pre-Commit Hook - Validations avant commit
# Se déclenche AVANT un commit Git

set -e

PROJECT_ROOT="${1:-$(pwd)}"
JEANCLAUDE_DIR="${PROJECT_ROOT}/.jeanclaude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 PRE-COMMIT HOOK ACTIVATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$PROJECT_ROOT"
FAILED=0

# 1. Check for secrets
echo "🔍 Checking for secrets..."
if git diff --cached | grep -iE "(api[_-]?key|secret|password|token|private[_-]?key)\s*=\s*['\"][^'\"]+['\"]" > /dev/null 2>&1; then
    echo "❌ BLOCKED: Potential secrets detected!"
    echo "   Remove sensitive data before committing"
    git diff --cached | grep -iE "(api[_-]?key|secret|password|token)" | head -5
    FAILED=1
else
    echo "✅ No secrets detected"
fi

echo ""

# 2. Check file sizes
echo "📦 Checking file sizes..."
LARGE_FILES=$(git diff --cached --numstat | awk '$1 > 1000 {print $3 " (+" $1 " lines)"}')
if [ -n "$LARGE_FILES" ]; then
    echo "⚠️  Large files detected:"
    echo "$LARGE_FILES"
fi

echo ""

# 3. Run quick tests
echo "🧪 Running pre-commit tests..."
if [ -f "$(dirname "$0")/../agents/test-runner.sh" ]; then
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/test-runner.sh" smoke "$PROJECT_ROOT" || {
            echo "⚠️  Tests failed - commit anyway? (not recommended)"
            FAILED=1
        }
else
    echo "ℹ️  No test runner available"
fi

echo ""

# 4. Lint checks (if available)
echo "🎨 Running lint checks..."

# Python
if [ -f "$PROJECT_ROOT/.flake8" ] || [ -f "$PROJECT_ROOT/setup.cfg" ]; then
    if command -v flake8 > /dev/null 2>&1; then
        flake8 $(git diff --cached --name-only | grep '\.py$') 2>/dev/null || {
            echo "⚠️  Python linting issues detected"
        }
    fi
fi

# JavaScript/TypeScript
if [ -f "$PROJECT_ROOT/.eslintrc.js" ] || [ -f "$PROJECT_ROOT/.eslintrc.json" ]; then
    if command -v eslint > /dev/null 2>&1; then
        eslint $(git diff --cached --name-only | grep '\.[jt]sx\?$') 2>/dev/null || {
            echo "⚠️  JavaScript linting issues detected"
        }
    fi
fi

# PHP
if [ -f "$PROJECT_ROOT/phpcs.xml" ] || [ -f "$PROJECT_ROOT/.phpcs.xml" ]; then
    if command -v phpcs > /dev/null 2>&1; then
        phpcs $(git diff --cached --name-only | grep '\.php$') 2>/dev/null || {
            echo "⚠️  PHP linting issues detected"
        }
    fi
fi

echo ""

# 5. Check commit message format
echo "📝 Validating commit message format..."
# This would normally be done with the actual commit message
echo "ℹ️  Ensure commit follows convention: type(scope): description"
echo "   Types: feat, fix, docs, style, refactor, test, chore"

echo ""

# 6. Log to memory
if [ -f "$(dirname "$0")/../agents/memory-keeper.sh" ]; then
    STATS="Files: $(git diff --cached --numstat | wc -l), Lines: +$(git diff --cached --numstat | awk '{s+=$1} END {print s}') -$(git diff --cached --numstat | awk '{s+=$2} END {print s}')"
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/memory-keeper.sh" save "Pre-commit: $STATS"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FAILED" -eq 0 ]; then
    echo "✅ PRE-COMMIT CHECKS PASSED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "❌ PRE-COMMIT CHECKS FAILED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Fix issues above before committing"
    echo "Or use --no-verify to skip (not recommended)"
    exit 1
fi