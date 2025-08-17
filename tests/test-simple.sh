#!/bin/bash

set -e

# Setup
TEST_DIR=$(mktemp -d)
export JEANCLAUDE_DIR="$TEST_DIR/.jeanclaude"
mkdir -p "$JEANCLAUDE_DIR"/{lib,context}

# Copy context manager
cp lib/context-manager.sh "$JEANCLAUDE_DIR/lib/"

# Source it
source "$JEANCLAUDE_DIR/lib/context-manager.sh"

# Test 1: Init
echo "Test 1: Init context"
cd "$TEST_DIR"
init_context
ls -la "$JEANCLAUDE_DIR/context/"

# Test 2: Get context
echo "Test 2: Get context"
PROJECT_ROOT=$(get_context "test" "minimal" "project_root")
echo "Project root: $PROJECT_ROOT"

# Test 3: Save agent context
echo "Test 3: Save agent context"
save_agent_context "test-agent" '{"key": "value"}'
cat "$JEANCLAUDE_DIR/context/agents/test-agent.json"

# Cleanup
rm -rf "$TEST_DIR"
echo "✅ All tests passed"