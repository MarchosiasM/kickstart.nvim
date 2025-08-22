# 🧪 Neovim Configuration Test Suite

A comprehensive testing framework to ensure your custom zettelkasten workflow continues working as expected.

## 📋 Overview

This test suite covers:
- ✅ **Zettelkasten keymaps** (`<leader>z2`, `<leader>zw`, etc.)
- ✅ **Custom Lua scripts** (task rollover, better tags, better backlinks)  
- ✅ **Telekasten integration** (templates, configuration)
- ✅ **Plugin configurations** (mini.surround, calendar.vim)
- ✅ **File operations** (note creation, template application)

## 🚀 Quick Start

### Run All Tests
```bash
# Using make (recommended)
make test

# Or directly
./tests/run_tests.sh
```

### Run Specific Test Categories
```bash
make test-keymaps      # Test zettelkasten keymaps only
make test-scripts      # Test custom Lua scripts only  
make test-integration  # Test Telekasten integration only
```

### Just Check Syntax
```bash
make lint
```

## 🛠️ Setting Up Automated Testing

### Install Git Hooks (Recommended)
```bash
# Install pre-commit hooks
make install-hooks

# Or directly
./tests/setup_hooks.sh
```

This will:
- ✅ Run syntax checks before each commit
- ✅ Run critical tests to catch breaking changes
- ✅ Encourage conventional commit messages
- ✅ Prevent commits that break core functionality

### Test Before Major Changes
```bash
# Full pre-commit workflow
make pre-commit

# Quick verification
make verify
```

## 📁 Test Structure

```
tests/
├── README.md                    # This file
├── run_tests.sh                 # Main test runner
├── setup_hooks.sh               # Git hooks installer
├── test_runner.lua              # Plenary test harness setup
├── minimal_init.lua             # Minimal config for testing
└── specs/                       # Test specifications
    ├── zettelkasten_keymaps_spec.lua      # Keymap tests
    ├── daily_task_rollover_spec.lua       # Task rollover tests
    ├── better_tags_spec.lua               # Tag functionality tests
    ├── better_backlinks_spec.lua          # Backlinks tests
    └── telekasten_integration_spec.lua    # Integration tests
```

## 🧩 Test Categories

### 1. Keymap Tests (`zettelkasten_keymaps_spec.lua`)
Tests your custom zettelkasten keymaps:
- `<leader>z2` - 2-word zettelkasten links
- `<leader>zw` - Single word links  
- `<leader>z[` - Visual selection links
- Ensures no extra spaces or characters

### 2. Task Rollover Tests (`daily_task_rollover_spec.lua`)
Tests the automatic task rollover system:
- Finding yesterday's notes
- Extracting incomplete tasks
- Extracting tomorrow items
- Creating new daily notes with rollover

### 3. Tag System Tests (`better_tags_spec.lua`)
Tests the enhanced tag browsing:
- Scanning for tags across notes
- Counting tag occurrences
- File location tracking
- Floating window creation

### 4. Backlinks Tests (`better_backlinks_spec.lua`)
Tests the improved backlinks system:
- Finding notes that link to current note
- Counting multiple references
- Handling notes with no backlinks
- Interactive backlinks viewer

### 5. Integration Tests (`telekasten_integration_spec.lua`)
Tests Telekasten plugin integration:
- Template system functionality
- Directory structure creation
- Calendar integration
- Configuration loading

## 🔧 Writing New Tests

### Basic Test Structure
```lua
local assert = require('luassert')

describe('Feature Name', function()
  before_each(function()
    -- Setup test environment
  end)

  after_each(function()
    -- Cleanup
  end)

  describe('Sub-feature', function()
    it('should do something specific', function()
      -- Test implementation
      assert.equals(expected, actual)
    end)
  end)
end)
```

### Common Patterns

#### Testing Keymaps
```lua
local keymaps = vim.api.nvim_get_keymap('n')
for _, map in ipairs(keymaps) do
  if map.lhs == '<leader>z2' and map.callback then
    map.callback()
    break
  end
end
```

#### Mocking File Paths
```lua
local original_expand = vim.fn.expand
vim.fn.expand = function(path)
  if path:match('~/Documents/Notes/zettelkasten') then
    return '/tmp/test_zettelkasten'
  end
  return original_expand(path)
end
-- Restore after test
vim.fn.expand = original_expand
```

#### Testing Buffer Content
```lua
vim.api.nvim_buf_set_lines(0, 0, -1, false, {'line 1', 'line 2'})
local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
assert.match('expected pattern', lines[1])
```

## 📊 Test Results

### Interpreting Output
- ✅ **Green** - Tests passed
- ❌ **Red** - Tests failed  
- ⚠️ **Yellow** - Warnings or skipped tests

### Common Failure Reasons
1. **Plugin not loaded** - Restart Neovim or check plugin config
2. **File path issues** - Check zettelkasten directory paths
3. **Keymap conflicts** - Verify keymaps are properly set
4. **Template missing** - Ensure templates exist in `.telekasten/templates/`

## 🐛 Debugging Failed Tests

### Check Test Logs
```bash
# Test output is saved to:
cat tests/results/test_output.log
```

### Run Individual Tests
```bash
# Run specific test file
./tests/run_tests.sh "keymap*"

# Run with more verbose output
nvim --headless -c "lua require('plenary.test_harness').test_directory('tests/specs/zettelkasten_keymaps_spec.lua')" -c "quit"
```

### Manual Testing
```bash
# Test configuration syntax
make lint

# Test specific functionality manually
nvim ~/Documents/Notes/zettelkasten/
# Try <leader>z2 on some text
```

## 🔄 Continuous Integration

### GitHub Actions Example
```yaml
# .github/workflows/test.yml
name: Test Neovim Configuration
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Neovim
        run: sudo apt-get install neovim
      - name: Run tests
        run: make ci
```

### Local Pre-commit Workflow
```bash
# Before every commit
make pre-commit

# Quick check before pushing
make verify
```

## 🎯 Best Practices

1. **Run tests frequently** - Catch issues early
2. **Write tests for new features** - Maintain coverage
3. **Use meaningful test names** - Easy debugging
4. **Keep tests isolated** - No dependencies between tests
5. **Mock external dependencies** - Reliable test results

## 🆘 Getting Help

### Common Issues
- **Tests hang** - Check for infinite loops in config
- **Plugin errors** - Verify all plugins are installed
- **Path issues** - Check zettelkasten directory exists
- **Permission errors** - Ensure test directories are writable

### Support Resources  
- Test output logs in `tests/results/`
- Individual test files for specific issues
- Configuration backup in `init_backup.lua`
- Make commands for common workflows

## 🎉 Success!

When all tests pass, you can be confident that:
- ✅ Your zettelkasten workflow is intact
- ✅ All custom keymaps work correctly  
- ✅ Task rollover functions properly
- ✅ Tag and backlink systems are operational
- ✅ Templates and integrations work
- ✅ Future changes won't break existing functionality

**Happy note-taking!** 📝✨
