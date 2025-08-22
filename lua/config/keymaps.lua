-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- JavaScript/TypeScript specific settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>pv', ':Explore<CR>', { desc = 'Open [P]roject [V]iew' })

-- Buffer navigation
vim.keymap.set('n', '<leader>[', '<cmd>bprevious<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<leader>]', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Open hyperlink under cursor with gx
vim.keymap.set('n', 'gx', function()
  local function get_url_under_cursor()
    -- Save cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local col = cursor_pos[2]
    
    -- Pattern to match URLs
    local url_pattern = "https?://[%w-._~:/?#[%]@!$&'()*+,;=%%]+"
    
    -- Find URL containing cursor position
    local start_pos = 1
    while start_pos <= #line do
      local url_start, url_end = string.find(line, url_pattern, start_pos)
      if not url_start then
        break
      end
      
      -- Check if cursor is within this URL (1-indexed to 0-indexed conversion)
      if col >= url_start - 1 and col <= url_end - 1 then
        return string.sub(line, url_start, url_end)
      end
      
      start_pos = url_end + 1
    end
    
    return nil
  end

  local url = get_url_under_cursor()
  if url then
    -- Use appropriate command based on OS
    local open_cmd
    if vim.fn.has('mac') == 1 then
      open_cmd = 'open'
    elseif vim.fn.has('unix') == 1 then
      open_cmd = 'xdg-open'
    elseif vim.fn.has('win32') == 1 then
      open_cmd = 'start'
    else
      vim.notify('Unsupported OS for opening URLs', vim.log.levels.ERROR)
      return
    end
    
    -- Open the URL
    local handle = io.popen(open_cmd .. ' "' .. url .. '"')
    if handle then
      handle:close()
      vim.notify('Opened: ' .. url, vim.log.levels.INFO)
    else
      vim.notify('Failed to open: ' .. url, vim.log.levels.ERROR)
    end
  else
    vim.notify('No URL found under cursor', vim.log.levels.WARN)
  end
end, { desc = 'Open URL under cursor' })
