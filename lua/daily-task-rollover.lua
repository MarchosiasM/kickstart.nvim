-- Daily Task Rollover System
-- Automatically forwards incomplete tasks from previous day and "Tomorrow" items

local M = {}

-- Parse a daily note and extract tasks
function M.parse_daily_note(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return {incomplete_tasks = {}, tomorrow_items = {}}
  end
  
  local content = file:read("*a")
  file:close()
  
  local lines = vim.split(content, '\n')
  local incomplete_tasks = {}
  local tomorrow_items = {}
  local current_section = nil
  
  for _, line in ipairs(lines) do
    -- Detect sections
    if line:match("^## Tasks") then
      current_section = "tasks"
    elseif line:match("^## Tomorrow") then
      current_section = "tomorrow"
    elseif line:match("^##") then
      current_section = "other"
    elseif current_section == "tasks" then
      -- Extract incomplete tasks (- [ ])
      if line:match("^%s*-%s*%[%s*%]") then
        local task = line:gsub("^%s*-%s*%[%s*%]%s*", "")
        if task ~= "" then
          table.insert(incomplete_tasks, task)
        end
      end
    elseif current_section == "tomorrow" then
      -- Extract tomorrow items (any line with content)
      local content_line = line:match("^%s*-%s*(.+)")
      if content_line and content_line ~= "" then
        table.insert(tomorrow_items, content_line)
      end
    end
  end
  
  return {
    incomplete_tasks = incomplete_tasks,
    tomorrow_items = tomorrow_items
  }
end

-- Get the previous day's date (handling weekends intelligently)
function M.get_previous_workday(date_str)
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year then return nil end
  
  local date = os.time({
    year = tonumber(year),
    month = tonumber(month), 
    day = tonumber(day)
  })
  
  -- Go back one day
  local prev_date = date - 24 * 60 * 60
  
  -- Check if it's a Monday (weekday 2), if so, go back to Friday
  local weekday = tonumber(os.date("%w", prev_date))
  if weekday == 1 then -- Monday, so go back to Friday
    prev_date = prev_date - 2 * 24 * 60 * 60
  end
  
  return os.date("%Y-%m-%d", prev_date)
end

-- Create today's daily note with task rollover
function M.create_daily_with_rollover(date_str)
  date_str = date_str or os.date("%Y-%m-%d")
  local daily_dir = vim.fn.expand("~/Documents/Notes/zettelkasten/daily")
  local today_file = daily_dir .. "/" .. date_str .. ".md"
  
  -- Check if today's note already exists
  if vim.fn.filereadable(today_file) == 1 then
    vim.notify("Daily note for " .. date_str .. " already exists", vim.log.levels.WARN)
    vim.cmd("edit " .. today_file)
    return
  end
  
  -- Get previous workday
  local prev_date = M.get_previous_workday(date_str)
  local prev_file = daily_dir .. "/" .. prev_date .. ".md"
  
  local rollover_data = {incomplete_tasks = {}, tomorrow_items = {}}
  
  if prev_date and vim.fn.filereadable(prev_file) == 1 then
    rollover_data = M.parse_daily_note(prev_file)
    -- Only notify if there are items to roll over
    local total_items = #rollover_data.incomplete_tasks + #rollover_data.tomorrow_items
    if total_items > 0 then
      vim.notify("Rolled over " .. total_items .. " items from " .. prev_date, vim.log.levels.INFO)
    end
  end
  
  -- Create the new daily note content
  local template_content = string.format([[# Daily Note - %s

## Today's Focus
- 

## Tasks]], date_str)

  -- Add rolled over tasks
  local all_tasks = {}
  
  -- Add incomplete tasks from previous day
  for _, task in ipairs(rollover_data.incomplete_tasks) do
    table.insert(all_tasks, "- [ ] " .. task .. " ⏪") -- ⏪ indicates rolled over
  end
  
  -- Add tomorrow items from previous day
  for _, item in ipairs(rollover_data.tomorrow_items) do
    table.insert(all_tasks, "- [ ] " .. item .. " 📋") -- 📋 indicates from tomorrow list
  end
  
  -- Add a blank task line
  table.insert(all_tasks, "- [ ] ")
  
  local tasks_section = table.concat(all_tasks, "\n")
  
  local full_content = template_content .. "\n" .. tasks_section .. "\n\n" .. [[## Notes


## Reflections
- 

## Tomorrow
- 

#daily]]
  
  -- Write the file
  local file = io.open(today_file, "w")
  if file then
    file:write(full_content)
    file:close()
    
    -- Open the file in Neovim
    vim.cmd("edit " .. today_file)
    
    -- Position cursor in Today's Focus section
    vim.cmd("normal! /Today's Focus")
    vim.cmd("normal! A")
  else
    vim.notify("Failed to create daily note", vim.log.levels.ERROR)
  end
end

-- Rollover tasks from a specific date to today
function M.manual_rollover(from_date)
  local today = os.date("%Y-%m-%d")
  local daily_dir = vim.fn.expand("~/Documents/Notes/zettelkasten/daily")
  local from_file = daily_dir .. "/" .. from_date .. ".md"
  local today_file = daily_dir .. "/" .. today .. ".md"
  
  if vim.fn.filereadable(from_file) ~= 1 then
    vim.notify("Cannot find daily note for " .. from_date, vim.log.levels.ERROR)
    return
  end
  
  if vim.fn.filereadable(today_file) ~= 1 then
    vim.notify("Today's daily note doesn't exist yet", vim.log.levels.ERROR)
    return
  end
  
  local rollover_data = M.parse_daily_note(from_file)
  
  if #rollover_data.incomplete_tasks == 0 and #rollover_data.tomorrow_items == 0 then
    vim.notify("No tasks to roll over from " .. from_date, vim.log.levels.WARN)
    return
  end
  
  -- Read today's file
  local file = io.open(today_file, "r")
  local today_content = file:read("*a")
  file:close()
  
  -- Find the Tasks section and add rolled over items
  local lines = vim.split(today_content, '\n')
  local new_lines = {}
  local in_tasks = false
  local tasks_added = false
  
  for _, line in ipairs(lines) do
    table.insert(new_lines, line)
    
    if line:match("^## Tasks") then
      in_tasks = true
    elseif line:match("^##") and in_tasks then
      if not tasks_added then
        -- Add rollover tasks before the next section
        for _, task in ipairs(rollover_data.incomplete_tasks) do
          table.insert(new_lines, #new_lines, "- [ ] " .. task .. " ⏪")
        end
        for _, item in ipairs(rollover_data.tomorrow_items) do
          table.insert(new_lines, #new_lines, "- [ ] " .. item .. " 📋")
        end
        tasks_added = true
      end
      in_tasks = false
    end
  end
  
  -- Write back to today's file
  file = io.open(today_file, "w")
  file:write(table.concat(new_lines, '\n'))
  file:close()
  
  vim.notify("Rolled over " .. (#rollover_data.incomplete_tasks + #rollover_data.tomorrow_items) .. 
             " items from " .. from_date .. " to today", vim.log.levels.INFO)
  
  -- Refresh the buffer if it's open
  vim.cmd("checktime")
end

return M
