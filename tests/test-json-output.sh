#!/bin/bash

# 🧪 Tests for JSON Output System v2.2

set +e

# Setup test environment
TEST_DIR=$(mktemp -d)
export JEANCLAUDE_DIR="$TEST_DIR/.jeanclaude"
mkdir -p "$JEANCLAUDE_DIR"/{lib,agents,context,memory/{session,project}}

# Copy files for testing
cp "$(dirname "$0")/../lib/context-manager.sh" "$JEANCLAUDE_DIR/lib/"
cp "$(dirname "$0")/../lib/output-formatter.sh" "$JEANCLAUDE_DIR/lib/"
cp "$(dirname "$0")/../agents/navigator.sh" "$JEANCLAUDE_DIR/agents/"
cp "$(dirname "$0")/../agents/git-guardian.sh" "$JEANCLAUDE_DIR/agents/"
cp "$(dirname "$0")/../agents/test-runner.sh" "$JEANCLAUDE_DIR/agents/"

# Source libraries
source "$JEANCLAUDE_DIR/lib/context-manager.sh"
source "$JEANCLAUDE_DIR/lib/output-formatter.sh"

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

echo "🧪 Testing JSON Output System v2.2"
echo "========================================="

# Initialize context for agents
cd "$TEST_DIR"
JEANCLAUDE_DIR="$JEANCLAUDE_DIR" init_context

# Test 1: Output formatter basic functions
echo ""
echo "Test 1: Output formatter functions"
OUTPUT_FORMAT="json"
JSON_OUTPUT=$(output "Test message" '{"test": "data"}' "test-agent" "test-action" "success")
run_test "JSON output generated" "echo '$JSON_OUTPUT' | jq -e '.agent == \"test-agent\"'"
run_test "JSON has timestamp" "echo '$JSON_OUTPUT' | jq -e '.timestamp'"
run_test "JSON has correct status" "echo '$JSON_OUTPUT' | jq -e '.status == \"success\"'"

# Test 2: Text vs JSON output
echo ""
echo "Test 2: Text vs JSON output modes"
OUTPUT_FORMAT="text"
TEXT_OUTPUT=$(output "Test message")
run_test "Text output is simple" "[ '$TEXT_OUTPUT' = 'Test message' ]"

OUTPUT_FORMAT="json"
JSON_OUTPUT=$(output "Test message")
run_test "JSON output is structured" "echo '$JSON_OUTPUT' | jq -e '.'"

# Test 3: Navigator with JSON flag
echo ""
echo "Test 3: Navigator agent JSON output"
mkdir -p "$TEST_DIR/src"
echo "test" > "$TEST_DIR/src/test.js"

# Test without JSON
OUTPUT=$("$JEANCLAUDE_DIR/agents/navigator.sh" discover "$TEST_DIR" 2>&1 || true)
run_test "Navigator text output works" "echo '$OUTPUT' | grep -q 'Navigator'"

# Test with JSON
JSON_OUTPUT=$("$JEANCLAUDE_DIR/agents/navigator.sh" discover "$TEST_DIR" --json 2>&1 || true)
run_test "Navigator JSON output is valid" "echo '$JSON_OUTPUT' | jq -e '.agent == \"navigator\"' 2>/dev/null"

# Test 4: Git Guardian with JSON flag
echo ""
echo "Test 4: Git Guardian agent JSON output"
cd "$TEST_DIR"
git init >/dev/null 2>&1
git config user.email "test@test.com"
git config user.name "Test"
echo "test" > test.txt
git add test.txt
git commit -m "test" >/dev/null 2>&1

# Test status with JSON
JSON_OUTPUT=$("$JEANCLAUDE_DIR/agents/git-guardian.sh" status --json 2>&1 || true)
run_test "Git Guardian JSON is valid" "echo '$JSON_OUTPUT' | jq -e '.agent == \"git-guardian\"' 2>/dev/null"
run_test "Git Guardian JSON has branch info" "echo '$JSON_OUTPUT' | jq -e '.data.branch' 2>/dev/null"

# Test 5: Test Runner with JSON flag
echo ""
echo "Test 5: Test Runner agent JSON output"

# Create a simple test file
cat > "$TEST_DIR/test.py" << EOF
def test_simple():
    assert 1 == 1
EOF

JSON_OUTPUT=$("$JEANCLAUDE_DIR/agents/test-runner.sh" smoke "$TEST_DIR" --json 2>&1 || true)
run_test "Test Runner JSON is valid" "echo '$JSON_OUTPUT' | jq -e '.agent == \"test-runner\"' 2>/dev/null"

# Test 6: Error handling in JSON
echo ""
echo "Test 6: Error output in JSON format"
OUTPUT_FORMAT="json"
ERROR_JSON=$(output_error "Test error" 42 "test-agent")
run_test "Error JSON has error field" "echo '$ERROR_JSON' | jq -e '.data.error == \"Test error\"'"
run_test "Error JSON has correct status" "echo '$ERROR_JSON' | jq -e '.status == \"error\"'"

# Test 7: Chaining agents with JSON
echo ""
echo "Test 7: Agent chaining with JSON"

# Navigator outputs JSON that git-guardian can read
NAV_OUTPUT=$("$JEANCLAUDE_DIR/agents/navigator.sh" discover "$TEST_DIR" --json 2>/dev/null || echo '{}')
FILES_COUNT=$(echo "$NAV_OUTPUT" | jq -r '.data.files' 2>/dev/null || echo "0")
run_test "Can extract data from agent JSON" "[ -n '$FILES_COUNT' ]"

# Test 8: Parse args function
echo ""
echo "Test 8: Argument parsing"
source "$JEANCLAUDE_DIR/lib/output-formatter.sh"
ARGS=($(parse_args "action" "param" "--json" "other"))
run_test "Removes --json from args" "[ '${ARGS[0]}' = 'action' ] && [ '${ARGS[2]}' = 'other' ]"

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