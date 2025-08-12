return {
  'lewis6991/gitsigns.nvim',

  config = function()
    require('gitsigns').setup({
      signs = {
        add          = { text = '+' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      current_line_blame = false,
      attach_to_untracked = true,
    })

    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() require('gitsigns').next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() require('gitsigns').prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk)
    vim.keymap.set('n', '<leader>hb', function() require('gitsigns').blame_line{full=true} end)
    vim.keymap.set('n', '<leader>hs', require('gitsigns').stage_hunk)
    vim.keymap.set('n', '<leader>hr', require('gitsigns').reset_hunk)
  end
}
