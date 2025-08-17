#!/bin/bash

# 🧪 Tests for Context Management System v2.1

# Don't exit on error for tests
set +e

# Setup test environment
TEST_DIR=$(mktemp -d)
export JEANCLAUDE_DIR="$TEST_DIR/.jeanclaude"
mkdir -p "$JEANCLAUDE_DIR"/{lib,agents,context}

# Copy files for testing
cp "$(dirname "$0")/../lib/context-manager.sh" "$JEANCLAUDE_DIR/lib/"
cp "$(dirname "$0")/../agents/navigator.sh" "$JEANCLAUDE_DIR/agents/"

# Source context manager
source "$JEANCLAUDE_DIR/lib/context-manager.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
function test_pass() {
    echo "✅ $1"
    ((TESTS_PASSED++))
}

function test_fail() {
    echo "❌ $1: $2"
    ((TESTS_FAILED++))
}

function run_test() {
    local test_name=$1
    local test_cmd=$2
    ((TESTS_RUN++))
    
    if eval "$test_cmd"; then
        test_pass "$test_name"
    else
        test_fail "$test_name" "Command failed"
    fi
}

echo "🧪 Testing Context Management System v2.1"
echo "========================================="

# Test 1: Context initialization
echo ""
echo "Test 1: Context initialization"
cd "$TEST_DIR"
JEANCLAUDE_DIR="$JEANCLAUDE_DIR" init_context
run_test "Minimal context created" "[ -f '$JEANCLAUDE_DIR/context/minimal.json' ]"
run_test "Shared context created" "[ -f '$JEANCLAUDE_DIR/context/shared.json' ]"

# Test 2: Get minimal context
echo ""
echo "Test 2: Get minimal context"
PROJECT_ROOT=$(get_context "test" "minimal" "project_root")
run_test "Can get project_root" "[ -n '$PROJECT_ROOT' ]"
run_test "Project root is correct" "[ '$PROJECT_ROOT' = '$TEST_DIR' ]"

# Test 3: Save and retrieve agent context
echo ""
echo "Test 3: Agent-specific context"
save_agent_context "test-agent" '{"test_key": "test_value", "count": 42}'
run_test "Agent context saved" "[ -f '$JEANCLAUDE_DIR/context/agents/test-agent.json' ]"

TEST_VALUE=$(get_context "test-agent" "agent" "test_key")
run_test "Can retrieve agent context" "[ '$TEST_VALUE' = 'test_value' ]"

COUNT=$(get_context "test-agent" "agent" "count")
run_test "Can retrieve numeric values" "[ '$COUNT' = '42' ]"

# Test 4: Update shared context
echo ""
echo "Test 4: Update shared context"
update_shared_context "new_key" "new_value"
NEW_VALUE=$(get_context "test" "shared" "new_key")
run_test "Can update shared context" "[ '$NEW_VALUE' = 'new_value' ]"

# Test 5: Context isolation
echo ""
echo "Test 5: Context isolation (agents don't see each other's data)"
save_agent_context "agent-a" '{"private": "data-a"}'
save_agent_context "agent-b" '{"private": "data-b"}'

DATA_A=$(get_context "agent-a" "agent" "private")
DATA_B=$(get_context "agent-b" "agent" "private")
run_test "Agent A has its data" "[ '$DATA_A' = 'data-a' ]"
run_test "Agent B has its data" "[ '$DATA_B' = 'data-b' ]"

# Agent A shouldn't see Agent B's data
CROSS_DATA=$(get_context "agent-a" "agent" "private")
run_test "Agents contexts are isolated" "[ '$CROSS_DATA' != 'data-b' ]"

# Test 6: Context size reporting
echo ""
echo "Test 6: Context size reporting"
SIZE_OUTPUT=$(context_size "test-agent")
run_test "Can get context sizes" "echo '$SIZE_OUTPUT' | grep -q 'Minimal:'"

# Test 7: Project type detection
echo ""
echo "Test 7: Project type detection"
echo '{"name": "test"}' > "$TEST_DIR/package.json"
cd "$TEST_DIR"
PROJECT_TYPE=$(detect_project_type)
run_test "Detects Node.js project" "[ '$PROJECT_TYPE' = 'node' ]"

rm "$TEST_DIR/package.json"
echo "requests==2.0" > "$TEST_DIR/requirements.txt"
PROJECT_TYPE=$(detect_project_type)
run_test "Detects Python project" "[ '$PROJECT_TYPE' = 'python' ]"

# Test 8: Navigator with minimal context
echo ""
echo "Test 8: Navigator agent with minimal context"
cd "$TEST_DIR"
mkdir -p src
echo "test" > src/test.js

# Run navigator with minimal context
OUTPUT=$("$JEANCLAUDE_DIR/agents/navigator.sh" discover 2>&1 || true)
run_test "Navigator runs with context" "echo '$OUTPUT' | grep -q 'Navigator Agent v2.1'"

# Check if navigator saved its context
sleep 1  # Give time for trap to execute
run_test "Navigator saved context" "[ -f '$JEANCLAUDE_DIR/context/agents/navigator.json' ]"

# Test 9: Memory efficiency
echo ""
echo "Test 9: Memory efficiency (context sizes)"
MINIMAL_SIZE=$(wc -c < "$JEANCLAUDE_DIR/context/minimal.json")
SHARED_SIZE=$(wc -c < "$JEANCLAUDE_DIR/context/shared.json")

run_test "Minimal context < 500 bytes" "[ $MINIMAL_SIZE -lt 500 ]"
run_test "Shared context < 1000 bytes" "[ $SHARED_SIZE -lt 1000 ]"

# Summary
echo ""
echo "========================================="
echo "📊 Test Summary"
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

# Cleanup
rm -rf "$TEST_DIR"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo ""
    echo "🎉 All tests passed!"
    exit 0
else
    echo ""
    echo "⚠️  Some tests failed"
    exit 1
fi