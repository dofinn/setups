local parsers = {
  "lua",
  "vim",
  "vimdoc",
  "javascript",
  "html",
  "python",
  "go",
  "terraform",
  "hcl",
  "typescript",
  "zig",
  "rust",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup()
      treesitter.install(parsers)

      -- Highlighting and indentation are native Neovim features in the
      -- rewritten nvim-treesitter API, so enable them per supported filetype.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match) or args.match
          if not pcall(vim.treesitter.start, args.buf, language) then
            return
          end

          if vim.treesitter.query.get(language, "indents") then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
        select = { lookahead = true },
      })

      local move = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")

      local move_mappings = {
        ["]m"] = { move.goto_next_start, "@function.outer" },
        ["]]"] = { move.goto_next_start, "@class.outer" },
        ["]M"] = { move.goto_next_end, "@function.outer" },
        ["]["] = { move.goto_next_end, "@class.outer" },
        ["[m"] = { move.goto_previous_start, "@function.outer" },
        ["[["] = { move.goto_previous_start, "@class.outer" },
        ["[M"] = { move.goto_previous_end, "@function.outer" },
        ["[]"] = { move.goto_previous_end, "@class.outer" },
      }

      for key, mapping in pairs(move_mappings) do
        local move_to, query = mapping[1], mapping[2]
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move_to(query, "textobjects")
        end)
      end

      local select_mappings = {
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
      }

      for key, query in pairs(select_mappings) do
        local textobject = query
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(textobject, "textobjects")
        end)
      end
    end,
  },
}
