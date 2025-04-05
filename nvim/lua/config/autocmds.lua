-- Format TypeScript files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.json" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
