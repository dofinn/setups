return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio', -- Required for nvim-dap-ui
    'jay-babu/mason-nvim-dap.nvim', -- Auto-install debug adapters
  },
  config = function()
    -- ── Adapter installation ──────────────────────────────────────────────
    -- mason-nvim-dap auto-downloads codelldb (Rust/C/C++) and debugpy (Python)
    -- into ~/.local/share/nvim/mason/. Without this you'd have to install them
    -- manually and point dap.adapters at the binaries yourself.
    require('mason-nvim-dap').setup({
      ensure_installed = { 'codelldb', 'debugpy' },
      automatic_installation = true,
    })

    local dap = require('dap')

    -- ── codelldb adapter (Rust / C / C++) ────────────────────────────────
    -- codelldb is an LLDB wrapper that speaks the DAP protocol. It runs as a
    -- local server on a random port; Neovim connects to it as a client.
    -- mason-nvim-dap installs the binary but doesn't wire up the command,
    -- so we do it manually here.
    dap.adapters.codelldb = {
      type = 'server',
      port = "${port}",
      executable = {
        command = vim.fn.expand('~/.local/share/nvim/mason/bin/codelldb'),
        args = { "--port", "${port}" },
      }
    }

    -- ── Rust release debug configuration ─────────────────────────────────
    -- rust-analyzer only generates non-release debuggables. This config lets
    -- codelldb do a `cargo build --release` first, then debug the output binary.
    -- Accessible via <Leader>dc (shows all configs) rather than <Leader>rd
    -- (rust-analyzer runnables only). Prompts for binary name, defaulting to
    -- the workspace directory name.
    dap.configurations.rust = {
      {
        type    = 'codelldb',
        request = 'launch',
        name    = 'Debug binary (release)',
        cargo   = function()
          local default = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
          local bin     = vim.fn.input('Binary name: ', default)
          if bin == '' then return vim.NIL end
          return {
            args   = { 'build', '--release', '--bin', bin, '--all-features' },
            filter = { name = bin, kind = 'bin' },
          }
        end,
        cwd         = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    -- ── debugpy adapter (Python) ──────────────────────────────────────────
    -- debugpy is the standard Python debug adapter (used by VS Code too).
    -- It runs as a Python subprocess; the adapter speaks DAP over stdio.
    dap.adapters.python = {
      type = 'executable',
      command = vim.fn.expand('~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'),
      args = { '-m', 'debugpy.adapter' },
    }

    -- ── Python launch configurations ─────────────────────────────────────
    -- These appear in the picker when you hit <Leader>dc on a .py file.
    -- "Launch file" runs the current buffer. "with arguments" prompts for
    -- CLI args first. Both prefer the active virtualenv if VIRTUAL_ENV is set.
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          local venv = vim.fn.getenv('VIRTUAL_ENV')
          if venv ~= vim.NIL and venv ~= '' then
            return venv .. '/bin/python'
          else
            return '/usr/bin/python3'
          end
        end,
      },
      {
        type = 'python',
        request = 'launch',
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input('Arguments: ')
          return vim.split(args_string, " +")
        end,
        pythonPath = function()
          local venv = vim.fn.getenv('VIRTUAL_ENV')
          if venv ~= vim.NIL and venv ~= '' then
            return venv .. '/bin/python'
          else
            return '/usr/bin/python3'
          end
        end,
      },
    }

    local dapui = require('dapui')

    -- ── DAP UI panels ─────────────────────────────────────────────────────
    -- dapui manages persistent side/bottom panels that update as you step:
    --   stacks  – the current call stack (frames you can jump between)
    --   watches – expressions you type in manually that re-evaluate each step
    --             (e.g. type "my_vec.len()" and it'll show the value live)
    --   scopes  – all local variables and their current values in the active frame
    --
    -- Console removed: it mostly echoes adapter noise. Use <Leader>dr (REPL)
    -- for interactive evaluation instead.
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
          -- Left panel: call stack + watch expressions (narrower without console)
          elements = {
            { id = "stacks",  size = 0.6 },
            { id = "watches", size = 0.4 },
          },
          size = 25,
          position = "left",
        },
        {
          -- Bottom panel: all locals/variables for the current stack frame
          elements = {
            { id = "scopes" },
          },
          size = 15,
          position = "bottom",
        },
      },
    })

    -- ── Virtual text ──────────────────────────────────────────────────────
    -- Shows variable values as inline ghost text next to the relevant line
    -- in your source buffer while stopped at a breakpoint. Requires no extra
    -- interaction — values just appear as you step.
    require('nvim-dap-virtual-text').setup()

    -- ── Disassembly panel ─────────────────────────────────────────────────
    -- Manual buffer+window approach instead of widgets.sidebar() — gives us
    -- direct control over open/render timing so it reliably appears on step.
    --
    -- The buffer is created once at startup and reused across sessions; only
    -- the window is created/destroyed. equalalways is disabled before the
    -- split so the left dapui panels don't get squashed when the right split
    -- appears.
    local asm_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[asm_buf].buftype  = 'nofile'
    vim.bo[asm_buf].filetype = 'asm'
    vim.api.nvim_buf_set_name(asm_buf, 'dap-disassembly')

    local asm_win = nil

    local function asm_is_open()
      return asm_win ~= nil and vim.api.nvim_win_is_valid(asm_win)
    end

    local function asm_open()
      if asm_is_open() then return end
      -- Find the main source window (a normal file buffer, not a dapui/nofile panel).
      -- We split that window specifically so dapui's left panel is untouched.
      local source_win = nil
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == '' then
          source_win = win
          break
        end
      end
      if not source_win then return end

      local prev_win    = vim.api.nvim_get_current_win()
      local prev_ea     = vim.o.equalalways
      vim.o.equalalways = false
      vim.api.nvim_set_current_win(source_win)
      vim.cmd('rightbelow 60 vsplit')
      asm_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(asm_win, asm_buf)
      vim.wo[asm_win].number         = false
      vim.wo[asm_win].relativenumber = false
      vim.wo[asm_win].statusline     = ' Disassembly '
      vim.o.equalalways = prev_ea
      vim.api.nvim_set_current_win(prev_win)
    end

    local function asm_close()
      if asm_is_open() then
        vim.api.nvim_win_close(asm_win, true)
      end
      asm_win = nil
    end

    local function asm_render()
      local session = dap.session()
      if not session then return end
      local frame = session.current_frame
      if not frame or not frame.instructionPointerReference then
        vim.bo[asm_buf].modifiable = true
        vim.api.nvim_buf_set_lines(asm_buf, 0, -1, false, { 'Run to a breakpoint to see disassembly' })
        vim.bo[asm_buf].modifiable = false
        return
      end
      session:request('disassemble', {
        memoryReference   = frame.instructionPointerReference,
        instructionOffset = -10,
        instructionCount  = 30,
        resolveSymbols    = true,
      }, function(err, response)
        vim.schedule(function()
          if err or not response then
            vim.bo[asm_buf].modifiable = true
            vim.api.nvim_buf_set_lines(asm_buf, 0, -1, false, { 'Error: ' .. vim.inspect(err) })
            vim.bo[asm_buf].modifiable = false
            return
          end
          local lines        = {}
          local current_line = 1
          for i, instr in ipairs(response.instructions) do
            local marker = (instr.address == frame.instructionPointerReference) and '>' or ' '
            if marker == '>' then current_line = i end
            local sym = instr.symbol and (' <' .. instr.symbol .. '>') or ''
            table.insert(lines, string.format('%s %s%s  %s', marker, instr.address, sym, instr.instruction))
          end
          vim.bo[asm_buf].modifiable = true
          vim.api.nvim_buf_set_lines(asm_buf, 0, -1, false, lines)
          vim.bo[asm_buf].modifiable = false
          if asm_is_open() then
            vim.api.nvim_win_set_cursor(asm_win, { current_line, 0 })
          end
        end)
      end)
    end

    -- ── Auto open / close ─────────────────────────────────────────────────
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end

    -- Use the `scopes` event rather than `event_stopped`: scopes fires after
    -- nvim-dap has fetched the stack frames, so current_frame and
    -- instructionPointerReference are actually populated by this point.
    -- event_stopped fires earlier, before frame data is available.
    dap.listeners.after.scopes["dap_asm"] = function()
      vim.schedule(function()
        asm_open()
        asm_render()
      end)
    end

    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
      asm_close()
      dap.listeners.after.scopes["dap_asm"] = nil
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
      asm_close()
      dap.listeners.after.scopes["dap_asm"] = nil
    end

    -- ── Keybindings ───────────────────────────────────────────────────────

    -- Continue / start
    vim.keymap.set('n', '<F5>',       function() dap.continue() end,    { desc = "Continue" })
    vim.keymap.set('n', '<Leader>dc', function() dap.continue() end,    { desc = "Continue" })

    -- Step over: advance one source line, don't descend into calls
    vim.keymap.set('n', '<F10>',      function() dap.step_over() end,   { desc = "Step Over" })
    vim.keymap.set('n', '<Leader>dn', function() dap.step_over() end,   { desc = "Step Over (Next)" })

    -- Step into: descend into the function call on the current line
    vim.keymap.set('n', '<F11>',      function() dap.step_into() end,   { desc = "Step Into" })
    vim.keymap.set('n', '<Leader>di', function() dap.step_into() end,   { desc = "Step Into" })

    -- Step out: finish the current function and stop at its call site
    vim.keymap.set('n', '<F12>',      function() dap.step_out() end,    { desc = "Step Out" })
    vim.keymap.set('n', '<Leader>do', function() dap.step_out() end,    { desc = "Step Out" })

    -- Breakpoints
    vim.keymap.set('n', '<Leader>b',  function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
    vim.keymap.set('n', '<Leader>B',
      function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
      { desc = "Conditional Breakpoint" })

    -- UI controls
    vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end,   { desc = "Open REPL" })
    vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end,    { desc = "Run Last" })
    vim.keymap.set('n', '<Leader>dq', function() dap.terminate() end,   { desc = "Quit/Terminate Debug" })
    vim.keymap.set('n', '<Leader>du', function() dapui.toggle() end,    { desc = "Toggle DAP UI" })

    -- Manually toggle the disassembly panel
    vim.keymap.set('n', '<Leader>dA', function()
      if asm_is_open() then
        asm_close()
      else
        asm_open()
        asm_render()
      end
    end, { desc = "Toggle Disassembly" })
  end,
}
