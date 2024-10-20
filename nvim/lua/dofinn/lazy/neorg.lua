return {
  "nvim-neorg/neorg",
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = "*", -- Pin Neorg to the latest stable release
  dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-neorg/neorg-telescope" } },
  config = function ()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.export"] = {},
        ["core.todo-introspector"] = {},
        ["core.concealer"] = {
          config = {
            folds = false,
          },
        },
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/notes",
            },
          },
        },
        ["core.integrations.telescope"] = {},
      },
    })
    vim.keymap.set("n", "<localleader>lf", "<Plug>(neorg.telescope.find_linkable)")
    vim.keymap.set("n", "<localleader>li", "<Plug>(neorg.telescope.insert_link)")
    vim.keymap.set("n", "<localleader>lf", "<Plug>(neorg.telescope.insert_file_link)")
    vim.keymap.set("n", "<localleader>ws", "<Plug>(neorg.telescope.switch_workspace)")
    vim.keymap.set("n", "<localleader>sh", "<Plug>(neorg.telescope.search_headings)")
  end
}
