#!/bin/bash

# Claude Framework Installer
# Usage: ./install.sh [target-directory]

TARGET_DIR=${1:-.}
FRAMEWORK_DIR="$(dirname "$0")"

echo "🤖 Installing Claude Framework..."

# Create necessary files if they don't exist
if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    cp "$FRAMEWORK_DIR/templates/CLAUDE.md.template" "$TARGET_DIR/CLAUDE.md"
    echo "✅ Created CLAUDE.md"
else
    echo "⏭️  CLAUDE.md already exists, skipping"
fi

if [ ! -f "$TARGET_DIR/NAVIGATION.md" ]; then
    cp "$FRAMEWORK_DIR/templates/NAVIGATION.md.template" "$TARGET_DIR/NAVIGATION.md"
    echo "✅ Created NAVIGATION.md"
else
    echo "⏭️  NAVIGATION.md already exists, skipping"
fi

if [ ! -f "$TARGET_DIR/TODO.md" ]; then
    cp "$FRAMEWORK_DIR/templates/TODO.md.template" "$TARGET_DIR/TODO.md"
    echo "✅ Created TODO.md"
else
    echo "⏭️  TODO.md already exists, skipping"
fi

# Create config if not exists
if [ ! -f "$TARGET_DIR/.claude-config.yml" ]; then
    cp "$FRAMEWORK_DIR/templates/config.yml.template" "$TARGET_DIR/.claude-config.yml"
    echo "✅ Created .claude-config.yml"
else
    echo "⏭️  .claude-config.yml already exists, skipping"
fi

# Create symlink to framework
if [ ! -e "$TARGET_DIR/.claude" ]; then
    ln -s "$FRAMEWORK_DIR" "$TARGET_DIR/.claude"
    echo "✅ Linked framework to .claude/"
fi

echo ""
echo "🎉 Claude Framework installed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Edit CLAUDE.md with your project-specific instructions"
echo "2. Configure .claude-config.yml for your needs"
echo "3. Start Claude Code with: 'Use the .claude framework'"
echo ""
echo "📚 Documentation: $FRAMEWORK_DIR/README.md"