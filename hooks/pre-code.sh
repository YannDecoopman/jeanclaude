#!/bin/bash

# 🚀 Pre-Code Hook - Actions avant d'écrire du code
# Se déclenche AVANT que Claude commence à coder

set -e

REQUEST="$1"
PROJECT_ROOT="${2:-$(pwd)}"
JEANCLAUDE_DIR="${PROJECT_ROOT}/.jeanclaude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 PRE-CODE HOOK ACTIVATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Clarification obligatoire
echo "📋 Step 1: Clarifying request..."
if [ -f "$(dirname "$0")/../agents/clarifier.sh" ]; then
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/clarifier.sh" "$REQUEST"
else
    echo "⚠️  Clarifier agent not found, skipping..."
fi

echo ""

# 2. Vérifier l'état Git
echo "🔍 Step 2: Checking Git status..."
if [ -d "$PROJECT_ROOT/.git" ]; then
    cd "$PROJECT_ROOT"
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo "⚠️  Uncommitted changes detected:"
        git status --short
        echo ""
        echo "💡 Recommendation: Commit or stash changes before proceeding"
    fi
    
    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "📍 Current branch: $CURRENT_BRANCH"
    
    # Suggest creating feature branch if on main
    if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
        echo "💡 Recommendation: Create a feature branch"
        echo "   Suggested: feature/$(echo "$REQUEST" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-30)"
    fi
else
    echo "ℹ️  Not a Git repository"
fi

echo ""

# 3. Navigation/Discovery
echo "🗺️  Step 3: Discovering project structure..."
if [ -f "$(dirname "$0")/../agents/navigator.sh" ]; then
    JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
        "$(dirname "$0")/../agents/navigator.sh" discover "$PROJECT_ROOT"
    echo "✅ Project structure mapped"
else
    echo "⚠️  Navigator agent not found, skipping..."
fi

echo ""

# 4. Check memory for relevant context
echo "🧠 Step 4: Recalling relevant context..."
if [ -f "$(dirname "$0")/../agents/memory-keeper.sh" ]; then
    # Extract keywords from request for context search
    KEYWORDS=$(echo "$REQUEST" | grep -oE '\b\w{4,}\b' | head -3 | tr '\n' '|' | sed 's/|$//')
    
    if [ -n "$KEYWORDS" ]; then
        JEANCLAUDE_MEMORY="$JEANCLAUDE_DIR/memory" \
            "$(dirname "$0")/../agents/memory-keeper.sh" recall "$KEYWORDS" | head -10
    fi
else
    echo "ℹ️  No previous context found"
fi

echo ""

# 5. Initialize memory for this session
echo "📝 Step 5: Initializing session memory..."
mkdir -p "$JEANCLAUDE_DIR/memory/session" "$JEANCLAUDE_DIR/memory/project" "$JEANCLAUDE_DIR/logs"

cat > "$JEANCLAUDE_DIR/memory/session/current.md" << EOF
# Session Started: $(date)

## Request
$REQUEST

## Pre-Code Status
- Branch: $CURRENT_BRANCH
- Uncommitted changes: $(git status --porcelain 2>/dev/null | wc -l || echo "0")
- Project: $PROJECT_ROOT

EOF

echo "✅ Session memory initialized"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PRE-CODE CHECKS COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📌 Next steps:"
echo "   1. Validate understanding with user"
echo "   2. Create feature branch if needed"
echo "   3. Implement incrementally"
echo "   4. Commit atomically"