#!/bin/bash

# 🤖 [AGENT_NAME] Agent - [AGENT_DESCRIPTION]
# Usage: ./[agent_name].sh [action] [parameters]

set -e

# Configuration
ACTION=${1:-default}
PARAM1=${2:-""}
PARAM2=${3:-""}
OUTPUT_DIR="${JEANCLAUDE_MEMORY:-../.jeanclaude/memory}/[session|project]"

# Logging function
function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [[AGENT_NAME]] $1" | tee -a "$OUTPUT_DIR/../logs/agents.log"
}

# Initialize environment
function init() {
    # Ensure output directories exist
    mkdir -p "$OUTPUT_DIR" "$(dirname "$OUTPUT_DIR")/logs"
    
    # Load any configuration
    if [ -f "$(dirname "$OUTPUT_DIR")/config.json" ]; then
        # Parse config if needed
        log "Configuration loaded"
    fi
}

# Main action function
function action_default() {
    local param="$1"
    log "Executing default action with: $param"
    
    # TODO: Implement main logic here
    
    # Example structure:
    # 1. Validate inputs
    if [ -z "$param" ]; then
        log "ERROR: Parameter required"
        exit 1
    fi
    
    # 2. Process
    # ... your logic here ...
    
    # 3. Save results
    cat > "$OUTPUT_DIR/[agent_name]-result.md" << EOF
# [Agent Name] Results
Timestamp: $(date)
Action: $ACTION
Parameter: $param

## Results
[Your results here]
EOF
    
    # 4. Log completion
    log "Action completed successfully"
}

# Alternative action
function action_alternative() {
    local param="$1"
    log "Executing alternative action"
    
    # TODO: Implement alternative logic
    
    log "Alternative action completed"
}

# Help function
function show_help() {
    cat << EOF
Usage: $0 [action] [parameters]

Actions:
  default    - [Description of default action]
  alternative - [Description of alternative action]
  help       - Show this help message

Parameters:
  param1     - [Description of parameter 1]
  param2     - [Description of parameter 2]

Examples:
  $0 default "value"
  $0 alternative "param1" "param2"

Environment Variables:
  JEANCLAUDE_MEMORY - Base directory for memory storage

EOF
}

# Error handling
function handle_error() {
    local error_msg="$1"
    log "ERROR: $error_msg"
    
    # Save error to memory
    echo "$(date): $error_msg" >> "$OUTPUT_DIR/../session/errors.log"
    
    # Call post-error hook if available
    if [ -f "$(dirname "$0")/../hooks/post-error.sh" ]; then
        "$(dirname "$0")/../hooks/post-error.sh" "$error_msg" "$?"
    fi
    
    exit 1
}

# Cleanup function
function cleanup() {
    log "Cleaning up..."
    # Add any cleanup tasks here
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Initialize
init

# Execute based on action
case $ACTION in
    default)
        action_default "$PARAM1"
        ;;
    alternative)
        action_alternative "$PARAM1" "$PARAM2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown action: $ACTION"
        show_help
        exit 1
        ;;
esac

log "[Agent Name] completed: $ACTION"