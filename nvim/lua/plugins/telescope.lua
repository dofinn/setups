return {
  'nvim-telescope/telescope.nvim',

  --  tag = '0.1.6', -- or, branch = '0.1.x',

  dependencies = { 'nvim-lua/plenary.nvim' },

  config = function()
    require('telescope').setup({
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden'            -- 🔍 Include hidden files
        }
      }
    })

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', 'z=', builtin.spell_suggest, {})
    vim.keymap.set('n', '<leader>kf', builtin.find_files, {})
    vim.keymap.set('n', '<leader>kF', function() builtin.find_files({ hidden = true, no_ignore = true })end)
    vim.keymap.set('n', '<leader>kg', builtin.git_files, {})
    vim.keymap.set('n', '<leader>gst', builtin.git_status, {})
    vim.keymap.set('n', '<leader>gco', builtin.git_commits, {})
    vim.keymap.set('n', '<leader>gcb', builtin.git_bcommits, {})
    vim.keymap.set('n', '<leader>kws', function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>kwS', function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>ks', function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") }); end)
    vim.keymap.set('n', ';', builtin.buffers, {})
    vim.keymap.set('n', '<leader>kh', builtin.help_tags, {})
    vim.keymap.set('n', '<leader>gi', builtin.lsp_implementations, {})
    vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, {})
    vim.keymap.set('n', '<leader>gt', builtin.lsp_type_definitions, {})
  end
}
