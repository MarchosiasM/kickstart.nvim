-- Editor enhancement plugins
return {
  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- Beautiful notification system
  {
    'rcarriga/nvim-notify',
    opts = {
      -- Remove background_colour to prevent color interference
      render = "wrapped-compact",
      timeout = 3000,
      stages = "fade_in_slide_out",
    },
    config = function(_, opts)
      local notify = require('notify')
      notify.setup(opts)
      -- Set as default notification handler
      vim.notify = notify
    end,
  },

  -- Smooth cursor animations
  {
    'sphamba/smear-cursor.nvim',
    opts = {},
  },

  -- Browser integration
  {
    'glacambre/firenvim',
    cond = function()
      return not vim.g.vscode
    end, -- Only load when not loaded through vscode
    build = ':call firenvim#install(0)',
  },

  -- Code formatting
  {
    'sbdchd/neoformat',
    cond = function()
      return not vim.g.vscode
    end, -- Only load when not loaded through vscode
  },

  -- Vim training helper
  {
    'm4xshen/hardtime.nvim',
    lazy = false,
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      -- Now uses nvim-notify for beautiful notifications!
      notification = true,
      allow_different_key = false,
      -- You can add other customizations here:
      -- disabled_filetypes = { "qf", "netrw", "NvimTree", "lazy", "mason" },
      -- max_time = 1000,  -- Time in ms after which hardtime kicks in
      -- max_count = 3,    -- Max repetitions before restriction
    },
  },

  -- Todo comment highlighting
  { 
    'folke/todo-comments.nvim', 
    event = 'VimEnter', 
    dependencies = { 'nvim-lua/plenary.nvim' }, 
    opts = { signs = false } 
  },
}
