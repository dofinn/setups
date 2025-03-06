vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex)
vim.keymap.set("n", "<leader>la", vim.cmd.Lazy)
vim.keymap.set("n", "<CR><leader>", vim.cmd.Auto)
vim.keymap.set("t", "<esc>", "<C-\\><C-N>")
vim.keymap.set("t", "<C-K>", "<C-\\><C-N><C-w-k>")
vim.keymap.set("t", "<C-J>", "<C-\\><C-N><C-w-j>")
vim.keymap.set("t", "<C-H>", "<C-\\><C-N><C-w-h>")
vim.keymap.set("t", "<C-L>", "<C-\\><C-N><C-w-l>")

-- swap current line with below line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
