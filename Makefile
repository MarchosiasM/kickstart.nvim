# Makefile for Neovim Configuration
# Provides easy commands for testing and maintenance

.PHONY: test test-keymaps test-scripts test-integration lint install-hooks help

# Default target
help:
	@echo "🛠️  Neovim Configuration Management"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "Available commands:"
	@echo "  make test           - Run all tests"
	@echo "  make test-keymaps   - Test zettelkasten keymaps only"
	@echo "  make test-scripts   - Test custom Lua scripts only"
	@echo "  make test-integration - Test Telekasten integration only"
	@echo "  make lint           - Check configuration syntax"
	@echo "  make install-hooks  - Set up git pre-commit hooks"
	@echo "  make clean          - Clean test artifacts"
	@echo "  make help           - Show this help"
	@echo ""

# Run all tests
test:
	@echo "🧪 Running full test suite..."
	@./tests/run_tests.sh

# Run specific test categories
test-keymaps:
	@echo "⌨️  Testing zettelkasten keymaps..."
	@./tests/run_tests.sh "*keymaps*"

test-scripts:
	@echo "📜 Testing custom Lua scripts..."
	@./tests/run_tests.sh "*rollover*|*tags*|*backlinks*"

test-integration:
	@echo "🔗 Testing Telekasten integration..."
	@./tests/run_tests.sh "*telekasten*"

# Syntax checking
lint:
	@echo "🔍 Checking configuration syntax..."
	@nvim --headless -c "lua vim.cmd('luafile init.lua')" -c "quit" 2>/dev/null && \
		echo "✅ Configuration syntax is valid" || \
		(echo "❌ Configuration has syntax errors"; exit 1)

# Install git hooks for automated testing
install-hooks:
	@echo "🪝 Installing git pre-commit hooks..."
	@./tests/setup_hooks.sh

# Clean test artifacts
clean:
	@echo "🧹 Cleaning test artifacts..."
	@rm -rf tests/results/
	@rm -rf /tmp/nvim_test_*
	@rm -rf /tmp/nvim_config_test_*
	@echo "✅ Cleanup complete"

# Quick verification that everything is working
verify:
	@echo "✅ Running quick verification..."
	@make lint
	@echo "✅ Basic functionality verified"

# Development workflow - run before committing
pre-commit: lint test
	@echo "🚀 Pre-commit checks complete!"

# CI-style testing (useful for automation)
ci:
	@echo "🤖 Running CI-style tests..."
	@make lint
	@make test
	@echo "🎉 All CI checks passed!"
