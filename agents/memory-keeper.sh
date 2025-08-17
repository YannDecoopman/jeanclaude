#!/bin/bash

# 🧠 Memory Keeper Agent - Gestion de la mémoire court/long terme
# Usage: ./memory-keeper.sh [save|recall|clean|analyze] [context]

set -e

ACTION=${1:-save}
CONTEXT=${2:-""}
MEMORY_DIR="${JEANCLAUDE_MEMORY:-../.jeanclaude/memory}"
SHORT_TERM="$MEMORY_DIR/session"
LONG_TERM="$MEMORY_DIR/project"

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [MEMORY-KEEPER] $1" | tee -a "$MEMORY_DIR/logs/agents.log"
}

function save_to_session() {
    local content="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Append to current session
    cat >> "$SHORT_TERM/current.md" << EOF

## $timestamp
$content

EOF
    
    # Also log decision if it's a decision
    if echo "$content" | grep -qiE 'decided|chosen|selected|will use|going with'; then
        echo "$timestamp: $content" >> "$SHORT_TERM/decisions.log"
        log "Decision saved to session memory"
    fi
    
    # Log errors if detected
    if echo "$content" | grep -qiE 'error|failed|exception|bug|issue'; then
        echo "$timestamp: $content" >> "$SHORT_TERM/errors.log"
        log "Error saved to session memory"
    fi
    
    log "Context saved to session memory"
}

function promote_to_longterm() {
    local pattern="$1"
    
    # Extract patterns from session
    if [ -f "$SHORT_TERM/decisions.log" ]; then
        grep -E "$pattern" "$SHORT_TERM/decisions.log" >> "$LONG_TERM/patterns.md" 2>/dev/null || true
    fi
    
    # Extract recurring errors
    if [ -f "$SHORT_TERM/errors.log" ]; then
        sort "$SHORT_TERM/errors.log" | uniq -c | sort -rn | head -10 >> "$LONG_TERM/pitfalls.md"
    fi
    
    log "Promoted patterns to long-term memory"
}

function recall_context() {
    local query="$1"
    
    echo "=== Session Memory ==="
    if [ -f "$SHORT_TERM/current.md" ]; then
        if [ -n "$query" ]; then
            grep -i "$query" "$SHORT_TERM/current.md" 2>/dev/null || echo "No matches in session"
        else
            tail -50 "$SHORT_TERM/current.md"
        fi
    fi
    
    echo ""
    echo "=== Long-term Patterns ==="
    if [ -f "$LONG_TERM/patterns.md" ]; then
        if [ -n "$query" ]; then
            grep -i "$query" "$LONG_TERM/patterns.md" 2>/dev/null || echo "No patterns found"
        else
            tail -20 "$LONG_TERM/patterns.md"
        fi
    fi
}

function analyze_session() {
    log "Analyzing current session"
    
    local decisions=0
    local errors=0
    local duration=0
    
    if [ -f "$SHORT_TERM/decisions.log" ]; then
        decisions=$(wc -l < "$SHORT_TERM/decisions.log")
    fi
    
    if [ -f "$SHORT_TERM/errors.log" ]; then
        errors=$(wc -l < "$SHORT_TERM/errors.log")
    fi
    
    if [ -f "$SHORT_TERM/current.md" ]; then
        # Get session duration from first and last timestamp
        local first_time=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' "$SHORT_TERM/current.md" | head -1)
        local last_time=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' "$SHORT_TERM/current.md" | tail -1)
        
        if [ -n "$first_time" ] && [ -n "$last_time" ]; then
            local start_seconds=$(date -j -f "%Y-%m-%d %H:%M:%S" "$first_time" +%s 2>/dev/null || date -d "$first_time" +%s)
            local end_seconds=$(date -j -f "%Y-%m-%d %H:%M:%S" "$last_time" +%s 2>/dev/null || date -d "$last_time" +%s)
            duration=$(( (end_seconds - start_seconds) / 60 ))
        fi
    fi
    
    cat > "$SHORT_TERM/analysis.md" << EOF
# 📊 Session Analysis
Generated: $(date)

## Metrics
- Duration: ${duration} minutes
- Decisions made: $decisions
- Errors encountered: $errors

## Top Decisions
$([ -f "$SHORT_TERM/decisions.log" ] && tail -5 "$SHORT_TERM/decisions.log" || echo "No decisions yet")

## Recent Errors
$([ -f "$SHORT_TERM/errors.log" ] && tail -5 "$SHORT_TERM/errors.log" || echo "No errors recorded")

## Recommendations
EOF
    
    if [ "$errors" -gt 5 ]; then
        echo "- ⚠️ High error rate detected. Review error patterns." >> "$SHORT_TERM/analysis.md"
    fi
    
    if [ "$decisions" -lt 3 ] && [ "$duration" -gt 30 ]; then
        echo "- 💡 Consider more frequent decision logging for better tracking." >> "$SHORT_TERM/analysis.md"
    fi
    
    cat "$SHORT_TERM/analysis.md"
    log "Session analysis complete"
}

function clean_old_sessions() {
    local days=${1:-7}
    
    log "Cleaning sessions older than $days days"
    
    # Archive old session files
    find "$SHORT_TERM" -type f -mtime +$days -name "*.md" -exec mv {} "$SHORT_TERM/archive/" \; 2>/dev/null || true
    
    # Compress old logs
    find "$SHORT_TERM" -type f -mtime +$days -name "*.log" -exec gzip {} \; 2>/dev/null || true
    
    log "Cleanup complete"
}

function extract_learnings() {
    log "Extracting learnings from session"
    
    # Extract successful patterns
    if [ -f "$SHORT_TERM/decisions.log" ]; then
        echo "## Successful Patterns - $(date)" >> "$LONG_TERM/patterns.md"
        grep -E "success|worked|fixed|resolved" "$SHORT_TERM/decisions.log" >> "$LONG_TERM/patterns.md" 2>/dev/null || true
    fi
    
    # Extract pitfalls
    if [ -f "$SHORT_TERM/errors.log" ]; then
        echo "## Common Pitfalls - $(date)" >> "$LONG_TERM/pitfalls.md"
        sort "$SHORT_TERM/errors.log" | uniq -c | sort -rn | head -5 >> "$LONG_TERM/pitfalls.md"
    fi
    
    # Update context
    cat >> "$LONG_TERM/context.md" << EOF

## Session $(date '+%Y-%m-%d')
### Key Decisions
$([ -f "$SHORT_TERM/decisions.log" ] && tail -3 "$SHORT_TERM/decisions.log" || echo "None")

### Key Learnings
$(grep -h "learned\|discovered\|found that" "$SHORT_TERM/current.md" 2>/dev/null | head -3 || echo "None recorded")

EOF
    
    log "Learnings extracted to long-term memory"
}

# Ensure directories exist
mkdir -p "$SHORT_TERM" "$LONG_TERM" "$MEMORY_DIR/logs" "$SHORT_TERM/archive"

# Execute action
case $ACTION in
    save)
        save_to_session "$CONTEXT"
        ;;
    recall)
        recall_context "$CONTEXT"
        ;;
    analyze)
        analyze_session
        ;;
    clean)
        clean_old_sessions "$CONTEXT"
        ;;
    learn)
        extract_learnings
        ;;
    promote)
        promote_to_longterm "$CONTEXT"
        ;;
    *)
        echo "Usage: $0 [save|recall|analyze|clean|learn|promote] [context/query/days]"
        exit 1
        ;;
esac