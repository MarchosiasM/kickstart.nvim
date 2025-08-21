-- Note-taking and knowledge management plugins
return {
  -- Telekasten: Zettelkasten note-taking system
  {
    'renerocksai/telekasten.nvim',
    branch = 'main', -- Use latest main branch for bug fixes
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    opts = {
      home = vim.fn.expand("~/zettelkasten"), -- Your notes directory
      dailies = vim.fn.expand("~/zettelkasten/daily"), -- Daily notes
      weeklies = vim.fn.expand("~/zettelkasten/weekly"), -- Weekly notes
      templates = vim.fn.expand("~/zettelkasten/templates"), -- Templates

      -- File extension for notes
      extension = ".md",

      -- Note templates (inline - required for variable substitution)
      template_new_note = [[
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

      template_new_daily = [[
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

      template_new_weekly = [[
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

      template_coworker = "# {{title}}\n\n## Background\n- Location: \n- Personal: \n- Previous experience: \n\n## Professional\n- Role: \n- Team: \n- Expertise: \n- Years at company: \n\n## Personal Details\n- Family: \n- Interests: \n- Fun facts: {{cursor}}\n\n## Interactions\n### {{date}} - First meeting\n- \n\n## Related Notes\n- [[Pharmacy Engineering Team]]\n- \n\n## Action Items\n- [ ] \n\n#people #team #pharmacy-eng",

      -- Configure how links work
      follow_creates_nonexisting = true, -- Create note when following non-existing link
      dailies_create_nonexisting = true,
      weeklies_create_nonexisting = true,

      -- Image handling (optional)
      image_subdir = "img",
      
      -- Calendar integration
      calendar_monday = 1,

      -- Tag notation
      tag_notation = "#tag",
      
      -- Subdirs in templates (optional)
      subdirs_in_links = true,
    },
    
    config = function(_, opts)
      require('telekasten').setup(opts)
      
      -- Create the directories if they don't exist
      vim.fn.mkdir(opts.home, "p")
      vim.fn.mkdir(opts.dailies, "p")
      vim.fn.mkdir(opts.weeklies, "p")
      vim.fn.mkdir(opts.templates, "p")
      
      -- Key mappings for zettelkasten
      local map = vim.keymap.set
      
      -- Note management
      map('n', '<leader>zf', '<cmd>Telekasten find_notes<CR>', { desc = '[Z]ettelkasten [F]ind notes' })
      map('n', '<leader>zg', '<cmd>Telekasten search_notes<CR>', { desc = '[Z]ettelkasten [G]rep notes' })
      map('n', '<leader>zn', '<cmd>Telekasten new_note<CR>', { desc = '[Z]ettelkasten [N]ew note' })
      map('n', '<leader>zz', '<cmd>Telekasten panel<CR>', { desc = '[Z]ettelkasten panel' })
      map('n', '<leader>zt', '<cmd>Telekasten toggle_todo<CR>', { desc = '[Z]ettelkasten [T]oggle todo' })
      
      -- Coworker note template
      map('n', '<leader>zp', function()
        vim.ui.input({ prompt = 'Coworker name: ' }, function(name)
          if name and name ~= '' then
            local telekasten = require('telekasten')
            local template = telekasten.Cfg.template_coworker
            local filepath = telekasten.Cfg.home .. '/' .. name .. telekasten.Cfg.extension
            
            -- Check if file already exists
            if vim.fn.filereadable(filepath) == 1 then
              -- File exists, just open it
              vim.cmd('edit ' .. filepath)
              vim.notify('Opened existing note for ' .. name, vim.log.levels.INFO)
            elseif template then
              -- Create new note with template
              vim.cmd('edit ' .. filepath)
              
              -- Substitute template variables
              local today = os.date('%Y-%m-%d')
              local lines = vim.split(template, '\n')
              
              for i, line in ipairs(lines) do
                lines[i] = line:gsub('{{title}}', name)
                lines[i] = lines[i]:gsub('{{date}}', today)
                lines[i] = lines[i]:gsub('{{cursor}}', '')
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
          end
        end)
      end, { desc = '[Z]ettelkasten [P]erson/coworker note' })
      
      -- Daily and weekly notes with templates  
      map('n', '<leader>zd', function()
        local telekasten = require('telekasten')
        local today = os.date('%Y-%m-%d')
        local daily_path = telekasten.Cfg.dailies .. '/' .. today .. telekasten.Cfg.extension
        
        -- Check if today's note already exists
        if vim.fn.filereadable(daily_path) == 1 then
          -- File exists, just open it
          telekasten.goto_today()
        else
          -- File doesn't exist, create with template
          vim.cmd('edit ' .. daily_path)
          
          -- Apply the daily template manually
          local template = telekasten.Cfg.template_new_daily
          if template then
            local lines = vim.split(template, '\n')
            
            -- Substitute template variables
            local today_formatted = os.date('%Y-%m-%d')
            for i, line in ipairs(lines) do
              lines[i] = line:gsub('{{date}}', today_formatted)
              lines[i] = lines[i]:gsub('{{cursor}}', '')
            end
            
            -- Insert the template content
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            
            -- Find cursor position and place cursor there
            for i, line in ipairs(lines) do
              if line == '' and lines[i-1] and lines[i-1]:match('Notes') then
                vim.api.nvim_win_set_cursor(0, {i, 0})
                break
              end
            end
          end
        end
      end, { desc = '[Z]ettelkasten [D]aily note with template' })
      
      map('n', '<leader>zw', '<cmd>Telekasten goto_thisweek<CR>', { desc = '[Z]ettelkasten [W]eekly note' })
      
      -- Linking and navigation
      map('n', '<leader>zl', '<cmd>Telekasten insert_link<CR>', { desc = '[Z]ettelkasten insert [L]ink' })
      map('n', '<leader>zb', '<cmd>Telekasten show_backlinks<CR>', { desc = '[Z]ettelkasten [B]acklinks' })
      map('n', '<leader>zi', '<cmd>Telekasten paste_img_and_link<CR>', { desc = '[Z]ettelkasten [I]nsert image' })
      
      -- Tags
      map('n', '<leader>z#', '<cmd>Telekasten show_tags<CR>', { desc = '[Z]ettelkasten show tags' })
      
      -- Calendar (if you want calendar integration)
      map('n', '<leader>zc', '<cmd>Telekasten show_calendar<CR>', { desc = '[Z]ettelkasten [C]alendar' })
      
      -- Follow links with Enter in normal mode
      map('n', '<CR>', '<cmd>Telekasten follow_link<CR>', { desc = 'Follow zettel link' })
      
      -- Alternative keymap for following links (more reliable)
      map('n', '<leader>zj', '<cmd>Telekasten follow_link<CR>', { desc = '[Z]ettelkasten [J]ump to link' })
      
      -- Create link from visual selection
      map('v', '<leader>zl', '<cmd>Telekasten toggle_todo<CR>', { desc = '[Z]ettelkasten link from selection' })
      

    end,
  },

  -- Optional: Calendar integration for better daily/weekly note navigation
  {
    'mattn/calendar-vim',
    cmd = 'Calendar',
    config = function()
      vim.g.calendar_monday = 1
      vim.g.calendar_weeknm = 1
    end,
  },

  -- Better markdown support with task management - RESTORED
  {
    'ixru/nvim-markdown',
    ft = 'markdown',
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_frontmatter = 1
      
      -- Only disable the gx mapping that conflicts, keep everything else
      vim.g.vim_markdown_no_default_key_mappings = 0  -- Enable default mappings
      vim.g.vim_markdown_auto_insert_bullets = 1
      vim.g.vim_markdown_new_list_item_indent = 2
      
      -- Override just the problematic gx mapping after plugin loads
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          -- Restore our custom gx mapping that opens URLs
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
