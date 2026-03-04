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
      dap = {
        adapter = require('rustaceanvim.config').get_codelldb_adapter(
          vim.fn.expand("~/.local/share/nvim/mason/bin/codelldb"),
          vim.fn.expand("~/.local/share/nvim/mason/packages/codelldb/extension/lldb/lib/liblldb.dylib")
        ),
      },
      server = {
        default_settings = {
          ['rust-analyzer'] = {
            -- Detailed inlay hints for maximum insights
            inlayHints = {
              bindingModeHints = { enable = true },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true },
              closureReturnTypeHints = { enable = "always" },
              lifetimeElisionHints = { enable = "always" },
              parameterHints = { enable = true },
              reborrowHints = { enable = "always" },
              typeHints = { enable = true },
            },

            -- Enhanced hover actions
            hover = {
              actions = {
                references = { enable = true },
                run = { enable = true },
              },
            },

            -- Enable all code lenses
            lens = {
              enable = true,
              references = {
                adt = { enable = true },
                enumVariant = { enable = true },
                method = { enable = true },
                trait = { enable = true },
              },
              run = { enable = true },
              debug = { enable = true },
            },

            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = false,
              },
            },
            check = {
              command = "clippy",
              -- Critical for monorepo: only check current package
              allTargets = false,
              -- Use monorepo rust-analyzer profile (see .cargo/config.toml)
              extraArgs = {
                "--profile", "rust-analyzer",
                "--",
                "-W", "clippy::needless_range_loop",
                "-W", "clippy::manual_find",
                "-W", "clippy::manual_filter",
                "-W", "clippy::search_is_some",
                "-W", "clippy::single_char_add_str",
                "-W", "clippy::map_unwrap_or",
                "-W", "clippy::unnecessary_fold",
                "-W", "clippy::redundant_closure",
                "-W", "clippy::filter_map_next",
                "-W", "clippy::flat_map_identity",
                "-W", "clippy::map_flatten",
              },
            },
            -- Try disabling proc-macros to stop the spam/memory issue
            procMacro = {
              enable = false,  -- Disable proc-macros temporarily to stop the flood
            },
            diagnostics = {
              enable = true,
            },
          },
        },
      }
    }

    -- Note: Telescope ui-select extension is loaded in telescope.lua

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

        -- Enable inlay hints by default for Rust files
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        -- Set up code lens auto-refresh
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
          buffer = bufnr,
          callback = function()
            vim.lsp.codelens.refresh({ bufnr = bufnr })
          end,
        })
        -- Initial refresh
        vim.lsp.codelens.refresh({ bufnr = bufnr })

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

        -- Custom runnable - provide your own command (uses same terminal as runnables)
        local function run_in_terminal(cmd)
          -- Open a terminal split (same behavior as rustaceanvim)
          vim.cmd('split')
          vim.cmd('resize 15')
          local bufnr = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_set_current_buf(bufnr)
          vim.fn.termopen(cmd, {
            on_exit = function(_, exit_code)
              if exit_code == 0 then
                print("✓ Command completed successfully")
              else
                print("✗ Command failed with exit code: " .. exit_code)
              end
            end
          })
          vim.cmd('startinsert')
        end

        vim.keymap.set("n", "<leader>rl", function()
          local clippy_cmd = "cargo clippy -- " ..
            "-W clippy::needless_range_loop " ..
            "-W clippy::manual_find " ..
            "-W clippy::manual_filter " ..
            "-W clippy::search_is_some " ..
            "-W clippy::single_char_add_str " ..
            "-W clippy::map_unwrap_or " ..
            "-W clippy::unnecessary_fold " ..
            "-W clippy::redundant_closure " ..
            "-W clippy::filter_map_next " ..
            "-W clippy::flat_map_identity " ..
            "-W clippy::map_flatten"
          run_in_terminal(clippy_cmd)
        end, vim.tbl_extend("force", opts, { desc = "Run Clippy (strict)" }))

        vim.keymap.set("n", "<leader>ra", function()
          -- View assembly using cargo-show-asm (install with: cargo install cargo-show-asm)
          -- Examples: "main", "--lib function_name", "--bin binary_name function_name"
          vim.ui.input({
            prompt = "cargo asm args (e.g., --lib function_name): ",
          }, function(args)
            if args and args ~= "" then
              run_in_terminal("cargo asm " .. args)
            end
          end)
        end, vim.tbl_extend("force", opts, { desc = "View Assembly (cargo-show-asm)" }))

        vim.keymap.set("n", "<leader>rR", function()
          vim.ui.input({
            prompt = "Run command: ",
          }, function(cmd)
            if cmd and cmd ~= "" then
              run_in_terminal(cmd)
            end
          end)
        end, vim.tbl_extend("force", opts, { desc = "Custom Run Command" }))

        -- Repeat last custom command
        _G.rust_last_cmd = _G.rust_last_cmd or "cargo run"
        vim.keymap.set("n", "<leader>rL", function()
          vim.ui.input({
            prompt = "Run command: ",
            default = _G.rust_last_cmd,
          }, function(cmd)
            if cmd and cmd ~= "" then
              _G.rust_last_cmd = cmd
              run_in_terminal(cmd)
            end
          end)
        end, vim.tbl_extend("force", opts, { desc = "Repeat Last Command" }))

        -- LSP Diagnostic & Status Commands
        vim.keymap.set("n", "<leader>rI", function()
          -- Show LSPInfo window with all client details
          vim.cmd("LspInfo")
        end, vim.tbl_extend("force", opts, { desc = "LSP Info" }))

        vim.keymap.set("n", "<leader>rS", function()
          -- Restart rust-analyzer LSP
          vim.cmd("LspRestart rust-analyzer")
          vim.notify("Restarting rust-analyzer...", vim.log.levels.INFO)
        end, vim.tbl_extend("force", opts, { desc = "Restart LSP" }))

        vim.keymap.set("n", "<leader>rO", function()
          -- Open LSP log file
          vim.cmd("LspLog")
        end, vim.tbl_extend("force", opts, { desc = "Open LSP Log" }))

        vim.keymap.set("n", "<leader>rC", function()
          -- Clear rust-analyzer cache and restart
          vim.ui.select(
            { "Yes, clear cache and restart", "No, cancel" },
            { prompt = "Clear rust-analyzer cache? This will trigger re-indexing." },
            function(choice)
              if choice and choice:match("^Yes") then
                local cache_dir = vim.fn.stdpath("cache") .. "/rust-analyzer"
                vim.fn.delete(cache_dir, "rf")
                vim.cmd("LspRestart rust-analyzer")
                vim.notify("Cache cleared. rust-analyzer will re-index workspace.", vim.log.levels.WARN)
              end
            end
          )
        end, vim.tbl_extend("force", opts, { desc = "Clear Cache & Restart" }))

        vim.keymap.set("n", "<leader>rH", function()
          -- Toggle inlay hints
          if vim.lsp.inlay_hint then
            local current = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not current, { bufnr = bufnr })
            vim.notify(
              "Inlay hints " .. (current and "disabled" or "enabled"),
              vim.log.levels.INFO
            )
          else
            vim.notify("Inlay hints not supported", vim.log.levels.WARN)
          end
        end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))

        vim.keymap.set("n", "<leader>rL", function()
          vim.lsp.codelens.run()
        end, vim.tbl_extend("force", opts, { desc = "Run Code Lens" }))

        vim.keymap.set("n", "<leader>rP", function()
          -- Show LSP progress/status
          local all_clients = vim.lsp.get_clients and vim.lsp.get_clients() or vim.lsp.get_active_clients()
          local client = nil

          for _, c in ipairs(all_clients) do
            if c.name == "rust-analyzer" then
              client = c
              break
            end
          end

          if not client then
            vim.notify("rust-analyzer not attached", vim.log.levels.WARN)
            return
          end

          local info = {
            "rust-analyzer Status:",
            "─────────────────────────",
            string.format("State: %s", client.initialized and "Running" or "Starting..."),
            string.format("Root: %s", client.config.root_dir or "N/A"),
            "",
            "Tip: Use :messages to see indexing activity",
            "     Use <leader>rO to view full LSP log",
            "     Use <leader>rI to see detailed LSP info",
          }

          -- Create floating window
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, info)

          local width = 50
          local height = #info
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "cursor",
            width = width,
            height = height,
            row = 1,
            col = 0,
            style = "minimal",
            border = "rounded",
          })

          -- Close on any key
          vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
          vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
        end, vim.tbl_extend("force", opts, { desc = "Show LSP Status" }))
      end,
    })
  end,
}
