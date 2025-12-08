return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio', -- Required for nvim-dap-ui
    'jay-babu/mason-nvim-dap.nvim', -- Auto-install debug adapters
  },
  config = function()
    -- Setup mason-nvim-dap first to install codelldb
    require('mason-nvim-dap').setup({
      ensure_installed = { 'codelldb' },
      automatic_installation = true,
      handlers = {},
    })

    local dap = require('dap')
    local dapui = require('dapui')

    -- Setup DAP UI
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 10,
          position = "bottom",
        },
      },
    })

    -- Setup virtual text
    require('nvim-dap-virtual-text').setup()

    -- Auto open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Keybindings for debugging
    vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = "Continue" })
    vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "Step Over" })
    vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "Step Into" })
    vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = "Step Out" })
    vim.keymap.set('n', '<Leader>b', function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
    vim.keymap.set('n', '<Leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
      { desc = "Conditional Breakpoint" })
    vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end, { desc = "Open REPL" })
    vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end, { desc = "Run Last" })
  end,
}
