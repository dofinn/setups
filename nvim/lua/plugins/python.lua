return {
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      settings = {
        search = {
          venv = { command = "fd python$ ~/.pyenv" },
        },
      },
    },
    event = 'VeryLazy',
    keys = {
      { '<leader>pv', '<cmd>VenvSelect<cr>', desc = 'Select Virtual Environment' },
    },
  },

  -- FileType autocmd for Python-specific keybindings
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Python keybindings via autocmd (like rustaceanvim pattern)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local opts_buf = { buffer = bufnr, silent = true }

          -- Set up which-key group name
          vim.schedule(function()
            local wk_ok, wk = pcall(require, "which-key")
            if wk_ok then
              wk.add({
                { "<leader>p", group = "Python" },
              })
            end
          end)

          -- Virtual Environment
          vim.keymap.set("n", "<leader>pv", "<cmd>VenvSelect<cr>",
            vim.tbl_extend("force", opts_buf, { desc = "Select Virtual Environment" }))

          -- LSP Utilities
          vim.keymap.set("n", "<leader>pI", "<cmd>LspInfo<cr>",
            vim.tbl_extend("force", opts_buf, { desc = "LSP Info" }))
          vim.keymap.set("n", "<leader>pL", "<cmd>LspRestart basedpyright<cr>",
            vim.tbl_extend("force", opts_buf, { desc = "Restart LSP" }))

          -- Running code
          vim.keymap.set("n", "<leader>pp", "<cmd>!python3 %<cr>",
            vim.tbl_extend("force", opts_buf, { desc = "Run Current File" }))
        end,
      })
    end,
  },
}
