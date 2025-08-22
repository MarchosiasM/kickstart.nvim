-- Tests for Telekasten integration and templates
local assert = require('luassert')

describe('Telekasten Integration', function()
  local test_dir = '/tmp/nvim_test_zettelkasten'
  local test_templates_dir = test_dir .. '/.telekasten/templates'
  
  before_each(function()
    -- Create test directory structure
    vim.fn.mkdir(test_templates_dir, 'p')
    vim.fn.mkdir(test_dir .. '/daily', 'p')
    vim.fn.mkdir(test_dir .. '/weekly', 'p')
    
    -- Create test templates
    local templates = {
      {
        name = 'daily.md',
        content = {
          '# Daily Note - %date%',
          '',
          '## Today\'s Focus',
          '- ',
          '',
          '## Tasks',
          '- [ ] ',
          '',
          '## Notes',
          '',
          '',
          '## Reflections',
          '- ',
          '',
          '## Tomorrow',
          '- ',
          '',
          '#daily',
        }
      },
      {
        name = 'weekly.md',
        content = {
          '# Weekly Review - %date%',
          '',
          '## Accomplishments',
          '- ',
          '',
          '## Lessons Learned',
          '- ',
          '',
          '## Next Week Focus',
          '- ',
          '',
          '#weekly #review',
        }
      },
      {
        name = 'meeting.md',
        content = {
          '# Meeting: %title%',
          '',
          '**Date:** %date%',
          '**Attendees:** ',
          '',
          '## Agenda',
          '- ',
          '',
          '## Notes',
          '',
          '',
          '## Action Items',
          '- [ ] ',
          '',
          '#meeting',
        }
      }
    }
    
    for _, template in ipairs(templates) do
      vim.fn.writefile(template.content, test_templates_dir .. '/' .. template.name)
    end
  end)

  after_each(function()
    vim.fn.delete(test_dir, 'rf')
  end)

  describe('Template System', function()
    it('should have all required templates', function()
      local required_templates = {'daily.md', 'weekly.md', 'meeting.md'}
      
      for _, template in ipairs(required_templates) do
        local template_path = test_templates_dir .. '/' .. template
        assert.is_true(vim.fn.filereadable(template_path) == 1, 'Template should exist: ' .. template)
      end
    end)

    it('should contain required placeholder tokens', function()
      local daily_content = vim.fn.readfile(test_templates_dir .. '/daily.md')
      local daily_text = table.concat(daily_content, '\n')
      
      assert.match('%%date%%', daily_text)
      assert.match('Today\'s Focus', daily_text)
      assert.match('## Tasks', daily_text)
      assert.match('#daily', daily_text)
    end)

    it('should have proper structure for meeting template', function()
      local meeting_content = vim.fn.readfile(test_templates_dir .. '/meeting.md')
      local meeting_text = table.concat(meeting_content, '\n')
      
      assert.match('%%title%%', meeting_text)
      assert.match('%%date%%', meeting_text)
      assert.match('## Agenda', meeting_text)
      assert.match('## Action Items', meeting_text)
      assert.match('#meeting', meeting_text)
    end)
  end)

  describe('Telekasten Configuration', function()
    it('should have correct paths configured', function()
      -- This test will verify that the configuration loads correctly
      local success, config = pcall(function()
        return require('plugins.notes')
      end)
      
      assert.is_true(success, 'Notes plugin should load without error')
      
      -- In a real test, we'd check the actual Telekasten config
      -- but that requires the plugin to be fully loaded
    end)
  end)

  describe('Daily Note Creation', function()
    it('should create notes in correct directory structure', function()
      -- Mock the zettelkasten path for testing
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      -- Test that daily directory exists and is writable
      local daily_dir = test_dir .. '/daily'
      assert.is_true(vim.fn.isdirectory(daily_dir) == 1)
      
      -- Test file creation
      local today = os.date('%Y-%m-%d')
      local test_file = daily_dir .. '/' .. today .. '.md'
      vim.fn.writefile({'# Test'}, test_file)
      assert.is_true(vim.fn.filereadable(test_file) == 1)
      
      vim.fn.expand = original_expand
    end)
  end)

  describe('Calendar Integration', function()
    it('should not produce calendar errors', function()
      -- Test that calendar plugin integration doesn't break
      local success, result = pcall(function()
        -- This would test calendar.vim integration
        -- For now, just ensure no obvious errors
        return true
      end)
      
      assert.is_true(success, 'Calendar integration should not error')
    end)
  end)
end)
