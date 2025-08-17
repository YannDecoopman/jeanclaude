#!/bin/bash

# 🤖 Installation de Jean Claude Framework v2
# Usage: ./install.sh [project_directory]

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Jean Claude Framework v2 Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Configuration
PROJECT_ROOT="${1:-$(pwd)}"
JEANCLAUDE_DIR="$PROJECT_ROOT/.jeanclaude"
FRAMEWORK_DIR="$(dirname "$0")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

function log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo ""
echo "📍 Installing in: $PROJECT_ROOT"
echo ""

# 1. Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$JEANCLAUDE_DIR"/{agents,hooks,methods,templates,memory/{session,project},logs,backups}

log_success "Directory structure created"

# 2. Copy agents
echo ""
echo "🤖 Installing agents..."
if [ -d "$FRAMEWORK_DIR/agents" ]; then
    cp -r "$FRAMEWORK_DIR/agents" "$JEANCLAUDE_DIR/"
    chmod +x "$JEANCLAUDE_DIR/agents/"*.sh
    log_success "$(ls -1 "$JEANCLAUDE_DIR/agents" | wc -l) agents installed"
else
    log_info "No agents to install"
fi

# 3. Copy hooks
echo ""
echo "🪝 Installing hooks..."
if [ -d "$FRAMEWORK_DIR/hooks" ]; then
    cp -r "$FRAMEWORK_DIR/hooks" "$JEANCLAUDE_DIR/"
    chmod +x "$JEANCLAUDE_DIR/hooks/"*.sh
    log_success "$(ls -1 "$JEANCLAUDE_DIR/hooks" | wc -l) hooks installed"
else
    log_info "No hooks to install"
fi

# 4. Copy methods
echo ""
echo "📋 Installing methods..."
if [ -d "$FRAMEWORK_DIR/methods" ]; then
    cp -r "$FRAMEWORK_DIR/methods" "$JEANCLAUDE_DIR/"
    log_success "$(ls -1 "$JEANCLAUDE_DIR/methods" | wc -l) methods installed"
else
    log_info "No methods to install"
fi

# 5. Copy templates
echo ""
echo "📄 Installing templates..."
if [ -d "$FRAMEWORK_DIR/templates" ]; then
    cp -r "$FRAMEWORK_DIR/templates" "$JEANCLAUDE_DIR/"
    log_success "$(ls -1 "$JEANCLAUDE_DIR/templates" | wc -l) templates installed"
else
    log_info "No templates to install"
fi

# 6. Create CLAUDE.md if not exists
echo ""
echo "📝 Setting up CLAUDE.md..."
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    if [ -f "$FRAMEWORK_DIR/templates/CLAUDE.md.template" ]; then
        cp "$FRAMEWORK_DIR/templates/CLAUDE.md.template" "$PROJECT_ROOT/CLAUDE.md"
        log_success "CLAUDE.md created - Please customize it"
    else
        log_error "Template not found"
    fi
else
    log_info "CLAUDE.md already exists - skipping"
fi

# 7. Initialize Git hooks (optional)
echo ""
echo "🔗 Git hooks setup..."
if [ -d "$PROJECT_ROOT/.git" ]; then
    read -p "Install Git hooks integration? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Link pre-commit hook
        if [ -f "$JEANCLAUDE_DIR/hooks/pre-commit.sh" ]; then
            ln -sf "$JEANCLAUDE_DIR/hooks/pre-commit.sh" "$PROJECT_ROOT/.git/hooks/pre-commit"
            chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"
            log_success "Git pre-commit hook linked"
        fi
    else
        log_info "Git hooks skipped"
    fi
else
    log_info "Not a Git repository - skipping hooks"
fi

# 8. Create initial configuration
echo ""
echo "⚙️  Creating configuration..."
cat > "$JEANCLAUDE_DIR/config.json" << EOF
{
  "version": "2.0",
  "project_name": "$(basename "$PROJECT_ROOT")",
  "installed_date": "$(date -Iseconds)",
  "features": {
    "agents": true,
    "hooks": true,
    "memory": true,
    "react_pattern": true,
    "git_strategy": true
  },
  "settings": {
    "auto_commit_interval": 1800,
    "memory_retention_days": 7,
    "log_level": "info"
  }
}
EOF
log_success "Configuration created"

# 9. Initialize memory
echo ""
echo "🧠 Initializing memory system..."
cat > "$JEANCLAUDE_DIR/memory/project/context.md" << EOF
# Project Context
Initialized: $(date)
Project: $(basename "$PROJECT_ROOT")

## Key Information
- Framework: Jean Claude v2
- Location: $PROJECT_ROOT

## Patterns
(Will be populated as you work)

## Pitfalls
(Will be populated from errors)
EOF

cat > "$JEANCLAUDE_DIR/memory/session/current.md" << EOF
# Session Memory
Started: $(date)
Project: $(basename "$PROJECT_ROOT")

## Installation
- Jean Claude Framework v2 installed
- Ready to start development
EOF

log_success "Memory system initialized"

# 10. Create quick reference
echo ""
echo "📚 Creating quick reference..."
cat > "$JEANCLAUDE_DIR/README.md" << EOF
# Jean Claude Framework - Quick Reference

## 🤖 Available Agents
- **navigator.sh** - Code navigation and discovery
- **clarifier.sh** - Request clarification
- **git-guardian.sh** - Automatic Git management
- **test-runner.sh** - Progressive testing
- **memory-keeper.sh** - Context management

## 🪝 Available Hooks
- **pre-code.sh** - Before writing code
- **post-code.sh** - After writing code
- **pre-commit.sh** - Before Git commit
- **post-error.sh** - After errors
- **session-end.sh** - End of session

## 📋 Methods
- **CLARIFICATION.md** - Clarification process
- **GIT_STRATEGY.md** - Git workflow
- **REACT_PATTERN.md** - ReAct methodology

## 🚀 Quick Commands

### Run an agent
\`\`\`bash
.jeanclaude/agents/navigator.sh discover
.jeanclaude/agents/git-guardian.sh status
\`\`\`

### Run a hook
\`\`\`bash
.jeanclaude/hooks/pre-code.sh "Feature request"
\`\`\`

### Check memory
\`\`\`bash
cat .jeanclaude/memory/session/current.md
\`\`\`

---
Installed: $(date)
EOF

log_success "Quick reference created"

# 11. Detect project type and suggest next steps
echo ""
echo "🔍 Detecting project type..."

PROJECT_TYPE="unknown"
if [ -f "$PROJECT_ROOT/package.json" ]; then
    PROJECT_TYPE="node"
    log_info "Node.js project detected"
elif [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/setup.py" ]; then
    PROJECT_TYPE="python"
    log_info "Python project detected"
elif [ -f "$PROJECT_ROOT/composer.json" ]; then
    PROJECT_TYPE="php"
    log_info "PHP project detected"
elif [ -f "$PROJECT_ROOT/go.mod" ]; then
    PROJECT_TYPE="go"
    log_info "Go project detected"
fi

# Final summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📂 Installed in: $JEANCLAUDE_DIR"
echo "📊 Components:"
echo "   - $(ls -1 "$JEANCLAUDE_DIR/agents" 2>/dev/null | wc -l) agents"
echo "   - $(ls -1 "$JEANCLAUDE_DIR/hooks" 2>/dev/null | wc -l) hooks"
echo "   - $(ls -1 "$JEANCLAUDE_DIR/methods" 2>/dev/null | wc -l) methods"
echo "   - $(ls -1 "$JEANCLAUDE_DIR/templates" 2>/dev/null | wc -l) templates"
echo ""
echo "🎯 Next Steps:"
echo "   1. Edit CLAUDE.md with project specifics"
echo "   2. Test an agent: $JEANCLAUDE_DIR/agents/navigator.sh discover"
echo "   3. Read the methods in $JEANCLAUDE_DIR/methods/"
echo "   4. Start coding with Claude!"
echo ""
echo "💡 Pro tip: Add to your .gitignore:"
echo "   .jeanclaude/memory/session/"
echo "   .jeanclaude/logs/"
echo "   .jeanclaude/backups/"
echo ""
echo "📚 Documentation: $JEANCLAUDE_DIR/README.md"
echo ""
echo "Happy coding with Jean Claude! 🤖"