vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex)
vim.keymap.set("n", "<leader>la", vim.cmd.Lazy)
vim.keymap.set("n", "<CR><leader>", vim.cmd.Auto)

-- swap current line with below line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
