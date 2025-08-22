-- Minimal init for testing
-- Only load essential plugins and configurations for testing

-- Add lazy.nvim to runtime path
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set up leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Minimal plugin setup for testing
require('lazy').setup({
  {
    'nvim-lua/plenary.nvim',
  },
  {
    'renerocksai/telekasten.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      -- Load our notes configuration
      require('plugins.notes')
    end,
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Load our UI configuration  
      require('plugins.ui')
    end,
  },
}, {
  -- Disable change detection for tests
  checker = { enabled = false },
  change_detection = { enabled = false },
})

-- Test-specific settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Set up temporary directories for testing
local test_dir = '/tmp/nvim_config_tests'
vim.fn.mkdir(test_dir, 'p')
vim.env.HOME = test_dir
