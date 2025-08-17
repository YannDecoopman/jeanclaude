#!/bin/bash

# 🧭 Navigator Agent v2.2 - Découverte avec support JSON optionnel
# Usage: ./navigator.sh [discover|map|search] [path|query] [--json]

set -e

# Load libraries
CONTEXT_LIB="$(dirname "$0")/../lib/context-manager.sh"
OUTPUT_LIB="$(dirname "$0")/../lib/output-formatter.sh"
[ -f "$CONTEXT_LIB" ] && source "$CONTEXT_LIB"
[ -f "$OUTPUT_LIB" ] && source "$OUTPUT_LIB"

# Parse arguments (remove --json if present)
CLEAN_ARGS=()
for arg in "$@"; do
    if [ "$arg" != "--json" ]; then
        CLEAN_ARGS+=("$arg")
    fi
done
ACTION=${CLEAN_ARGS[0]:-discover}
TARGET=${CLEAN_ARGS[1]:-.}

# Get ONLY minimal context needed
if [ -n "$JEANCLAUDE_DIR" ]; then
    PROJECT_ROOT=$(get_context "navigator" "minimal" "project_root" 2>/dev/null || pwd)
    OUTPUT_DIR="${JEANCLAUDE_DIR}/memory/project"
else
    PROJECT_ROOT=$(pwd)
    OUTPUT_DIR="${PROJECT_ROOT}/.jeanclaude/memory/project"
fi

# Navigator-specific context (if exists)
LAST_SCAN=$(get_context "navigator" "agent" "last_scan" 2>/dev/null || echo "never")
CACHE_VALID=$(get_context "navigator" "agent" "cache_valid_until" 2>/dev/null || echo "0")

function log() {
    if ! is_json_output; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [NAVIGATOR] $1" | tee -a "$OUTPUT_DIR/../logs/agents.log"
    fi
}

function discover_structure() {
    local path=$1
    log "Discovering structure of $path"
    
    # Check cache validity
    local now=$(date +%s)
    if [ "$now" -lt "$CACHE_VALID" ] && [ -f "$OUTPUT_DIR/structure.md" ]; then
        log "Using cached structure (valid until $(date -d @$CACHE_VALID))"
        if is_json_output; then
            local files_count=$(find "$path" -type f 2>/dev/null | wc -l || echo 0)
            local dirs_count=$(find "$path" -type d 2>/dev/null | wc -l || echo 0)
            output_success "Structure discovered from cache" \
                "{\"files\": $files_count, \"directories\": $dirs_count, \"cached\": true}" \
                "navigator" "discover"
        else
            cat "$OUTPUT_DIR/structure.md"
        fi
        return 0
    fi
    
    # Create navigation map
    find "$path" -type f -name "*.py" -o -name "*.js" -o -name "*.ts" \
        -o -name "*.php" -o -name "*.java" -o -name "*.go" 2>/dev/null | \
        head -100 | \
        while read -r file; do
            echo "  - $file"
        done > "$OUTPUT_DIR/structure.md"
    
    # Identify key patterns
    echo "## Key Files Detected" >> "$OUTPUT_DIR/structure.md"
    
    # Package files
    for pkg in package.json composer.json requirements.txt go.mod Cargo.toml pom.xml; do
        if [ -f "$path/$pkg" ]; then
            echo "- $pkg found" >> "$OUTPUT_DIR/structure.md"
            log "Found package file: $pkg"
        fi
    done
    
    # Config files
    for cfg in .env.example docker-compose.yml Dockerfile Makefile; do
        if [ -f "$path/$cfg" ]; then
            echo "- $cfg found" >> "$OUTPUT_DIR/structure.md"
            log "Found config: $cfg"
        fi
    done
    
    log "Structure discovery complete"
}

function create_map() {
    local path=$1
    log "Creating navigation map"
    
    cat > "$OUTPUT_DIR/navigation-map.md" << EOF
# 🗺️ Navigation Map
Generated: $(date)

## Directory Structure
\`\`\`
$(tree -L 3 -I 'node_modules|vendor|.git|__pycache__|dist|build' "$path" 2>/dev/null || find "$path" -type d -maxdepth 3 | sort)
\`\`\`

## Entry Points
$(find "$path" -name "main.*" -o -name "index.*" -o -name "app.*" 2>/dev/null | head -10)

## Test Files
$(find "$path" -name "*test*" -o -name "*spec*" 2>/dev/null | head -10)

EOF
    
    log "Navigation map created at $OUTPUT_DIR/navigation-map.md"
}

function search_pattern() {
    local query=$1
    log "Searching for pattern: $query"
    
    grep -r "$query" "$TARGET" --include="*.py" --include="*.js" --include="*.ts" \
        --include="*.php" --include="*.java" --include="*.go" 2>/dev/null | \
        head -20 > "$OUTPUT_DIR/search-results.tmp"
    
    if [ -s "$OUTPUT_DIR/search-results.tmp" ]; then
        log "Found $(wc -l < "$OUTPUT_DIR/search-results.tmp") matches"
        cat "$OUTPUT_DIR/search-results.tmp"
    else
        log "No matches found for: $query"
    fi
    
    rm -f "$OUTPUT_DIR/search-results.tmp"
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" "$(dirname "$OUTPUT_DIR")/logs"

# Save navigator context after execution
function save_context() {
    local now=$(date +%s)
    local cache_duration=300  # 5 minutes cache
    
    save_agent_context "navigator" "{
        \"last_scan\": \"$(date -Iseconds)\",
        \"cache_valid_until\": $((now + cache_duration)),
        \"files_discovered\": $(find "$TARGET" -type f 2>/dev/null | wc -l || echo 0),
        \"action_performed\": \"$ACTION\",
        \"target\": \"$TARGET\"
    }"
}

# Register cleanup
trap save_context EXIT

# Execute action
case $ACTION in
    discover)
        discover_structure "$TARGET"
        ;;
    map)
        create_map "$TARGET"
        ;;
    search)
        search_pattern "$TARGET"
        ;;
    *)
        echo "Usage: $0 [discover|map|search] [path|query]"
        exit 1
        ;;
esac

# Final output
if ! is_json_output; then
    log "Navigator agent completed: $ACTION"
fi