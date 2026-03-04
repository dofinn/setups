-- Debug helper to check active LSP clients
-- Usage: :lua require('dofinn.debug-lsp').check_rust_clients()

local M = {}

function M.check_rust_clients()
  local clients = vim.lsp.get_clients()
  local rust_clients = {}

  for _, client in ipairs(clients) do
    if client.name:match("rust") then
      table.insert(rust_clients, {
        name = client.name,
        id = client.id,
        root_dir = client.config.root_dir,
      })
    end
  end

  print("Active Rust LSP clients: " .. #rust_clients)
  for _, client in ipairs(rust_clients) do
    print(string.format("  [%d] %s (root: %s)", client.id, client.name, client.root_dir))
  end

  if #rust_clients > 1 then
    print("\n⚠️  Warning: Multiple Rust LSP clients detected!")
    print("This may cause duplicate results in Telescope")
  end
end

return M
