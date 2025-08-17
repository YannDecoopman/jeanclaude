#!/bin/bash

# 🤝 Trust Manager for Jean Claude v2.3
# Manages trust levels and auto-proceed behavior

# Default configuration
DEFAULT_TRUST_LEVEL="smart"
DEFAULT_AUTO_DELAY=6
TRUST_CONFIG_FILE="${JEANCLAUDE_DIR:-$(pwd)/.jeanclaude}/config/trust.json"

# Load trust configuration
function load_trust_config() {
    if [ -f "$TRUST_CONFIG_FILE" ]; then
        TRUST_LEVEL=$(jq -r '.trust_level // "smart"' "$TRUST_CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_TRUST_LEVEL")
        AUTO_DELAY=$(jq -r '.auto_delay // 6' "$TRUST_CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_AUTO_DELAY")
    else
        TRUST_LEVEL="$DEFAULT_TRUST_LEVEL"
        AUTO_DELAY="$DEFAULT_AUTO_DELAY"
    fi
}

# Save trust configuration
function save_trust_config() {
    local level=$1
    local delay=${2:-6}
    
    mkdir -p "$(dirname "$TRUST_CONFIG_FILE")"
    cat > "$TRUST_CONFIG_FILE" << EOF
{
  "trust_level": "$level",
  "auto_delay": $delay,
  "updated": "$(date -Iseconds)",
  "operations": {
    "safe": ["edit", "read", "test", "analyze", "format"],
    "moderate": ["commit", "branch", "merge", "install"],
    "dangerous": ["delete", "deploy", "push", "reset", "force"]
  }
}
EOF
}

# Check if operation is safe based on trust level
function is_safe_operation() {
    local operation=$1
    local context=$2
    
    case "$TRUST_LEVEL" in
        conservative)
            # Only auto-proceed for read operations
            [[ "$operation" =~ ^(read|list|status|info|analyze)$ ]]
            ;;
        smart)
            # Auto-proceed for safe operations in current context
            if [[ "$operation" =~ ^(edit|write|create|test|format|lint)$ ]]; then
                # Check if file is in current task context
                if [ -n "$context" ] && [[ "$context" =~ "current_task" ]]; then
                    return 0
                fi
            fi
            # Always safe operations
            [[ "$operation" =~ ^(read|list|status|info|analyze|check)$ ]]
            ;;
        autonomous)
            # Auto-proceed for all except destructive operations
            ! [[ "$operation" =~ ^(delete|remove|force|reset|drop|truncate)$ ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if confirmation is required
function requires_confirmation() {
    local operation=$1
    local target=$2
    local context=$3
    
    # Load current configuration
    load_trust_config
    
    # Always require confirmation for production operations
    if [[ "$target" =~ production|prod|master|main ]] && [[ "$operation" =~ ^(deploy|push|merge)$ ]]; then
        return 0
    fi
    
    # Check if operation is safe
    if is_safe_operation "$operation" "$context"; then
        return 1  # No confirmation needed
    fi
    
    return 0  # Confirmation needed
}

# Auto-proceed with countdown
function auto_proceed() {
    local operation=$1
    local target=$2
    local message=${3:-"Proceeding with $operation on $target"}
    
    load_trust_config
    
    if [ "$TRUST_LEVEL" = "conservative" ]; then
        # Always ask in conservative mode
        return 1
    fi
    
    echo "⏱️  $message"
    echo "   Auto-proceeding in $AUTO_DELAY seconds (press Ctrl+C to cancel)..."
    
    # Countdown with interrupt capability
    for ((i=$AUTO_DELAY; i>0; i--)); do
        printf "\r   %d... " "$i"
        sleep 1
    done
    printf "\r   ✅ Proceeding...          \n"
    
    return 0
}

# Get trust level description
function describe_trust_level() {
    load_trust_config
    
    case "$TRUST_LEVEL" in
        conservative)
            echo "🔒 Conservative: Manual confirmation for all write operations"
            ;;
        smart)
            echo "🧠 Smart: Auto-proceed for safe operations in current context (${AUTO_DELAY}s delay)"
            ;;
        autonomous)
            echo "🚀 Autonomous: Auto-proceed for all non-destructive operations (${AUTO_DELAY}s delay)"
            ;;
        *)
            echo "❓ Unknown trust level: $TRUST_LEVEL"
            ;;
    esac
}

# Set trust level
function set_trust_level() {
    local level=$1
    local delay=${2:-$AUTO_DELAY}
    
    if [[ ! "$level" =~ ^(conservative|smart|autonomous)$ ]]; then
        echo "❌ Invalid trust level. Choose: conservative, smart, or autonomous"
        return 1
    fi
    
    save_trust_config "$level" "$delay"
    echo "✅ Trust level set to: $level (auto-delay: ${delay}s)"
}

# Log trust decision
function log_trust_decision() {
    local operation=$1
    local decision=$2
    local reason=$3
    
    local log_file="${JEANCLAUDE_DIR:-$(pwd)/.jeanclaude}/logs/trust-decisions.log"
    mkdir -p "$(dirname "$log_file")"
    
    echo "[$(date -Iseconds)] [$TRUST_LEVEL] $operation: $decision - $reason" >> "$log_file"
}

# Interactive trust configuration
function configure_trust() {
    echo "🤝 Jean Claude Trust Configuration"
    echo "=================================="
    echo ""
    echo "Current setting: $(describe_trust_level)"
    echo ""
    echo "Available trust levels:"
    echo "  1) Conservative - Always ask confirmation"
    echo "  2) Smart       - Auto-proceed for safe operations (recommended)"
    echo "  3) Autonomous  - Auto-proceed for most operations"
    echo ""
    read -p "Select trust level (1-3): " choice
    
    case $choice in
        1) level="conservative" ;;
        2) level="smart" ;;
        3) level="autonomous" ;;
        *) echo "Invalid choice"; return 1 ;;
    esac
    
    read -p "Auto-proceed delay in seconds (default: 6): " delay
    delay=${delay:-6}
    
    set_trust_level "$level" "$delay"
}

# Export functions
export -f load_trust_config
export -f save_trust_config
export -f is_safe_operation
export -f requires_confirmation
export -f auto_proceed
export -f describe_trust_level
export -f set_trust_level
export -f log_trust_decision
export -f configure_trust