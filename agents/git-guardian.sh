#!/bin/bash

# 🛡️ Git Guardian Agent v2.3 - Gestion Git avec support JSON et trust
# Usage: ./git-guardian.sh [check|commit|branch|status] [message] [--json]

set -e

# Load libraries
CONTEXT_LIB="$(dirname "$0")/../lib/context-manager.sh"
OUTPUT_LIB="$(dirname "$0")/../lib/output-formatter.sh"
TRUST_LIB="$(dirname "$0")/../lib/trust-manager.sh"
[ -f "$CONTEXT_LIB" ] && source "$CONTEXT_LIB"
[ -f "$OUTPUT_LIB" ] && source "$OUTPUT_LIB"
[ -f "$TRUST_LIB" ] && source "$TRUST_LIB"

# Parse arguments (remove --json if present)
CLEAN_ARGS=()
for arg in "$@"; do
    if [ "$arg" != "--json" ]; then
        CLEAN_ARGS+=("$arg")
    fi
done
ACTION=${CLEAN_ARGS[0]:-check}
MESSAGE=${CLEAN_ARGS[1]:-""}

# Git Guardian needs ONLY: git state and commit history
if [ -n "$JEANCLAUDE_DIR" ]; then
    PROJECT_ROOT=$(get_context "git-guardian" "minimal" "project_root" 2>/dev/null || pwd)
    CURRENT_BRANCH=$(get_context "git-guardian" "shared" "git_branch" 2>/dev/null || git branch --show-current 2>/dev/null || echo "main")
    OUTPUT_DIR="${JEANCLAUDE_DIR}/memory/session"
else
    PROJECT_ROOT=$(pwd)
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    OUTPUT_DIR="${PROJECT_ROOT}/.jeanclaude/memory/session"
fi

# Agent-specific: commit patterns
LAST_COMMIT_TIME=$(get_context "git-guardian" "agent" "last_commit_time" || echo "0")
COMMIT_STYLE=$(get_context "git-guardian" "agent" "commit_style" || echo "conventional")

# Config
COMMIT_INTERVAL=1800  # 30 minutes in seconds
MIN_CHANGES=1         # Minimum files changed to trigger auto-commit

function log() {
    if ! is_json_output; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GIT-GUARDIAN] $1" | tee -a "$OUTPUT_DIR/../logs/agents.log"
    fi
}

function get_last_commit_time() {
    if git log -1 --format=%ct 2>/dev/null; then
        git log -1 --format=%ct
    else
        echo "0"
    fi
}

function check_uncommitted_changes() {
    local changes=$(git status --porcelain 2>/dev/null | wc -l)
    echo "$changes"
}

function should_commit() {
    local last_commit=$(get_last_commit_time)
    local now=$(date +%s)
    local time_diff=$((now - last_commit))
    local changes=$(check_uncommitted_changes)
    
    if [ "$changes" -ge "$MIN_CHANGES" ]; then
        if [ "$time_diff" -ge "$COMMIT_INTERVAL" ]; then
            log "Time trigger: ${time_diff}s since last commit"
            return 0
        fi
        
        # Check for significant changes
        if [ "$changes" -ge 10 ]; then
            log "Change trigger: $changes files modified"
            return 0
        fi
    fi
    
    return 1
}

function auto_commit() {
    local changes=$(check_uncommitted_changes)
    
    if [ "$changes" -eq 0 ]; then
        log "No changes to commit"
        return 0
    fi
    
    # Generate commit message based on changes
    local message="auto: checkpoint $(date +%H:%M)"
    
    # Try to be more specific
    local modified_files=$(git diff --name-only 2>/dev/null | head -3 | xargs basename -a 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    if [ -n "$modified_files" ]; then
        message="auto: working on $modified_files"
    fi
    
    log "Auto-committing $changes changes"
    
    git add -A
    git commit -m "$message" --no-verify
    
    echo "$(date): Auto-commit - $changes files" >> "$OUTPUT_DIR/git-actions.log"
    log "Auto-commit successful: $message"
}

function create_feature_branch() {
    local branch_name="$1"
    
    if [ -z "$branch_name" ]; then
        # Generate branch name based on current time
        branch_name="feature/work-$(date +%Y%m%d-%H%M)"
    fi
    
    # Trust check for branch creation
    if ! requires_confirmation "branch" "$branch_name" "git"; then
        auto_proceed "branch" "$branch_name" "Creating new branch"
    fi
    
    # Ensure we're on main/master
    local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    
    log "Creating branch: $branch_name from $main_branch"
    
    git checkout "$main_branch" 2>/dev/null || git checkout main 2>/dev/null || git checkout master
    git pull origin "$main_branch" 2>/dev/null || true
    git checkout -b "$branch_name"
    
    echo "$(date): Created branch $branch_name" >> "$OUTPUT_DIR/git-actions.log"
    log "Branch created: $branch_name"
}

function smart_commit() {
    local custom_message="$1"
    local changes=$(check_uncommitted_changes)
    
    if [ "$changes" -eq 0 ]; then
        log "No changes to commit"
        return 0
    fi
    
    # Trust check for commit
    if requires_confirmation "commit" "repository" "git"; then
        read -p "Commit $changes files with message '$custom_message'? (y/n): " confirm
        [ "$confirm" != "y" ] && return 1
    else
        auto_proceed "commit" "$changes files" "Committing changes"
    fi
    
    # Analyze changes to generate better commit message
    local added=$(git diff --cached --numstat 2>/dev/null | wc -l)
    local modified=$(git diff --name-status 2>/dev/null | grep '^M' | wc -l)
    local deleted=$(git diff --name-status 2>/dev/null | grep '^D' | wc -l)
    
    local prefix="chore"
    if [ -n "$custom_message" ]; then
        # Try to detect type from message
        if echo "$custom_message" | grep -qiE 'fix|bug|issue|error'; then
            prefix="fix"
        elif echo "$custom_message" | grep -qiE 'feat|add|new|create'; then
            prefix="feat"
        elif echo "$custom_message" | grep -qiE 'test|spec'; then
            prefix="test"
        elif echo "$custom_message" | grep -qiE 'doc'; then
            prefix="docs"
        elif echo "$custom_message" | grep -qiE 'refactor|clean|improve'; then
            prefix="refactor"
        fi
    fi
    
    local message="${prefix}: ${custom_message:-checkpoint}"
    
    log "Committing with message: $message"
    
    git add -A
    git commit -m "$message"
    
    echo "$(date): Manual commit - $message" >> "$OUTPUT_DIR/git-actions.log"
    log "Commit successful"
}

function show_status() {
    local changes=$(check_uncommitted_changes)
    local last_commit_time=$(get_last_commit_time)
    local now=$(date +%s)
    local time_since=$((now - last_commit_time))
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    if is_json_output; then
        local recent_commits=$(git log --oneline -5 --format='%H|%s' 2>/dev/null | \
            awk -F'|' '{printf "{\\\"hash\\\":\\\"%s\\\",\\\"message\\\":\\\"%s\\\"},", $1, $2}' | \
            sed 's/,$//')
        
        output_success "Git status retrieved" \
            "{\"branch\": \"$current_branch\", \"uncommitted_files\": $changes, \"last_commit_minutes_ago\": $(($time_since / 60)), \"recent_commits\": [$recent_commits]}" \
            "git-guardian" "status"
    else
        cat << EOF
📊 Git Status Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Branch: $current_branch
Uncommitted changes: $changes files
Last commit: $(($time_since / 60)) minutes ago
Auto-commit in: $(( (COMMIT_INTERVAL - time_since) / 60 )) minutes

Recent commits:
$(git log --oneline -5 2>/dev/null || echo "No commits yet")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    fi
    
    if should_commit; then
        echo "⚠️  Auto-commit recommended!"
    fi
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" "$(dirname "$OUTPUT_DIR")/logs"

# Save git-guardian context
function save_context() {
    local commits_today=$(git log --since="24 hours ago" --oneline 2>/dev/null | wc -l || echo 0)
    
    save_agent_context "git-guardian" "{
        \"last_commit_time\": $(date +%s),
        \"last_action\": \"$ACTION\",
        \"current_branch\": \"$CURRENT_BRANCH\",
        \"commits_today\": $commits_today,
        \"commit_style\": \"$COMMIT_STYLE\",
        \"uncommitted_files\": $(git status --porcelain 2>/dev/null | wc -l || echo 0)
    }"
}

trap save_context EXIT

# Execute action
case $ACTION in
    check)
        if should_commit; then
            log "Auto-commit triggered"
            auto_commit
        else
            log "No commit needed yet"
        fi
        ;;
    commit)
        smart_commit "$MESSAGE"
        ;;
    branch)
        create_feature_branch "$MESSAGE"
        ;;
    status)
        show_status
        ;;
    auto)
        # Run in background mode
        log "Starting auto-commit daemon"
        while true; do
            if should_commit; then
                auto_commit
            fi
            sleep 300  # Check every 5 minutes
        done
        ;;
    *)
        echo "Usage: $0 [check|commit|branch|status|auto] [message/branch-name]"
        exit 1
        ;;
esac