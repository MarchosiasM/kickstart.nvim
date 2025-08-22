-- Test Runner for Neovim Configuration
-- Run with: nvim --headless -c "luafile tests/test_runner.lua" -c "quit"

local plenary_path = vim.fn.stdpath('data') .. '/lazy/plenary.nvim'
vim.opt.rtp:prepend(plenary_path)

-- Set up test environment
require('plenary.test_harness').test_directory('tests/specs', {
  minimal_init = 'tests/minimal_init.lua',
  sequential = true,
})
