-- Tests for zettelkasten keymaps
local assert = require('luassert')

describe('Zettelkasten Keymaps', function()
  before_each(function()
    -- Create a test buffer with some content
    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      'This is a test document.',
      'Here we have Pharma Eng as a test phrase.',
      'Also testing single words like automation.',
      'And some other content here.',
    })
    vim.api.nvim_win_set_cursor(0, {2, 14}) -- Position on "Pharma"
  end)

  after_each(function()
    vim.cmd('bdelete!')
  end)

  describe('<leader>z2 (2-word zettelkasten link)', function()
    it('should wrap 2 words in [[ ]]', function()
      -- Simulate the keymap
      require('plugins.notes')
      
      -- Get the keymap function
      local keymaps = vim.api.nvim_get_keymap('n')
      local z2_keymap = nil
      for _, map in ipairs(keymaps) do
        if map.lhs == '<leader>z2' then
          z2_keymap = map
          break
        end
      end
      
      assert.is_not_nil(z2_keymap, '<leader>z2 keymap should exist')
      
      -- Execute the keymap function
      if z2_keymap.callback then
        z2_keymap.callback()
        
        -- Check the result
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        assert.match('%[%[Pharma Eng%]%]', lines[2])
      end
    end)

    it('should not include extra characters', function()
      require('plugins.notes')
      
      -- Position cursor at start of "Pharma Eng"
      vim.api.nvim_win_set_cursor(0, {2, 14})
      
      -- Execute the function directly
      local keymaps = vim.api.nvim_get_keymap('n')
      for _, map in ipairs(keymaps) do
        if map.lhs == '<leader>z2' and map.callback then
          map.callback()
          break
        end
      end
      
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      -- Should not contain extra spaces or characters
      assert.is_not.match('%[%[Pharma Eng s%]%]', lines[2])
      assert.is_not.match('%[%[Pharma Eng %]%]', lines[2])
    end)
  end)

  describe('<leader>zw (single word zettelkasten link)', function()
    it('should wrap single word in [[ ]]', function()
      require('plugins.notes')
      
      -- Position on "automation"
      vim.api.nvim_win_set_cursor(0, {3, 25})
      
      local keymaps = vim.api.nvim_get_keymap('n')
      for _, map in ipairs(keymaps) do
        if map.lhs == '<leader>zw' and map.callback then
          map.callback()
          break
        end
      end
      
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.match('%[%[automation%]%]', lines[3])
    end)
  end)

  describe('<leader>z[ (visual selection zettelkasten link)', function()
    it('should wrap visually selected text in [[ ]]', function()
      require('plugins.notes')
      
      -- Simulate visual selection of "Pharma Eng"
      vim.api.nvim_win_set_cursor(0, {2, 14})
      vim.cmd('normal! v2ey') -- Select "Pharma Eng"
      
      -- Get visual keymap
      local keymaps = vim.api.nvim_get_keymap('v')
      for _, map in ipairs(keymaps) do
        if map.lhs == '<leader>z[' and map.callback then
          map.callback()
          break
        end
      end
      
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.match('%[%[Pharma Eng%]%]', lines[2])
    end)
  end)
end)
