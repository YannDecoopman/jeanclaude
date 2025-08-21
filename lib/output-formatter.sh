#!/bin/bash

# 📊 Output Formatter for Jean Claude v2.2
# Provides dual output: human-readable (default) and JSON (--json flag)

# Check if JSON output is requested
OUTPUT_FORMAT="text"
for arg in "$@"; do
    if [ "$arg" = "--json" ]; then
        OUTPUT_FORMAT="json"
        break
    fi
done

# Standard output structure for JSON
function create_json_output() {
    local agent=$1
    local action=$2
    local status=$3
    local data=$4
    local metadata=${5:-"{}"}
    local messages=${6:-"[]"}
    local next_agents=${7:-"[]"}
    
    cat << EOF
{
  "agent": "$agent",
  "version": "2.2",
  "timestamp": "$(date -Iseconds)",
  "action": "$action",
  "status": "$status",
  "data": $data,
  "metadata": $metadata,
  "messages": $messages,
  "next_agents": $next_agents
}
EOF
}

# Dual output function
function output() {
    local message=$1
    local json_data=${2:-"null"}
    local agent=${3:-"unknown"}
    local action=${4:-"default"}
    local status=${5:-"info"}
    
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        # JSON output
        if [ "$json_data" = "null" ]; then
            # Convert message to JSON data
            json_data="{\"message\": \"$message\"}"
        fi
        create_json_output "$agent" "$action" "$status" "$json_data"
    else
        # Human-readable output
        echo "$message"
    fi
}

# Output error in appropriate format
function output_error() {
    local error_msg=$1
    local error_code=${2:-1}
    local agent=${3:-"unknown"}
    
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        create_json_output "$agent" "error" "error" \
            "{\"error\": \"$error_msg\", \"code\": $error_code}"
    else
        echo "❌ Error: $error_msg" >&2
    fi
}

# Output success in appropriate format
function output_success() {
    local message=$1
    local data=${2:-"{}"}
    local agent=${3:-"unknown"}
    local action=${4:-"complete"}
    
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        create_json_output "$agent" "$action" "success" "$data"
    else
        echo "✅ $message"
    fi
}

# Output warning in appropriate format
function output_warning() {
    local message=$1
    local data=${2:-"{}"}
    local agent=${3:-"unknown"}
    
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        create_json_output "$agent" "warning" "warning" \
            "{\"warning\": \"$message\", \"details\": $data}"
    else
        echo "⚠️  $message"
    fi
}

# Output info in appropriate format
function output_info() {
    local message=$1
    local data=${2:-"{}"}
    local agent=${3:-"unknown"}
    
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        create_json_output "$agent" "info" "info" \
            "{\"info\": \"$message\", \"details\": $data}"
    else
        echo "ℹ️  $message"
    fi
}

# Parse arguments and remove --json if present
function parse_args() {
    for arg in "$@"; do
        if [ "$arg" != "--json" ]; then
            echo "$arg"
        fi
    done
}

# Check if JSON output is enabled
function is_json_output() {
    [ "$OUTPUT_FORMAT" = "json" ]
}

# Convert bash associative array to JSON
function array_to_json() {
    local -n arr=$1
    local json="{"
    local first=true
    
    for key in "${!arr[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            json+=","
        fi
        json+="\"$key\":\"${arr[$key]}\""
    done
    
    json+="}"
    echo "$json"
}

# Export functions for sourcing
export -f create_json_output
export -f output
export -f output_error
export -f output_success
export -f output_warning
export -f output_info
export -f parse_args
export -f is_json_output
export -f array_to_json
export OUTPUT_FORMAT