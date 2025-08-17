#!/bin/bash

# 🛡️ Git Guardian Agent - Gestion automatique des commits et branches
# Usage: ./git-guardian.sh [check|commit|branch|status]

set -e

ACTION=${1:-check}
MESSAGE=${2:-""}
OUTPUT_DIR="${JEANCLAUDE_MEMORY:-../.jeanclaude/memory}/session"

# Config
COMMIT_INTERVAL=1800  # 30 minutes in seconds
MIN_CHANGES=1         # Minimum files changed to trigger auto-commit

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GIT-GUARDIAN] $1" | tee -a "$OUTPUT_DIR/../logs/agents.log"
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
    
    if should_commit; then
        echo "⚠️  Auto-commit recommended!"
    fi
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" "$(dirname "$OUTPUT_DIR")/logs"

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