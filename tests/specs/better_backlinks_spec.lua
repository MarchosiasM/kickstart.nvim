-- Tests for better-backlinks functionality
local assert = require('luassert')

describe('Better Backlinks', function()
  local test_dir = '/tmp/nvim_test_zettelkasten'
  
  before_each(function()
    -- Create test directory structure
    vim.fn.mkdir(test_dir, 'p')
    
    -- Create test files with backlinks
    local test_files = {
      {
        name = 'Target Note.md',
        content = {
          '# Target Note',
          'This is the target note.',
          'Some content here.',
        }
      },
      {
        name = 'Source Note 1.md',
        content = {
          '# Source Note 1',
          'This note links to [[Target Note]].',
          'Also has other content.',
        }
      },
      {
        name = 'Source Note 2.md',
        content = {
          '# Source Note 2',
          'Another link to [[Target Note]] here.',
          'And mentions [[Target Note]] again.',
        }
      },
      {
        name = 'No Links.md',
        content = {
          '# No Links',
          'This note has no links to our target.',
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

  describe('find_backlinks', function()
    it('should find files that link to current note', function()
      local better_backlinks = require('better-backlinks')
      
      -- Mock the zettelkasten path for testing
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      -- Mock current buffer name
      local original_bufname = vim.api.nvim_buf_get_name
      vim.api.nvim_buf_get_name = function()
        return test_dir .. '/Target Note.md'
      end
      
      local backlinks = better_backlinks.find_backlinks()
      
      -- Restore original functions
      vim.fn.expand = original_expand
      vim.api.nvim_buf_get_name = original_bufname
      
      assert.equals(2, #backlinks)
      
      -- Check that we found the right files
      local found_files = {}
      for _, link in ipairs(backlinks) do
        table.insert(found_files, vim.fn.fnamemodify(link.file, ':t'))
      end
      
      assert.contains(found_files, 'Source Note 1.md')
      assert.contains(found_files, 'Source Note 2.md')
      assert.is_not.contains(found_files, 'No Links.md')
    end)

    it('should count multiple references in same file', function()
      local better_backlinks = require('better-backlinks')
      
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      local original_bufname = vim.api.nvim_buf_get_name
      vim.api.nvim_buf_get_name = function()
        return test_dir .. '/Target Note.md'
      end
      
      local backlinks = better_backlinks.find_backlinks()
      
      vim.fn.expand = original_expand
      vim.api.nvim_buf_get_name = original_bufname
      
      -- Source Note 2 has 2 references to Target Note
      for _, link in ipairs(backlinks) do
        if vim.fn.fnamemodify(link.file, ':t') == 'Source Note 2.md' then
          assert.equals(2, #link.lines)
          break
        end
      end
    end)

    it('should handle notes with no backlinks', function()
      local better_backlinks = require('better-backlinks')
      
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      local original_bufname = vim.api.nvim_buf_get_name
      vim.api.nvim_buf_get_name = function()
        return test_dir .. '/No Links.md'
      end
      
      local backlinks = better_backlinks.find_backlinks()
      
      vim.fn.expand = original_expand
      vim.api.nvim_buf_get_name = original_bufname
      
      assert.equals(0, #backlinks)
    end)
  end)

  describe('show_backlinks', function()
    it('should create a floating window with backlinks', function()
      local better_backlinks = require('better-backlinks')
      
      -- Mock functions
      local original_expand = vim.fn.expand
      vim.fn.expand = function(path)
        if path:match('~/Documents/Notes/zettelkasten') then
          return test_dir
        end
        return original_expand(path)
      end
      
      local original_bufname = vim.api.nvim_buf_get_name
      vim.api.nvim_buf_get_name = function()
        return test_dir .. '/Target Note.md'
      end
      
      -- Get window count before
      local windows_before = #vim.api.nvim_list_wins()
      
      better_backlinks.show_backlinks()
      
      -- Should have created a new window
      local windows_after = #vim.api.nvim_list_wins()
      assert.is_true(windows_after > windows_before)
      
      -- Restore functions
      vim.fn.expand = original_expand
      vim.api.nvim_buf_get_name = original_bufname
    end)
  end)
end)
