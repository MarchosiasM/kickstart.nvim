-- Tests for better-tags functionality
local assert = require('luassert')

describe('Better Tags', function()
  local test_dir = '/tmp/nvim_test_zettelkasten'
  
  before_each(function()
    -- Create test directory structure
    vim.fn.mkdir(test_dir, 'p')
    
    -- Create test files with tags
    local test_files = {
      {
        name = 'note1.md',
        content = {
          '# Note 1',
          'This is a note about #productivity and #automation.',
          'Also mentions #workflow.',
          '#daily',
        }
      },
      {
        name = 'note2.md', 
        content = {
          '# Note 2',
          'Another note with #productivity.',
          'And some #meeting notes.',
          '#project/important',
        }
      },
      {
        name = 'note3.md',
        content = {
          '# Note 3',
          'No tags in this note.',
        }
      }
    }
    
    for _, file in ipairs(test_files) do
      vim.fn.writefile(file.content, test_dir .. '/' .. file.name)
    end
  end)

  after_each(function()
    vim.fn.delete(test_dir, 'rf')
  end)

  describe('scan_for_tags', function()
    it('should find all tags in test directory', function()
      local better_tags = require('zettelkasten.better-tags')
      
      -- Mock the zettelkasten path for testing
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      local tag_data = better_tags.scan_for_tags()
      
      -- Restore original function
      vim.fn.expand = original_expand
      
      -- Check that we found the expected tags
      local expected_tags = {'productivity', 'automation', 'workflow', 'daily', 'meeting', 'project/important'}
      
      for _, expected_tag in ipairs(expected_tags) do
        assert.is_not_nil(tag_data[expected_tag], 'Should find tag: ' .. expected_tag)
      end
      
      -- Check counts
      assert.equals(2, tag_data['productivity'].count)
      assert.equals(1, tag_data['automation'].count)
    end)

    it('should track file locations for tags', function()
      local better_tags = require('zettelkasten.better-tags')
      
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      local tag_data = better_tags.scan_for_tags()
      vim.fn.expand = original_expand
      
      -- Check that productivity tag appears in both note1 and note2
      assert.equals(2, #tag_data['productivity'].files)
      
      local files = {}
      for _, file_info in ipairs(tag_data['productivity'].files) do
        table.insert(files, vim.fn.fnamemodify(file_info.file, ':t'))
      end
      
      assert.contains(files, 'note1.md')
      assert.contains(files, 'note2.md')
    end)
  end)

  describe('show_tags', function()
    it('should create a floating window with tags', function()
      local better_tags = require('zettelkasten.better-tags')
      
      -- Mock the expand function
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      -- Get window count before
      local windows_before = #vim.api.nvim_list_wins()
      
      better_tags.show_tags()
      
      -- Should have created a new window
      local windows_after = #vim.api.nvim_list_wins()
      assert.is_true(windows_after > windows_before)
      
      vim.fn.expand = original_expand
    end)
  end)
end)
