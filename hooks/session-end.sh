#!/bin/bash

# 🏁 Session-End Hook - Finalisation de session
# Se déclenche à la FIN d'une session Claude

set -e

PROJECT_ROOT="${1:-$(pwd)}"
JEANCLAUDE_DIR="${PROJECT_ROOT}/.jeanclaude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏁 SESSION-END HOOK ACTIVATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$PROJECT_ROOT"

# 1. Final Git status check
echo "📊 Final Git Status:"
if [ -d ".git" ]; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    echo "  Branch: $CURRENT_BRANCH"
    echo "  Uncommitted changes: $UNCOMMITTED files"
    
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo ""
        echo "⚠️  You have uncommitted changes:"
        git status --short | head -10
        echo ""
        echo "💡 Remember to commit or stash these changes"
    fi
    
    # Show recent commits
    echo ""
    echo "📝 Recent commits this session:"
    git log --oneline --since="8 hours ago" 2>/dev/null | head -5 || echo "  No commits in this session"
else
    echo "  Not a Git repository"
fi

echo ""

# 2. Analyze session with memory keeper
echo "🧠 Session Analysis:"
if [ -f "$(dirname "$0")/../agents/memory-keeper.sh" ]; then
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/memory-keeper.sh" analyze
    
    # Extract learnings to long-term memory
    echo ""
    echo "💾 Extracting learnings..."
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/memory-keeper.sh" learn
else
    echo "  Memory keeper not available"
fi

echo ""

# 3. Generate session summary
echo "📋 Generating session summary..."

SESSION_FILE="$JEANCLAUDE_DIR/memory/session/summary-$(date +%Y%m%d-%H%M).md"
cat > "$SESSION_FILE" << EOF
# Session Summary
Date: $(date)
Duration: Started at $(head -1 "$JEANCLAUDE_DIR/memory/session/current.md" 2>/dev/null | grep -oE '[0-9]{2}:[0-9]{2}' || echo "unknown")

## Git Activity
- Branch: $CURRENT_BRANCH
- Commits: $(git log --oneline --since="8 hours ago" 2>/dev/null | wc -l || echo "0")
- Files changed: $(git diff --stat HEAD~5..HEAD 2>/dev/null | tail -1 || echo "unknown")

## Decisions Made
$([ -f "$JEANCLAUDE_DIR/memory/session/decisions.log" ] && wc -l < "$JEANCLAUDE_DIR/memory/session/decisions.log" || echo "0") decisions logged

## Errors Encountered
$([ -f "$JEANCLAUDE_DIR/memory/session/errors.log" ] && wc -l < "$JEANCLAUDE_DIR/memory/session/errors.log" || echo "0") errors logged

## Key Accomplishments
$(grep -h "completed\|fixed\|added\|implemented" "$JEANCLAUDE_DIR/memory/session/current.md" 2>/dev/null | head -5 || echo "- Session details not available")

## Files Modified
$(git diff --name-only HEAD~5..HEAD 2>/dev/null | head -10 || find . -type f -mmin -480 -not -path "./.git/*" -not -path "./.jeanclaude/*" 2>/dev/null | head -10 || echo "No recent modifications tracked")

EOF

echo "✅ Summary saved to: $SESSION_FILE"
echo ""

# 4. Cleanup old sessions
echo "🧹 Cleaning up old sessions..."
if [ -f "$(dirname "$0")/../agents/memory-keeper.sh" ]; then
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/memory-keeper.sh" clean 7
fi

# Clean old logs
find "$JEANCLAUDE_DIR/logs" -type f -mtime +30 -delete 2>/dev/null || true
echo "✅ Cleanup complete"
echo ""

# 5. Backup important data
echo "💾 Creating session backup..."
BACKUP_DIR="$JEANCLAUDE_DIR/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup current session
if [ -d "$JEANCLAUDE_DIR/memory/session" ]; then
    tar -czf "$BACKUP_DIR/session-$(date +%H%M).tar.gz" \
        -C "$JEANCLAUDE_DIR/memory" "session" 2>/dev/null || true
    echo "✅ Session backed up"
fi

echo ""

# 6. Final recommendations
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 RECOMMENDATIONS FOR NEXT SESSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$UNCOMMITTED" -gt 0 ]; then
    echo "1. ⚠️  Commit or stash uncommitted changes"
fi

if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "2. 🔀 Consider merging '$CURRENT_BRANCH' to main if complete"
fi

if [ -f "$JEANCLAUDE_DIR/memory/session/errors.log" ]; then
    ERROR_COUNT=$(wc -l < "$JEANCLAUDE_DIR/memory/session/errors.log")
    if [ "$ERROR_COUNT" -gt 5 ]; then
        echo "3. 🔍 Review error patterns - $ERROR_COUNT errors this session"
    fi
fi

# Check for TODOs
TODO_COUNT=$(grep -r "TODO\|FIXME" "$PROJECT_ROOT" --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.jeanclaude 2>/dev/null | wc -l || echo "0")
if [ "$TODO_COUNT" -gt 0 ]; then
    echo "4. 📝 Address $TODO_COUNT TODO/FIXME items in codebase"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SESSION ENDED SUCCESSFULLY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Thanks for using Jean Claude Framework! 🤖"
echo "Session data saved in: $JEANCLAUDE_DIR"