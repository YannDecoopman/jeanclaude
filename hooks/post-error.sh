#!/bin/bash

# 🚨 Post-Error Hook - Gestion des erreurs
# Se déclenche APRÈS une erreur

set -e

ERROR_MSG="$1"
ERROR_CODE="${2:-1}"
PROJECT_ROOT="${3:-$(pwd)}"
JEANCLAUDE_DIR="${PROJECT_ROOT}/.jeanclaude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚨 POST-ERROR HOOK ACTIVATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Error: $ERROR_MSG"
echo "Code: $ERROR_CODE"
echo ""

# 1. Log error to memory
echo "📝 Logging error..."
mkdir -p "$JEANCLAUDE_DIR/memory/session"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
cat >> "$JEANCLAUDE_DIR/memory/session/errors.log" << EOF
$TIMESTAMP | Code: $ERROR_CODE | $ERROR_MSG
EOF

# Also save to current session
cat >> "$JEANCLAUDE_DIR/memory/session/current.md" << EOF

## 🚨 Error at $TIMESTAMP
- **Code:** $ERROR_CODE
- **Message:** $ERROR_MSG
- **Working directory:** $(pwd)

EOF

echo "✅ Error logged"
echo ""

# 2. Analyze error pattern
echo "🔍 Analyzing error pattern..."

# Check if this error has occurred before
OCCURRENCES=$(grep -c "$ERROR_MSG" "$JEANCLAUDE_DIR/memory/session/errors.log" 2>/dev/null || echo "1")
if [ "$OCCURRENCES" -gt 1 ]; then
    echo "⚠️  This error has occurred $OCCURRENCES times in this session"
fi

# Common error patterns
if echo "$ERROR_MSG" | grep -qiE "permission denied|cannot access|forbidden"; then
    echo "💡 Hint: Permission issue detected. Check file permissions."
elif echo "$ERROR_MSG" | grep -qiE "not found|no such file|cannot find"; then
    echo "💡 Hint: File/resource not found. Verify paths and names."
elif echo "$ERROR_MSG" | grep -qiE "syntax error|unexpected token|parse error"; then
    echo "💡 Hint: Syntax error detected. Review recent code changes."
elif echo "$ERROR_MSG" | grep -qiE "connection refused|timeout|unreachable"; then
    echo "💡 Hint: Network/connection issue. Check services and connectivity."
elif echo "$ERROR_MSG" | grep -qiE "out of memory|heap|stack overflow"; then
    echo "💡 Hint: Memory issue. Consider optimizing or increasing limits."
fi

echo ""

# 3. Capture environment state
echo "📸 Capturing environment state..."

cat > "$JEANCLAUDE_DIR/memory/session/error-context-$(date +%s).md" << EOF
# Error Context
Time: $TIMESTAMP
Error: $ERROR_MSG
Code: $ERROR_CODE

## Git Status
$(git status --short 2>/dev/null || echo "Not a git repository")

## Recent Commands (if available)
$(history | tail -10 2>/dev/null || echo "History not available")

## Working Directory
$(pwd)

## Directory Contents
$(ls -la | head -20)

EOF

echo "✅ Context captured"
echo ""

# 4. Suggest recovery actions
echo "🔧 Suggested recovery actions:"

case "$ERROR_CODE" in
    1)
        echo "  1. Review the error message above"
        echo "  2. Check recent changes with: git diff"
        echo "  3. Consider reverting with: git checkout -- <file>"
        ;;
    2)
        echo "  1. Check file paths and permissions"
        echo "  2. Verify all required files exist"
        ;;
    127)
        echo "  1. Command not found - install missing dependencies"
        echo "  2. Check PATH environment variable"
        ;;
    *)
        echo "  1. Review error message and context"
        echo "  2. Check logs in $JEANCLAUDE_DIR/memory/session/"
        echo "  3. Consider rolling back recent changes"
        ;;
esac

echo ""

# 5. Check if we should alert on pattern
if [ "$OCCURRENCES" -gt 3 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  RECURRING ERROR PATTERN DETECTED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "This error has occurred $OCCURRENCES times."
    echo "Consider a different approach or seeking help."
    
    # Save to pitfalls for long-term memory
    echo "$ERROR_MSG" >> "$JEANCLAUDE_DIR/memory/project/pitfalls.md"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 ERROR HANDLING COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Return error code to propagate
exit "$ERROR_CODE"