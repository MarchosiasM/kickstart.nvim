-- Enhanced backlinks functionality for zettelkasten
-- Provides reliable backlink detection when telekasten fails

local M = {}

-- Get all backlinks to the current file
function M.get_backlinks(target_file)
  target_file = target_file or vim.fn.expand('%:t:r') -- filename without extension
  
  local backlinks = {}
  local home_dir = vim.fn.expand("~/Documents/Notes/zettelkasten")
  
  -- Search patterns for different link formats
  local patterns = {
    "%[%[" .. target_file .. "%]%]",                    -- [[Filename]]
    "%[%[" .. target_file .. "|[^%]]*%]%]",            -- [[Filename|display text]]
    "%[%[" .. target_file .. "#[^%]]*%]%]",            -- [[Filename#section]]
  }
  
  -- Find all markdown files
  local find_cmd = string.format('find "%s" -name "*.md" -type f', home_dir)
  local handle = io.popen(find_cmd)
  local files = {}
  
  if handle then
    for line in handle:lines() do
      table.insert(files, line)
    end
    handle:close()
  end
  
  -- Search each file for links to target
  for _, file in ipairs(files) do
    local relative_file = file:gsub(home_dir .. "/", "")
    
    -- Skip the target file itself
    if not file:match(target_file .. "%.md$") then
      local file_handle = io.open(file, "r")
      if file_handle then
        local line_num = 0
        for line in file_handle:lines() do
          line_num = line_num + 1
          
          -- Check each pattern
          for _, pattern in ipairs(patterns) do
            if line:match(pattern) then
              table.insert(backlinks, {
                file = relative_file,
                line = line_num,
                content = line:gsub("^%s*", ""), -- trim leading whitespace
                full_path = file
              })
              break -- Don't check other patterns for this line
            end
          end
        end
        file_handle:close()
      end
    end
  end
  
  return backlinks
end

-- Show backlinks in a floating window
function M.show_backlinks()
  local current_file = vim.fn.expand('%:t:r')
  local backlinks = M.get_backlinks(current_file)
  
  if #backlinks == 0 then
    vim.notify("No backlinks found for " .. current_file, vim.log.levels.WARN)
    return
  end
  
  -- Create buffer content
  local lines = {
    "=== Backlinks to " .. current_file .. " ===",
    "",
  }
  
  -- Group by file
  local by_file = {}
  for _, link in ipairs(backlinks) do
    if not by_file[link.file] then
      by_file[link.file] = {}
    end
    table.insert(by_file[link.file], link)
  end
  
  -- Format content
  for file, links in pairs(by_file) do
    table.insert(lines, "📄 " .. file)
    for _, link in ipairs(links) do
      table.insert(lines, string.format("  %d: %s", link.line, link.content))
    end
    table.insert(lines, "")
  end
  
  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  local width = math.max(60, math.min(vim.o.columns - 10, 100))
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Backlinks for ' .. current_file .. ' ',
    title_pos = 'center'
  })
  
  -- Set up key mappings for the backlinks window
  local function goto_backlink()
    local line = vim.api.nvim_get_current_line()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    
    -- Find which backlink this line represents
    local current_file_in_window = nil
    local target_line = nil
    
    -- Parse the line to extract file and line number
    if line:match("^📄 ") then
      current_file_in_window = line:gsub("^📄 ", "")
    elseif line:match("^  %d+:") then
      target_line = tonumber(line:match("^  (%d+):"))
      -- Find the current file by looking backwards
      for i = line_num - 1, 1, -1 do
        local prev_line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
        if prev_line and prev_line:match("^📄 ") then
          current_file_in_window = prev_line:gsub("^📄 ", "")
          break
        end
      end
    end
    
    if current_file_in_window and target_line then
      local full_path = vim.fn.expand("~/Documents/Notes/zettelkasten/" .. current_file_in_window)
      vim.api.nvim_win_close(win, true)
      vim.cmd('edit ' .. full_path)
      vim.api.nvim_win_set_cursor(0, {target_line, 0})
      vim.cmd('normal! zz') -- center the line
    end
  end
  
  -- Key mappings
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    noremap = true,
    silent = true,
    callback = goto_backlink
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', {noremap = true, silent = true})
  
  vim.notify(string.format("Found %d backlinks in %d files", #backlinks, vim.tbl_count(by_file)), vim.log.levels.INFO)
end

-- Interactive backlink browser
function M.browse_backlinks()
  local current_file = vim.fn.expand('%:t:r')
  local backlinks = M.get_backlinks(current_file)
  
  if #backlinks == 0 then
    vim.notify("No backlinks found for " .. current_file, vim.log.levels.WARN)
    return
  end
  
  -- Create selection items
  local items = {}
  for _, link in ipairs(backlinks) do
    table.insert(items, string.format("%s:%d - %s", link.file, link.line, link.content:sub(1, 50)))
  end
  
  vim.ui.select(items, {
    prompt = 'Select backlink to jump to:',
  }, function(selected, idx)
    if selected and idx then
      local link = backlinks[idx]
      vim.cmd('edit ' .. link.full_path)
      vim.api.nvim_win_set_cursor(0, {link.line, 0})
      vim.cmd('normal! zz')
    end
  end)
end

return M
