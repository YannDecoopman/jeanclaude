#!/bin/bash

# 🧪 Test Runner Agent - Exécution progressive des tests
# Usage: ./test-runner.sh [smoke|unit|integration|full] [path]

set -e

LEVEL=${1:-smoke}
TARGET=${2:-.}
OUTPUT_DIR="${JEANCLAUDE_MEMORY:-../.jeanclaude/memory}/session"

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TEST-RUNNER] $1" | tee -a "$OUTPUT_DIR/../logs/agents.log"
}

function detect_test_framework() {
    local path="$1"
    
    # Python
    if [ -f "$path/pytest.ini" ] || [ -f "$path/setup.cfg" ]; then
        echo "pytest"
        return
    elif [ -f "$path/manage.py" ]; then
        echo "django"
        return
    fi
    
    # JavaScript/Node
    if [ -f "$path/package.json" ]; then
        if grep -q "jest" "$path/package.json" 2>/dev/null; then
            echo "jest"
            return
        elif grep -q "mocha" "$path/package.json" 2>/dev/null; then
            echo "mocha"
            return
        elif grep -q "vitest" "$path/package.json" 2>/dev/null; then
            echo "vitest"
            return
        fi
    fi
    
    # PHP
    if [ -f "$path/phpunit.xml" ] || [ -f "$path/phpunit.xml.dist" ]; then
        echo "phpunit"
        return
    fi
    
    # Go
    if [ -f "$path/go.mod" ]; then
        echo "go"
        return
    fi
    
    echo "unknown"
}

function run_smoke_tests() {
    local framework="$1"
    log "Running smoke tests with $framework"
    
    case $framework in
        pytest)
            pytest -v -x --tb=short -m "smoke or quick" 2>&1 | tee "$OUTPUT_DIR/test-smoke.log" || true
            ;;
        jest)
            npm test -- --bail --testNamePattern="smoke|quick" 2>&1 | tee "$OUTPUT_DIR/test-smoke.log" || true
            ;;
        phpunit)
            ./vendor/bin/phpunit --group smoke --stop-on-failure 2>&1 | tee "$OUTPUT_DIR/test-smoke.log" || true
            ;;
        go)
            go test -v -short -run "Smoke" ./... 2>&1 | tee "$OUTPUT_DIR/test-smoke.log" || true
            ;;
        *)
            log "No smoke tests available for $framework"
            return 1
            ;;
    esac
    
    log "Smoke tests completed"
}

function run_unit_tests() {
    local framework="$1"
    log "Running unit tests with $framework"
    
    case $framework in
        pytest)
            pytest -v --tb=short -m "not integration and not e2e" 2>&1 | tee "$OUTPUT_DIR/test-unit.log" || true
            ;;
        jest)
            npm test -- --testPathIgnorePatterns="integration|e2e" 2>&1 | tee "$OUTPUT_DIR/test-unit.log" || true
            ;;
        phpunit)
            ./vendor/bin/phpunit --exclude-group integration,e2e 2>&1 | tee "$OUTPUT_DIR/test-unit.log" || true
            ;;
        go)
            go test -v -short ./... 2>&1 | tee "$OUTPUT_DIR/test-unit.log" || true
            ;;
        *)
            log "No unit tests available for $framework"
            return 1
            ;;
    esac
    
    log "Unit tests completed"
}

function run_integration_tests() {
    local framework="$1"
    log "Running integration tests with $framework"
    
    case $framework in
        pytest)
            pytest -v --tb=short -m "integration" 2>&1 | tee "$OUTPUT_DIR/test-integration.log" || true
            ;;
        jest)
            npm test -- --testPathPattern="integration" 2>&1 | tee "$OUTPUT_DIR/test-integration.log" || true
            ;;
        phpunit)
            ./vendor/bin/phpunit --group integration 2>&1 | tee "$OUTPUT_DIR/test-integration.log" || true
            ;;
        go)
            go test -v -tags=integration ./... 2>&1 | tee "$OUTPUT_DIR/test-integration.log" || true
            ;;
        *)
            log "No integration tests available for $framework"
            return 1
            ;;
    esac
    
    log "Integration tests completed"
}

function run_full_tests() {
    local framework="$1"
    log "Running full test suite with $framework"
    
    case $framework in
        pytest)
            pytest -v --tb=short --cov 2>&1 | tee "$OUTPUT_DIR/test-full.log" || true
            ;;
        jest)
            npm test -- --coverage 2>&1 | tee "$OUTPUT_DIR/test-full.log" || true
            ;;
        phpunit)
            ./vendor/bin/phpunit --coverage-text 2>&1 | tee "$OUTPUT_DIR/test-full.log" || true
            ;;
        go)
            go test -v -cover ./... 2>&1 | tee "$OUTPUT_DIR/test-full.log" || true
            ;;
        *)
            log "No full test suite available for $framework"
            return 1
            ;;
    esac
    
    log "Full test suite completed"
}

function generate_test_report() {
    local level="$1"
    local log_file="$OUTPUT_DIR/test-${level}.log"
    
    if [ ! -f "$log_file" ]; then
        log "No test results to report"
        return
    fi
    
    cat > "$OUTPUT_DIR/test-report.md" << EOF
# 📊 Test Report
Level: $level
Time: $(date)

## Summary
EOF
    
    # Try to extract test counts
    if grep -q "passed" "$log_file"; then
        echo "✅ Tests passed: $(grep -c "passed\|PASS\|ok" "$log_file" || echo "unknown")" >> "$OUTPUT_DIR/test-report.md"
    fi
    if grep -q "failed\|FAIL\|error" "$log_file"; then
        echo "❌ Tests failed: $(grep -c "failed\|FAIL\|error" "$log_file" || echo "unknown")" >> "$OUTPUT_DIR/test-report.md"
    fi
    
    # Extract failures if any
    if grep -q "failed\|FAIL\|error" "$log_file"; then
        cat >> "$OUTPUT_DIR/test-report.md" << EOF

## Failed Tests
\`\`\`
$(grep -A 2 "failed\|FAIL\|error" "$log_file" | head -20)
\`\`\`
EOF
    fi
    
    log "Test report generated"
    cat "$OUTPUT_DIR/test-report.md"
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" "$(dirname "$OUTPUT_DIR")/logs"

# Detect test framework
FRAMEWORK=$(detect_test_framework "$TARGET")
log "Detected test framework: $FRAMEWORK"

if [ "$FRAMEWORK" = "unknown" ]; then
    log "WARNING: No test framework detected"
    echo "⚠️  No test framework detected in $TARGET"
    echo "Supported frameworks: pytest, jest, mocha, vitest, phpunit, go test"
    exit 0
fi

# Execute test level
case $LEVEL in
    smoke)
        run_smoke_tests "$FRAMEWORK"
        ;;
    unit)
        run_unit_tests "$FRAMEWORK"
        ;;
    integration)
        run_integration_tests "$FRAMEWORK"
        ;;
    full)
        run_full_tests "$FRAMEWORK"
        ;;
    *)
        echo "Usage: $0 [smoke|unit|integration|full] [path]"
        exit 1
        ;;
esac

# Generate report
generate_test_report "$LEVEL"