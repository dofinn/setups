return {
  'mrcjkb/rustaceanvim',
  version = '^5',
  lazy = false,
  config = function()
    vim.g.rustaceanvim = {
      -- Use Telescope for code actions and other UI
      tools = {
        code_actions = {
          ui_select_fallback = false,
        },
        executor = require('rustaceanvim.executors').termopen,
      },
      server = {
        default_settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              buildScripts = {
                enable = true,
              },
            },
            check = {
              command = "clippy",
              extraArgs = { "--", "-W", "clippy::unwrap_used", "-W", "clippy::expect_used" },
            },
            procMacro = {
              enable = true,
            },
            diagnostics = {
              enable = true,
            },
          },
        },
      },
    }

    -- Configure vim.ui.select to use Telescope
    local has_telescope, telescope = pcall(require, 'telescope')
    if has_telescope then
      telescope.load_extension('ui-select')
    end

    -- Easy-to-remember Rust keybindings (only for Rust files)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, silent = true }

        -- Set up which-key group name
        vim.schedule(function()
          local wk_ok, wk = pcall(require, "which-key")
          if wk_ok then
            wk.add({
              { "<leader>r", group = "Rust" },
            })
          end
        end)

        -- <leader>r prefix for all Rust commands
        vim.keymap.set("n", "<leader>re", function() vim.cmd.RustLsp('explainError') end,
          vim.tbl_extend("force", opts, { desc = "Explain Error" }))

        vim.keymap.set("n", "<leader>rm", function() vim.cmd.RustLsp('expandMacro') end,
          vim.tbl_extend("force", opts, { desc = "Expand Macro" }))

        vim.keymap.set("n", "<leader>rr", function() vim.cmd.RustLsp('runnables') end,
          vim.tbl_extend("force", opts, { desc = "Runnables" }))

        vim.keymap.set("n", "<leader>rc", function() vim.cmd.RustLsp('openCargo') end,
          vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

        vim.keymap.set("n", "<leader>rh", function() vim.cmd.RustLsp({ 'view', 'hir' }) end,
          vim.tbl_extend("force", opts, { desc = "View HIR" }))

        vim.keymap.set("n", "<leader>ri", function() vim.cmd.RustLsp({ 'view', 'mir' }) end,
          vim.tbl_extend("force", opts, { desc = "View MIR" }))

        -- Additional powerful features
        vim.keymap.set("n", "<leader>rd", function() vim.cmd.RustLsp('debuggables') end,
          vim.tbl_extend("force", opts, { desc = "Debuggables (DAP)" }))

        vim.keymap.set("n", "<leader>rt", function() vim.cmd.RustLsp('testables') end,
          vim.tbl_extend("force", opts, { desc = "Run Tests" }))

        vim.keymap.set("n", "<leader>rp", function() vim.cmd.RustLsp('parentModule') end,
          vim.tbl_extend("force", opts, { desc = "Parent Module" }))

        vim.keymap.set("n", "<leader>rj", function() vim.cmd.RustLsp('joinLines') end,
          vim.tbl_extend("force", opts, { desc = "Join Lines" }))

        vim.keymap.set("n", "<leader>rs", function() vim.cmd.RustLsp('ssr') end,
          vim.tbl_extend("force", opts, { desc = "Structural Search Replace" }))

        vim.keymap.set("n", "<leader>rg", function() vim.cmd.RustLsp('crateGraph') end,
          vim.tbl_extend("force", opts, { desc = "Crate Graph" }))

        vim.keymap.set("n", "<leader>rv", function() vim.cmd.RustLsp({ 'view', 'syntaxTree' }) end,
          vim.tbl_extend("force", opts, { desc = "View Syntax Tree" }))

        vim.keymap.set("n", "<leader>rD", function() vim.cmd.RustLsp('externalDocs') end,
          vim.tbl_extend("force", opts, { desc = "Open External Docs" }))
      end,
    })
  end,
}
