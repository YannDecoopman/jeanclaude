#!/bin/bash

# 🧭 Navigator Agent - Découverte et navigation dans le codebase
# Usage: ./navigator.sh [discover|map|search] [path|query]

set -e

ACTION=${1:-discover}
TARGET=${2:-.}
OUTPUT_DIR="${JEANCLAUDE_MEMORY:-../.jeanclaude/memory}/project"

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [NAVIGATOR] $1" | tee -a "$OUTPUT_DIR/../logs/agents.log"
}

function discover_structure() {
    local path=$1
    log "Discovering structure of $path"
    
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

log "Navigator agent completed: $ACTION"