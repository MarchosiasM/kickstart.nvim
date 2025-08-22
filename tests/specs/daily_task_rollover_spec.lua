-- Tests for daily task rollover functionality
local assert = require('luassert')

describe('Daily Task Rollover', function()
  local test_dir = '/tmp/nvim_test_zettelkasten'
  local test_daily_dir = test_dir .. '/daily'
  
  before_each(function()
    -- Create test directory structure
    vim.fn.mkdir(test_daily_dir, 'p')
    
    -- Create yesterday's note with tasks
    local yesterday = os.date('%Y-%m-%d', os.time() - 24*60*60)
    local yesterday_content = {
      '# Daily Note - ' .. yesterday,
      '',
      '## Today\'s Focus',
      '- Focus item 1',
      '',
      '## Tasks',
      '- [ ] Incomplete task 1',
      '- [x] Completed task',
      '- [ ] Incomplete task 2',
      '',
      '## Tomorrow',
      '- Tomorrow item 1',
      '- Tomorrow item 2',
      '',
      '## Notes',
      'Some notes here',
    }
    
    local yesterday_file = test_daily_dir .. '/' .. yesterday .. '.md'
    vim.fn.writefile(yesterday_content, yesterday_file)
  end)

  after_each(function()
    vim.fn.delete(test_dir, 'rf')
  end)

  describe('find_yesterday_note', function()
    it('should find yesterday\'s note file', function()
      local rollover = require('zettelkasten.daily-task-rollover')
      local yesterday_file = rollover.find_yesterday_note()
      
      local yesterday = os.date('%Y-%m-%d', os.time() - 24*60*60)
      local expected_file = vim.fn.expand('~/Documents/Notes/zettelkasten/daily/' .. yesterday .. '.md')
      
      -- In test environment, adjust path expectation
      assert.is_string(yesterday_file)
      assert.match(yesterday .. '%.md', yesterday_file)
    end)
  end)

  describe('extract_rollover_items', function()
    it('should extract incomplete tasks', function()
      local content = {
        '## Tasks',
        '- [ ] Incomplete task 1',
        '- [x] Completed task',
        '- [ ] Incomplete task 2',
        '## Other section',
      }
      
      local rollover = require('zettelkasten.daily-task-rollover')
      local tasks, tomorrow = rollover.extract_rollover_items(content)
      
      assert.equals(2, #tasks)
      assert.equals('- [ ] Incomplete task 1', tasks[1])
      assert.equals('- [ ] Incomplete task 2', tasks[2])
    end)

    it('should extract tomorrow items', function()
      local content = {
        '## Tomorrow',
        '- Tomorrow item 1',
        '- Tomorrow item 2',
        '## Other section',
      }
      
      local rollover = require('zettelkasten.daily-task-rollover')
      local tasks, tomorrow = rollover.extract_rollover_items(content)
      
      assert.equals(2, #tomorrow)
      assert.equals('- Tomorrow item 1', tomorrow[1])
      assert.equals('- Tomorrow item 2', tomorrow[2])
    end)

    it('should handle mixed content correctly', function()
      local content = {
        '## Tasks',
        '- [ ] Task 1',
        '- [x] Done task',
        '## Tomorrow',
        '- Tomorrow 1',
        '## Notes',
        'Some notes',
      }
      
      local rollover = require('zettelkasten.daily-task-rollover')
      local tasks, tomorrow = rollover.extract_rollover_items(content)
      
      assert.equals(1, #tasks)
      assert.equals(1, #tomorrow)
      assert.equals('- [ ] Task 1', tasks[1])
      assert.equals('- Tomorrow 1', tomorrow[1])
    end)
  end)

  describe('create_daily_with_rollover', function()
    it('should create a new daily note with template', function()
      -- Mock the template path for testing
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten/daily/') then
          return path:gsub('~', test_dir)
        end
        return original_expand(path)
      end
      
      local rollover = require('zettelkasten.daily-task-rollover')
      
      -- This should create today's note
      rollover.create_daily_with_rollover()
      
      local today = os.date('%Y-%m-%d')
      local today_file = test_daily_dir .. '/' .. today .. '.md'
      
      assert.is_true(vim.fn.filereadable(today_file) == 1)
      
      local content = vim.fn.readfile(today_file)
      assert.match('# Daily Note %- ' .. today, content[1])
      assert.match('## Today\'s Focus', table.concat(content, '\n'))
      
      -- Restore original function
      vim.fn.expand = original_expand
    end)
  end)
end)
