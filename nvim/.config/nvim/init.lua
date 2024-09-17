-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- https://github.com/neovim/neovim/issues/28058#issuecomment-2146978107
local lsp = vim.lsp

local make_client_capabilities = lsp.protocol.make_client_capabilities

function lsp.protocol.make_client_capabilities()
  local caps = make_client_capabilities()
  if not (caps.workspace or {}).didChangeWatchedFiles then
    vim.notify("lsp capability didChangeWatchedFiles is already disabled", vim.log.levels.WARN)
  else
    caps.workspace.didChangeWatchedFiles = nil
  end

  return caps
end
