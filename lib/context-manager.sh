#!/bin/bash

# 🎯 Context Manager for Jean Claude v2.1
# Manages minimal, shared, and agent-specific contexts

# Don't exit on error when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -e
fi

CONTEXT_DIR="${JEANCLAUDE_DIR:-.jeanclaude}/context"

# Initialize context structure
function init_context() {
    mkdir -p "$CONTEXT_DIR"/{agents,session}
    
    # Create minimal context
    cat > "$CONTEXT_DIR/minimal.json" << EOF
{
  "project_root": "$(pwd)",
  "project_name": "$(basename "$(pwd)")",
  "timestamp": "$(date -Iseconds)"
}
EOF
    
    # Create shared context
    cat > "$CONTEXT_DIR/shared.json" << EOF
{
  "session_id": "$(command -v uuidgen >/dev/null 2>&1 && uuidgen || echo "session-$(date +%s)")",
  "user": "$(whoami)",
  "platform": "$(uname)",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo "none")",
  "project_type": "$(detect_project_type)"
}
EOF
}

# Detect project type from files
function detect_project_type() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
        echo "python"
    elif [ -f "composer.json" ]; then
        echo "php"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

# Get context for an agent (minimal by default)
function get_context() {
    local agent=$1
    local level=${2:-minimal}  # minimal|shared|full
    local key=$3
    
    case $level in
        minimal)
            if [ -n "$key" ]; then
                jq -r ".$key" "$CONTEXT_DIR/minimal.json" 2>/dev/null || echo ""
            else
                cat "$CONTEXT_DIR/minimal.json" 2>/dev/null || echo "{}"
            fi
            ;;
        shared)
            if [ -n "$key" ]; then
                jq -r ".$key" "$CONTEXT_DIR/shared.json" 2>/dev/null || echo ""
            else
                cat "$CONTEXT_DIR/shared.json" 2>/dev/null || echo "{}"
            fi
            ;;
        agent)
            if [ -f "$CONTEXT_DIR/agents/$agent.json" ]; then
                if [ -n "$key" ]; then
                    jq -r ".$key" "$CONTEXT_DIR/agents/$agent.json" 2>/dev/null || echo ""
                else
                    cat "$CONTEXT_DIR/agents/$agent.json" 2>/dev/null || echo "{}"
                fi
            else
                echo "{}"
            fi
            ;;
        *)
            echo "{}"
            ;;
    esac
}

# Save agent-specific context
function save_agent_context() {
    local agent=$1
    local data=$2
    
    mkdir -p "$CONTEXT_DIR/agents"
    echo "$data" > "$CONTEXT_DIR/agents/$agent.json"
}

# Update shared context
function update_shared_context() {
    local key=$1
    local value=$2
    
    if [ -f "$CONTEXT_DIR/shared.json" ]; then
        local tmp=$(mktemp)
        jq ".$key = \"$value\"" "$CONTEXT_DIR/shared.json" > "$tmp"
        mv "$tmp" "$CONTEXT_DIR/shared.json"
    fi
}

# Clean old context
function clean_context() {
    local max_age=${1:-86400}  # Default 24h
    
    find "$CONTEXT_DIR" -type f -name "*.json" -mtime +1 -delete 2>/dev/null || true
}

# Context size report
function context_size() {
    local agent=$1
    
    echo "Context sizes:"
    echo "  Minimal: $(wc -c < "$CONTEXT_DIR/minimal.json" 2>/dev/null || echo 0) bytes"
    echo "  Shared: $(wc -c < "$CONTEXT_DIR/shared.json" 2>/dev/null || echo 0) bytes"
    
    if [ -n "$agent" ] && [ -f "$CONTEXT_DIR/agents/$agent.json" ]; then
        echo "  Agent ($agent): $(wc -c < "$CONTEXT_DIR/agents/$agent.json") bytes"
    fi
    
    echo "  Total: $(du -sh "$CONTEXT_DIR" 2>/dev/null | cut -f1)"
}

# Export functions for sourcing
export -f init_context
export -f get_context
export -f save_agent_context
export -f update_shared_context
export -f clean_context
export -f context_size
export -f detect_project_type