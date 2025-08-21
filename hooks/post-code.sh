#!/bin/bash

# ✅ Post-Code Hook - Actions après avoir écrit du code
# Se déclenche APRÈS que Claude ait modifié des fichiers

set -e

MODIFIED_FILES="$1"
PROJECT_ROOT="${2:-$(pwd)}"
JEANCLAUDE_DIR="${PROJECT_ROOT}/.jeanclaude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ POST-CODE HOOK ACTIVATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Check what changed
echo "📝 Step 1: Analyzing changes..."
cd "$PROJECT_ROOT"

CHANGES=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
echo "Files modified: $CHANGES"

if [ "$CHANGES" -gt 0 ]; then
    echo "Changed files:"
    git status --short 2>/dev/null | head -10
fi

echo ""

# 2. Run smoke tests if available
echo "🧪 Step 2: Running smoke tests..."
if [ -f "$(dirname "$0")/../agents/test-runner.sh" ]; then
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/test-runner.sh" smoke "$PROJECT_ROOT" || {
            echo "⚠️  Some smoke tests failed"
        }
else
    echo "ℹ️  Test runner not available"
fi

echo ""

# 3. Check if we should commit
echo "💾 Step 3: Checking commit status..."
if [ -f "$(dirname "$0")/../agents/git-guardian.sh" ]; then
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/git-guardian.sh" check
else
    echo "ℹ️  Git guardian not available"
fi

echo ""

# 4. Save context to memory
echo "🧠 Step 4: Saving context to memory..."
if [ -f "$(dirname "$0")/../agents/memory-keeper.sh" ]; then
    CONTEXT="Modified $CHANGES files. Changes: $(git diff --stat 2>/dev/null | tail -1)"
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/memory-keeper.sh" save "$CONTEXT"
    echo "✅ Context saved"
else
    echo "ℹ️  Memory keeper not available"
fi

echo ""

# 5. Check for common issues
echo "🔍 Step 5: Running quick checks..."

# Check for potential secrets
if git diff --cached 2>/dev/null | grep -iE "api[_-]?key|secret|password|token" > /dev/null 2>&1; then
    echo "⚠️  WARNING: Potential secrets detected in changes!"
    echo "   Please review before committing"
fi

# Check for console.log/print statements
if git diff --cached 2>/dev/null | grep -E "console\.(log|error)|print\(|var_dump" > /dev/null 2>&1; then
    echo "💡 Debug statements detected (console.log/print)"
fi

# Check for TODO comments
TODO_COUNT=$(git diff --cached 2>/dev/null | grep -c "TODO\|FIXME\|XXX" || echo "0")
if [ "$TODO_COUNT" -gt 0 ]; then
    echo "📌 Added $TODO_COUNT TODO/FIXME comments"
fi

echo ""

# 6. Generate summary
echo "📊 Summary:"
cat >> "$JEANCLAUDE_DIR/memory/session/current.md" << EOF

## Post-Code: $(date '+%H:%M')
- Files changed: $CHANGES
- Tests run: smoke
- Potential issues: $([ "$TODO_COUNT" -gt 0 ] && echo "$TODO_COUNT TODOs" || echo "none")

EOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ POST-CODE CHECKS COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Return status based on tests
if [ -f "$JEANCLAUDE_DIR/memory/session/test-smoke.log" ]; then
    if grep -q "FAIL\|ERROR" "$JEANCLAUDE_DIR/memory/session/test-smoke.log"; then
        echo ""
        echo "⚠️  Some tests failed - review before continuing"
        exit 1
    fi
fi

exit 0