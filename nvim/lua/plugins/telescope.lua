return {
  'nvim-telescope/telescope.nvim',

--  tag = '0.1.6', -- or, branch = '0.1.x',

  dependencies = { 'nvim-lua/plenary.nvim' },

  config = function()
    require('telescope').setup({})

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', 'z=', builtin.spell_suggest, {})
    vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
    vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
    vim.keymap.set('n', '<leader>pws', function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>pwS', function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>ps', function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") }); end)
    vim.keymap.set('n', ';', builtin.buffers, {})
    vim.keymap.set('n', '<leader>ph', builtin.help_tags, {})
    vim.keymap.set('n', '<leader>gi', builtin.lsp_implementations, {})
    vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, {})
    vim.keymap.set('n', '<leader>gt', builtin.lsp_type_definitions, {})
    end
}
