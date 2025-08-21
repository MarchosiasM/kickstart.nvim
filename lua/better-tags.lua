-- Better tag functionality for your zettelkasten
-- This creates improved tag browsing and search capabilities

local function create_better_tag_browser()
  -- Simple tag extraction from all markdown files
  local function get_all_tags()
    local tags = {}
    local files = vim.fn.glob("**/*.md", false, true)
    
    for _, file in ipairs(files) do
      if vim.fn.filereadable(file) == 1 then
        local lines = vim.fn.readfile(file)
        for _, line in ipairs(lines) do
          -- Extract tags using pattern matching
          for tag in string.gmatch(line, "#[%w%-_]+") do
            if not tags[tag] then
              tags[tag] = {}
            end
            table.insert(tags[tag], file)
          end
        end
      end
    end
    
    return tags
  end
  
  -- Show tags in a simple popup
  local function show_tags_popup()
    local tags = get_all_tags()
    local tag_list = {}
    
    for tag, files in pairs(tags) do
      table.insert(tag_list, string.format("%s (%d files)", tag, #files))
    end
    
    if #tag_list == 0 then
      vim.notify("No tags found in zettelkasten", vim.log.levels.WARN)
      return
    end
    
    table.sort(tag_list)
    
    -- Create a simple buffer to display tags
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = {"=== Tags in your Zettelkasten ===", ""}
    vim.list_extend(lines, tag_list)
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
    
    -- Create floating window
    local width = 60
    local height = math.min(#lines + 2, 20)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      style = 'minimal',
      border = 'rounded',
      title = ' Zettelkasten Tags ',
      title_pos = 'center'
    })
    
    -- Close on escape or q
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', {noremap = true, silent = true})
    
    vim.notify(string.format("Found %d unique tags", vim.tbl_count(tags)), vim.log.levels.INFO)
  end
  
  -- Search files by tag using telescope if available
  local function search_by_tag()
    local tags = get_all_tags()
    if vim.tbl_count(tags) == 0 then
      vim.notify("No tags found", vim.log.levels.WARN)
      return
    end
    
    -- Use vim.ui.select for tag selection
    local tag_names = {}
    for tag, _ in pairs(tags) do
      table.insert(tag_names, tag)
    end
    table.sort(tag_names)
    
    vim.ui.select(tag_names, {
      prompt = 'Select tag to search:',
      format_item = function(tag)
        return string.format("%s (%d files)", tag, #tags[tag])
      end,
    }, function(selected_tag)
      if selected_tag then
        local files = tags[selected_tag]
        if #files == 1 then
          vim.cmd('edit ' .. files[1])
        else
          -- Multiple files, let user choose
          vim.ui.select(files, {
            prompt = 'Select file:',
          }, function(selected_file)
            if selected_file then
              vim.cmd('edit ' .. selected_file)
            end
          end)
        end
      end
    end)
  end
  
  return {
    show_tags = show_tags_popup,
    search_by_tag = search_by_tag,
    get_all_tags = get_all_tags
  }
end

-- Export the functions
return create_better_tag_browser()
