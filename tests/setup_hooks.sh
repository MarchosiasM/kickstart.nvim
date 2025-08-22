#!/bin/bash

# Setup git hooks for automated testing
# This script installs pre-commit hooks to run tests automatically

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NVIM_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GIT_HOOKS_DIR="$NVIM_CONFIG_DIR/.git/hooks"

echo -e "${BLUE}🪝 Setting up git hooks for Neovim configuration${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if we're in a git repository
if [[ ! -d "$NVIM_CONFIG_DIR/.git" ]]; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    echo "Git hooks can only be installed in a git repository."
    echo "Run 'git init' first if you want to set up version control."
    exit 1
fi

echo "Config Directory: $NVIM_CONFIG_DIR"
echo "Git Hooks Directory: $GIT_HOOKS_DIR"
echo ""

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Create pre-commit hook
PRE_COMMIT_HOOK="$GIT_HOOKS_DIR/pre-commit"

echo -e "${BLUE}📝 Creating pre-commit hook...${NC}"

cat > "$PRE_COMMIT_HOOK" << 'EOF'
#!/bin/bash

# Pre-commit hook for Neovim configuration
# Runs syntax check and critical tests before allowing commit

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Running pre-commit checks...${NC}"

# Get the directory of this git repository
REPO_ROOT=$(git rev-parse --show-toplevel)

# Check if this is a Neovim config repository
if [[ ! -f "$REPO_ROOT/init.lua" ]]; then
    echo -e "${YELLOW}⚠️  Not a Neovim configuration repository, skipping checks${NC}"
    exit 0
fi

cd "$REPO_ROOT"

# 1. Syntax check
echo "Checking configuration syntax..."
if ! nvim --headless -c "lua vim.cmd('luafile init.lua')" -c "quit" 2>/dev/null; then
    echo -e "${RED}❌ Configuration has syntax errors${NC}"
    echo "Fix syntax errors before committing"
    exit 1
fi
echo "✅ Syntax check passed"

# 2. Quick test of critical functionality
echo "Running critical tests..."
if [[ -f "tests/run_tests.sh" ]]; then
    # Run only the most critical tests to keep pre-commit fast
    if ! ./tests/run_tests.sh "*keymaps*" >/dev/null 2>&1; then
        echo -e "${RED}❌ Critical keymap tests failed${NC}"
        echo "Run 'make test' to see detailed results"
        exit 1
    fi
    echo "✅ Critical tests passed"
else
    echo -e "${YELLOW}⚠️  No test suite found, skipping tests${NC}"
fi

# 3. Check for common issues
echo "Checking for common issues..."

# Check for hardcoded paths that might not work on other systems
if grep -r "\/Users\/" lua/ 2>/dev/null | grep -v "test" | grep -v "spec"; then
    echo -e "${YELLOW}⚠️  Found hardcoded paths in configuration${NC}"
    echo "Consider using vim.fn.expand('~') instead"
fi

# Check for debugging code left in
if grep -r "print(" lua/ 2>/dev/null | grep -v "test" | grep -v "spec"; then
    echo -e "${YELLOW}⚠️  Found print() statements in configuration${NC}"
    echo "Consider removing debugging code or using vim.notify()"
fi

echo "✅ Pre-commit checks completed successfully"
echo ""
EOF

# Make pre-commit hook executable
chmod +x "$PRE_COMMIT_HOOK"
echo "✅ Pre-commit hook created and made executable"

# Create commit-msg hook for conventional commits
COMMIT_MSG_HOOK="$GIT_HOOKS_DIR/commit-msg"

echo -e "${BLUE}📝 Creating commit-msg hook...${NC}"

cat > "$COMMIT_MSG_HOOK" << 'EOF'
#!/bin/bash

# Commit message hook to encourage conventional commits
# Helps maintain a clean git history

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "🚨 Commit message doesn't follow conventional commit format!"
    echo ""
    echo "Expected format: <type>(<scope>): <description>"
    echo ""
    echo "Types:"
    echo "  feat     - New feature"
    echo "  fix      - Bug fix"
    echo "  docs     - Documentation changes"
    echo "  style    - Code style changes (formatting, etc.)"
    echo "  refactor - Code refactoring"
    echo "  test     - Adding or updating tests"
    echo "  chore    - Maintenance tasks"
    echo ""
    echo "Examples:"
    echo "  feat(zettelkasten): add automatic task rollover"
    echo "  fix(keymaps): resolve surround bracket issue"
    echo "  test: add comprehensive keymap test suite"
    echo ""
    echo "Your commit message:"
    echo "  $(cat $1)"
    echo ""
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! $response =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
EOF

chmod +x "$COMMIT_MSG_HOOK"
echo "✅ Commit message hook created and made executable"

# Create a test script to verify hooks work
echo -e "${BLUE}🧪 Creating hook test script...${NC}"

cat > "$NVIM_CONFIG_DIR/tests/test_hooks.sh" << 'EOF'
#!/bin/bash

# Test script to verify git hooks are working correctly

echo "🧪 Testing git hooks..."

# Test pre-commit hook
echo "Testing pre-commit hook..."
if [[ -x ".git/hooks/pre-commit" ]]; then
    echo "✅ Pre-commit hook is executable"
else
    echo "❌ Pre-commit hook not found or not executable"
    exit 1
fi

# Test commit-msg hook
echo "Testing commit-msg hook..."
if [[ -x ".git/hooks/commit-msg" ]]; then
    echo "✅ Commit-msg hook is executable"
else
    echo "❌ Commit-msg hook not found or not executable"
    exit 1
fi

echo "🎉 All hooks are properly installed!"
EOF

chmod +x "$NVIM_CONFIG_DIR/tests/test_hooks.sh"

echo ""
echo -e "${GREEN}🎉 Git hooks successfully installed!${NC}"
echo ""
echo -e "${BLUE}📋 What was installed:${NC}"
echo "  ✅ Pre-commit hook - Runs syntax check and critical tests"
echo "  ✅ Commit-msg hook - Encourages conventional commit format"
echo "  ✅ Hook test script - Verify hooks are working"
echo ""
echo -e "${BLUE}💡 How to use:${NC}"
echo "  • Hooks run automatically on git commit"
echo "  • Test hooks: ./tests/test_hooks.sh"
echo "  • Bypass hooks: git commit --no-verify (use sparingly)"
echo "  • Manual test run: make test"
echo ""
echo -e "${BLUE}🔧 Customization:${NC}"
echo "  • Edit hooks in: $GIT_HOOKS_DIR/"
echo "  • Disable by removing execute permission"
echo "  • Configure in your git settings"
