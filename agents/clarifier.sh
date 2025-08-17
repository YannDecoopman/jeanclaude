#!/bin/bash

# 🎯 Clarifier Agent - Reformulation et validation des demandes
# Usage: ./clarifier.sh "user request"

set -e

REQUEST="$1"
OUTPUT_DIR="${JEANCLAUDE_MEMORY:-../.jeanclaude/memory}/session"

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [CLARIFIER] $1" | tee -a "$OUTPUT_DIR/../logs/agents.log"
}

function extract_keywords() {
    local text="$1"
    # Extract potential technical keywords
    echo "$text" | grep -oE '\b(add|create|fix|update|delete|refactor|test|deploy|install|configure|setup|implement|optimize|debug|analyze)\b' | sort -u
}

function identify_scope() {
    local text="$1"
    local scope="unknown"
    
    # Identify if it's about frontend, backend, database, etc.
    if echo "$text" | grep -qiE 'page|ui|frontend|html|css|react|vue|angular'; then
        scope="frontend"
    elif echo "$text" | grep -qiE 'api|endpoint|backend|server|route|controller'; then
        scope="backend"
    elif echo "$text" | grep -qiE 'database|table|query|sql|migration|schema'; then
        scope="database"
    elif echo "$text" | grep -qiE 'test|spec|unit|integration|e2e'; then
        scope="testing"
    elif echo "$text" | grep -qiE 'deploy|docker|ci|cd|build|production'; then
        scope="deployment"
    fi
    
    echo "$scope"
}

function generate_clarification() {
    local request="$1"
    local keywords=$(extract_keywords "$request")
    local scope=$(identify_scope "$request")
    
    cat > "$OUTPUT_DIR/clarification.md" << EOF
# 📋 Clarification Request
Timestamp: $(date)

## Original Request
"$request"

## My Understanding
Based on your request, I understand that you want to:

### Scope: $scope

### Actions Identified:
$(echo "$keywords" | sed 's/^/- /')

### Detailed Interpretation:
EOF

    # Generate interpretation based on keywords
    if echo "$keywords" | grep -q "add\|create"; then
        echo "- You want to CREATE something new" >> "$OUTPUT_DIR/clarification.md"
    fi
    if echo "$keywords" | grep -q "fix\|debug"; then
        echo "- You want to FIX an existing issue" >> "$OUTPUT_DIR/clarification.md"
    fi
    if echo "$keywords" | grep -q "update\|refactor"; then
        echo "- You want to MODIFY existing functionality" >> "$OUTPUT_DIR/clarification.md"
    fi
    if echo "$keywords" | grep -q "test"; then
        echo "- You want to ADD or RUN tests" >> "$OUTPUT_DIR/clarification.md"
    fi
    
    cat >> "$OUTPUT_DIR/clarification.md" << EOF

### Questions for Validation:
1. Is my understanding of the scope ($scope) correct?
2. Are all the actions I identified what you intended?
3. Is there a specific priority order for these actions?
4. Are there any constraints or requirements I should be aware of?

### Proposed Approach:
1. Validate understanding with you
2. Create feature branch if needed
3. Implement changes incrementally
4. Test each change
5. Commit atomically
6. Request your validation

## Decision Log Entry
EOF
    
    # Log the clarification
    echo "$(date): Request clarified - Scope: $scope, Keywords: $keywords" >> "$OUTPUT_DIR/decisions.log"
    
    log "Clarification generated for: $(echo "$request" | head -c 50)..."
}

function save_context() {
    local request="$1"
    
    # Save to session memory
    cat >> "$OUTPUT_DIR/current.md" << EOF

## $(date '+%H:%M') - New Request
**Original:** $request
**Status:** Clarifying
**Scope:** $(identify_scope "$request")

EOF
    
    log "Context saved to session memory"
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" "$(dirname "$OUTPUT_DIR")/logs"

if [ -z "$REQUEST" ]; then
    echo "Usage: $0 \"user request to clarify\""
    exit 1
fi

log "Starting clarification for request"

# Process the request
generate_clarification "$REQUEST"
save_context "$REQUEST"

# Output the clarification
cat "$OUTPUT_DIR/clarification.md"

log "Clarification complete - awaiting user validation"