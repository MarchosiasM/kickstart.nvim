-- Note-taking and knowledge management plugins
-- Organized into: Constants, Templates, Helper Functions, Keymaps, and Plugin Configs

-- ============================================================================
-- CONSTANTS
-- ============================================================================
local ZETTEL_HOME = vim.fn.expand("~/Documents/Notes/zettelkasten")
local ZETTEL_DAILIES = ZETTEL_HOME .. "/daily"
local ZETTEL_WEEKLIES = ZETTEL_HOME .. "/weekly"
local ZETTEL_TEMPLATES = ZETTEL_HOME .. "/.telekasten/templates"
local NOTE_EXTENSION = ".md"

-- ============================================================================
-- TEMPLATES
-- ============================================================================
local templates = {
  new_note = [[
# {{title}}

Date: {{date}}
Tags: #

## Content

{{cursor}}

## Links
- 

## References
- 
]],

  daily = [[
# Daily Note - {{date}}

## Today's Focus
- 

## Tasks
- [ ] 

## Notes
{{cursor}}

## Reflections
- 

## Tomorrow
- 

#daily
]],

  weekly = [[
# Week {{week}} - {{date}}

## Week Overview
{{cursor}}

## Goals Achieved
- 

## Challenges
- 

## Next Week
- 

#weekly
]],

  person = [[
# {{title}}

## Background
- Location: 
- Personal: 
- Previous experience: 

## Professional
- Role: 
- Team: 
- Expertise: 
- Years at company: 

## Personal Details
- Family: 
- Interests: 
- Fun facts: {{cursor}}

## Interactions
### {{date}} - First meeting
- 

## Related Notes
- 

## Action Items
- [ ] 

#people #team
]]
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
local function ensure_telescope()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if not ok then
    vim.notify('Telescope not available', vim.log.levels.ERROR)
    return nil
  end
  return builtin
end

local function get_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  
  -- Look for [[Link Name]] pattern
  local start_pos = line:find('%[%[', 1)
  while start_pos do
    local end_pos = line:find('%]%]', start_pos)
    if end_pos and col >= start_pos - 1 and col <= end_pos then
      -- Cursor is within this link
      return line:sub(start_pos + 2, end_pos - 1)
    end
    start_pos = line:find('%[%[', end_pos or start_pos + 1)
  end
  return nil
end

local function create_person_note(name)
  local telekasten = require('telekasten')
  local template = telekasten.Cfg.template_coworker
  local filepath = ZETTEL_HOME .. '/' .. name .. NOTE_EXTENSION
  
  -- Check if file already exists
  if vim.fn.filereadable(filepath) == 1 then
    vim.cmd('edit ' .. filepath)
    vim.notify('Opened existing note for ' .. name, vim.log.levels.INFO)
    return
  end
  
  if not template then
    vim.notify('Person template not found', vim.log.levels.ERROR)
    return
  end
  
  -- Create new note with template
  vim.cmd('edit ' .. filepath)
  
  -- Substitute template variables
  local today = os.date('%Y-%m-%d')
  local lines = vim.split(template, '\n')
  
  for i, line in ipairs(lines) do
    lines[i] = line:gsub('{{title}}', name)
                  :gsub('{{date}}', today)
                  :gsub('{{cursor}}', '')
  end
  
  -- Insert template content
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  
  -- Find cursor position (after "Fun facts:")
  for i, line in ipairs(lines) do
    if line:match('Fun facts:') then
      vim.api.nvim_win_set_cursor(0, {i, #line})
      break
    end
  end
  
  -- Save the file
  vim.cmd('write')
  vim.notify('Created new note for ' .. name, vim.log.levels.INFO)
end

local function create_clean_daily_note()
  local telekasten = require('telekasten')
  local today = os.date('%Y-%m-%d')
  local daily_path = ZETTEL_DAILIES .. '/' .. today .. NOTE_EXTENSION
  
  vim.cmd('edit ' .. daily_path)
  local template = telekasten.Cfg.template_new_daily
  if template then
    local lines = vim.split(template, '\n')
    for i, line in ipairs(lines) do
      lines[i] = line:gsub('{{date}}', today):gsub('{{cursor}}', '')
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    
    -- Position cursor in Notes section
    for i, line in ipairs(lines) do
      if line == '' and lines[i-1] and lines[i-1]:match('Notes') then
        vim.api.nvim_win_set_cursor(0, {i, 0})
        break
      end
    end
  end
  vim.notify("Created clean daily note (no rollover)", vim.log.levels.INFO)
end

-- ============================================================================
-- KEYMAPS SETUP
-- ============================================================================
local function setup_keymaps()
  local map = vim.keymap.set
  
  -- ============================
  -- Core Note Management
  -- ============================
  map('n', '<leader>zz', '<cmd>Telekasten panel<CR>', 
    { desc = '[Z]ettelkasten panel' })
  
  map('n', '<leader>zn', '<cmd>Telekasten new_note<CR>', 
    { desc = '[Z]ettelkasten [N]ew note' })
  
  map('n', '<leader>zt', '<cmd>Telekasten toggle_todo<CR>', 
    { desc = '[Z]ettelkasten [T]oggle todo' })
  
  -- ============================
  -- Search and Discovery  
  -- ============================
  map('n', '<leader>zf', function()
    local builtin = ensure_telescope()
    if builtin then
      builtin.find_files({
        prompt_title = 'Find Zettelkasten Notes',
        cwd = ZETTEL_HOME,
        search_dirs = { ZETTEL_HOME },
      })
    end
  end, { desc = '[Z]ettelkasten [F]ind notes' })
  
  map('n', '<leader>zg', function()
    local builtin = ensure_telescope()
    if not builtin then return end
    
    -- Check if ripgrep is available
    if vim.fn.executable('rg') == 0 then
      vim.notify('ripgrep (rg) not found. Install with: brew install ripgrep', vim.log.levels.WARN)
      builtin.grep_string({
        prompt_title = 'Search Zettelkasten Notes (fallback)',
        cwd = ZETTEL_HOME,
        search_dirs = { ZETTEL_HOME },
      })
      return
    end
    
    builtin.live_grep({
      prompt_title = 'Search Zettelkasten Notes',
      cwd = ZETTEL_HOME,
      search_dirs = { ZETTEL_HOME },
    })
  end, { desc = '[Z]ettelkasten [G]rep notes' })
  
  -- ============================
  -- Daily Notes
  -- ============================
  map('n', '<leader>zd', function()
    local telekasten = require('telekasten')
    local today = os.date('%Y-%m-%d')
    local daily_path = ZETTEL_DAILIES .. '/' .. today .. NOTE_EXTENSION
    
    if vim.fn.filereadable(daily_path) == 1 then
      telekasten.goto_today()
    else
      local rollover = require('zettelkasten.daily-task-rollover')
      rollover.create_daily_with_rollover()
    end
  end, { desc = '[Z]ettelkasten [D]aily note with automatic rollover' })
  
  map('n', '<leader>zdc', create_clean_daily_note, 
    { desc = '[Z]ettelkasten [D]aily [C]lean note (no rollover)' })
  
  map('n', '<leader>zdr', function()
    vim.ui.input({prompt = 'Roll over tasks from date (YYYY-MM-DD): '}, function(date)
      if date and date ~= '' then
        local rollover = require('zettelkasten.daily-task-rollover')
        rollover.manual_rollover(date)
      end
    end)
  end, { desc = '[Z]ettelkasten [D]aily [R]ollover from specific date' })
  
  map('n', '<leader>zw', '<cmd>Telekasten goto_thisweek<CR>', 
    { desc = '[Z]ettelkasten [W]eekly note' })
  
  -- ============================
  -- Person Notes (Smart)
  -- ============================
  map('n', '<leader>zp', function()
    local link_name = get_link_under_cursor()
    
    if link_name then
      create_person_note(link_name)
    else
      vim.ui.input({ prompt = 'Coworker name: ' }, function(name)
        if name and name ~= '' then
          create_person_note(name)
        end
      end)
    end
  end, { desc = '[Z]ettelkasten [P]erson/coworker note' })
  
  -- ============================
  -- Linking and Navigation
  -- ============================
  map('n', '<leader>zl', '<cmd>Telekasten insert_link<CR>', 
    { desc = '[Z]ettelkasten insert [L]ink' })
  
  map('n', '<CR>', '<cmd>Telekasten follow_link<CR>', 
    { desc = 'Follow zettel link' })
  
  map('n', '<leader>zj', '<cmd>Telekasten follow_link<CR>', 
    { desc = '[Z]ettelkasten [J]ump to link' })
  
  -- Enhanced link creation from selection
  map('v', '<leader>z[', function()
    vim.cmd('normal! y')
    local selected_text = vim.fn.getreg('"'):gsub("^%s*(.-)%s*$", "%1")
    vim.cmd('normal! c[[' .. selected_text .. ']]')
  end, { desc = "Wrap selection in [[]] (zettelkasten link)" })
  
  -- Quick link creation shortcuts
  map('n', '<leader>zw1', function()
    local word = vim.fn.expand('<cword>')
    if word and word ~= '' then
      vim.cmd("normal! ciw[[" .. word .. "]]")
    end
  end, { desc = "Wrap word under cursor in [[]]" })
  
  map('n', '<leader>z2', function()
    vim.cmd('normal! v2ey')
    local selected_text = vim.fn.getreg('"'):gsub("^%s*(.-)%s*$", "%1")
    vim.cmd('normal! gvc[[' .. selected_text .. ']]')
  end, { desc = "Wrap 2 words starting from cursor in [[]]" })
  
  -- ============================
  -- Enhanced Features
  -- ============================
  map('n', '<leader>zb', function()
    require('zettelkasten.better-backlinks').show_backlinks()
  end, { desc = '[Z]ettelkasten [B]acklinks (enhanced)' })
  
  map('n', '<leader>zB', function()
    require('zettelkasten.better-backlinks').browse_backlinks()
  end, { desc = '[Z]ettelkasten [B]rowse backlinks (interactive)' })
  
  map('n', '<leader>z#', function()
    require('zettelkasten.better-tags').show_tags()
  end, { desc = '[Z]ettelkasten show tags (enhanced)' })
  
  map('n', '<leader>zT', function()
    require('zettelkasten.better-tags').search_by_tag()
  end, { desc = '[Z]ettelkasten search by [T]ag' })
  
  -- ============================
  -- Utilities
  -- ============================
  map('n', '<leader>zi', '<cmd>Telekasten paste_img_and_link<CR>', 
    { desc = '[Z]ettelkasten [I]nsert image' })
  
  map('n', '<leader>zc', '<cmd>Telekasten show_calendar<CR>', 
    { desc = '[Z]ettelkasten [C]alendar' })
  
  -- ============================
  -- Fallback Commands
  -- ============================
  map('n', '<leader>zbo', '<cmd>Telekasten show_backlinks<CR>', 
    { desc = '[Z]ettelkasten [B]acklinks (original)' })
  
  map('n', '<leader>z#o', '<cmd>Telekasten show_tags<CR>', 
    { desc = '[Z]ettelkasten show tags (original)' })
end

-- ============================================================================
-- PLUGIN CONFIGURATION
-- ============================================================================
return {
  -- Telekasten: Main Zettelkasten plugin
  {
    'renerocksai/telekasten.nvim',
    branch = 'main',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    opts = {
      home = ZETTEL_HOME,
      dailies = ZETTEL_DAILIES,
      weeklies = ZETTEL_WEEKLIES,
      templates = ZETTEL_TEMPLATES,
      extension = NOTE_EXTENSION,
      
      -- Templates
      template_new_note = templates.new_note,
      template_new_daily = templates.daily,
      template_new_weekly = templates.weekly,
      template_coworker = templates.person,
      
      -- Link behavior
      follow_creates_nonexisting = true,
      dailies_create_nonexisting = true,
      weeklies_create_nonexisting = true,
      subdirs_in_links = true,
      
      -- Image handling
      image_subdir = "img",
      
      -- Calendar integration
      plug_into_calendar = true,
      calendar_monday = 1,
      calendar_opts = {
        weekdayHeader = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"},
        calendar_monday = 1,
        calendar_mark = "left-fit",
      },
      
      -- Tag notation
      tag_notation = "#tag",
    },
    
    config = function(_, opts)
      require('telekasten').setup(opts)
      
      -- Create directories
      local dirs = { opts.home, opts.dailies, opts.weeklies, opts.templates }
      for _, dir in ipairs(dirs) do
        vim.fn.mkdir(dir, "p")
      end
      
      -- Setup all keymaps
      setup_keymaps()
    end,
  },

  -- Calendar integration
  {
    'renerocksai/calendar-vim',
    cmd = { 'Calendar', 'CalendarVR' },
    config = function()
      vim.g.calendar_monday = 1
      vim.g.calendar_weeknm = 1
      vim.g.calendar_mark = 'left-fit'
    end,
  },

  -- Markdown rendering
  {
    'MeanderingProgrammer/render-markdown.nvim',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.treesitter.language.register('markdown', 'telekasten')
      
      require('render-markdown').setup({
        enabled = true,
        latex = { enabled = false },
        yaml = { enabled = false },
        file_types = { 'markdown', 'md', 'telekasten' },
        heading = {
          icons = { '● ', '○ ', '▸ ', '▹ ', '▪ ', '▫ ' },
        },
        bullet = {
          icons = { '•', '◦', '▸', '▹' },
        },
        checkbox = {
          unchecked = { icon = '[ ]' },
          checked = { icon = '[x]' },
        },
        link = {
          enabled = true,
          wiki = { icon = '🔗 ' },
        },
        wiki_link = {
          enabled = true,
          icon = '🔗 ',
        },
      })
      
      -- Enable for telekasten filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "telekasten",
        callback = function()
          vim.schedule(function()
            local rm_ok, rm = pcall(require, 'render-markdown')
            if rm_ok and rm.enable then
              rm.enable()
            end
          end)
        end,
        desc = "Enable render-markdown for telekasten filetype"
      })
    end,
  },

  -- Enhanced markdown support
  {
    'ixru/nvim-markdown',
    ft = { 'markdown', 'telekasten' },
    config = function()
      -- Basic configuration
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_no_default_key_mappings = 0
      vim.g.vim_markdown_auto_insert_bullets = 1
      vim.g.vim_markdown_new_list_item_indent = 2
      
      -- Custom URL opening for markdown files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'markdown', 'telekasten' },
        callback = function()
          vim.keymap.set('n', 'gx', function()
            local function get_url_under_cursor()
              local cursor_pos = vim.api.nvim_win_get_cursor(0)
              local line = vim.api.nvim_get_current_line()
              local col = cursor_pos[2]
              local url_pattern = "https?://[%w-._~:/?#[%]@!$&'()*+,;=%%]+"
              local start_pos = 1
              
              while start_pos <= #line do
                local url_start, url_end = string.find(line, url_pattern, start_pos)
                if not url_start then break end
                if col >= url_start - 1 and col <= url_end - 1 then
                  return string.sub(line, url_start, url_end)
                end
                start_pos = url_end + 1
              end
              return nil
            end

            local url = get_url_under_cursor()
            if url then
              local open_cmd = vim.fn.has('mac') == 1 and 'open' or 'xdg-open'
              os.execute(open_cmd .. ' "' .. url .. '"')
              vim.notify('Opened: ' .. url)
            else
              vim.notify('No URL found under cursor', vim.log.levels.WARN)
            end
          end, { buffer = 0, desc = 'Open URL under cursor' })
        end
      })
    end,
  },
}