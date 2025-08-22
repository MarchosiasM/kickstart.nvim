-- [[ Setting options ]]
-- See `:help vim.o` and `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Suppress deprecation warnings from third-party plugins
-- These plugins haven't updated to Neovim 1.0 APIs yet, but functionality still works
-- Remove this section once plugins are updated (likely mid-2025)
local function suppress_plugin_warnings()
  -- Save original vim.deprecate function
  if not vim._deprecate_original then
    vim._deprecate_original = vim.deprecate
  end
  
  -- Override vim.deprecate to filter plugin warnings
  vim.deprecate = function(name, alternative, version, plugin, backtrace)
    -- List of plugin paths to suppress warnings for
    local suppress_patterns = {
      '/lazy/nvim%-notify/',
      '/lazy/telescope%.nvim/',
      '/lazy/telekasten%.nvim/', 
      '/lazy/which%-key%.nvim/',
      '/lazy/mini%.nvim/',
    }
    
    -- Check if this warning is from a plugin we want to suppress
    if backtrace then
      for _, pattern in ipairs(suppress_patterns) do
        if backtrace:match(pattern) then
          return -- Suppress this warning
        end
      end
    end
    
    -- Show warnings for our own code
    return vim._deprecate_original(name, alternative, version, plugin, backtrace)
  end
end

-- Apply the suppression
suppress_plugin_warnings()

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Keep as vim.opt for table value

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- No exports needed currently
-- return {}
