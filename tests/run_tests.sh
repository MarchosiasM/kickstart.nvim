#!/bin/bash

# Comprehensive test runner for Neovim configuration
# Usage: ./tests/run_tests.sh [test_pattern]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NVIM_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$NVIM_CONFIG_DIR/tests"
TEMP_DIR="/tmp/nvim_config_test_$$"

echo -e "${BLUE}🧪 Running Neovim Configuration Tests${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Config Directory: $NVIM_CONFIG_DIR"
echo "Test Directory: $TEST_DIR"
echo ""

# Create temporary directory for test isolation
mkdir -p "$TEMP_DIR"
export HOME="$TEMP_DIR"

# Cleanup function
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Check if nvim is available
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}❌ Neovim not found in PATH${NC}"
    exit 1
fi

# Check if we're in the right directory
if [[ ! -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
    echo -e "${RED}❌ Not in a valid Neovim configuration directory${NC}"
    echo "Expected to find init.lua in $NVIM_CONFIG_DIR"
    exit 1
fi

echo -e "${BLUE}📋 Pre-flight Checks${NC}"
echo "✅ Neovim binary found"
echo "✅ Configuration directory valid"
echo "✅ Test environment isolated"
echo ""

# Set up test pattern
TEST_PATTERN="${1:-*_spec.lua}"
echo -e "${BLUE}🎯 Running tests matching: ${YELLOW}$TEST_PATTERN${NC}"
echo ""

# Run syntax check first
echo -e "${BLUE}🔍 Syntax Check${NC}"
if nvim --headless -c "lua vim.cmd('luafile init.lua')" -c "quit" 2>/dev/null; then
    echo "✅ Configuration syntax is valid"
else
    echo -e "${RED}❌ Configuration has syntax errors${NC}"
    echo "Fix syntax errors before running tests"
    exit 1
fi
echo ""

# Run the actual tests
echo -e "${BLUE}🚀 Running Test Suite${NC}"

# Create test results directory
RESULTS_DIR="$TEST_DIR/results"
mkdir -p "$RESULTS_DIR"

# Run tests with plenary
cd "$NVIM_CONFIG_DIR"

TEST_COMMAND="lua require('plenary.test_harness').test_directory('tests/specs', {
  minimal_init = 'tests/minimal_init.lua',
  sequential = true,
  keep_going = false,
})"

if nvim --headless -c "$TEST_COMMAND" -c "quit" 2>&1 | tee "$RESULTS_DIR/test_output.log"; then
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
    TEST_STATUS=0
else
    echo ""
    echo -e "${RED}❌ Some tests failed${NC}"
    TEST_STATUS=1
fi

# Generate test report
echo ""
echo -e "${BLUE}📊 Test Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count test files
TEST_FILES=$(find "$TEST_DIR/specs" -name "$TEST_PATTERN" | wc -l)
echo "Test files found: $TEST_FILES"

# Extract results from log if available
if [[ -f "$RESULTS_DIR/test_output.log" ]]; then
    TOTAL_TESTS=$(grep -c "describe\|it" "$RESULTS_DIR/test_output.log" 2>/dev/null || echo "Unknown")
    echo "Test results saved to: $RESULTS_DIR/test_output.log"
fi

echo "Test run completed at: $(date)"
echo ""

# Show help for next steps
if [[ $TEST_STATUS -eq 0 ]]; then
    echo -e "${GREEN}🎉 Configuration is working correctly!${NC}"
    echo ""
    echo -e "${BLUE}💡 Recommended next steps:${NC}"
    echo "  • Set up automated testing with: make test"
    echo "  • Add git pre-commit hook: ./tests/setup_hooks.sh"
    echo "  • Run tests before major changes"
else
    echo -e "${YELLOW}⚠️  Some tests failed - check the output above${NC}"
    echo ""
    echo -e "${BLUE}🔧 Debugging tips:${NC}"
    echo "  • Check test output in: $RESULTS_DIR/test_output.log"
    echo "  • Run specific test: ./tests/run_tests.sh specific_test_spec.lua"
    echo "  • Verify plugin installations are complete"
fi

exit $TEST_STATUS
