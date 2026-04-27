-- Fix for nvim-treesitter site directory runtimepath issue
local site_path = vim.fn.stdpath("data") .. "/site"
if not vim.tbl_contains(vim.opt.rtp:get(), site_path) then
  vim.opt.rtp:prepend(site_path)
end

-- Safeguard for highlight groups to prevent Snacks/Noice from crashing
-- during health checks when they try to index nil colors.
vim.api.nvim_set_hl(0, "Normal", { fg = "#cad3f5", bg = "#24273a" })
vim.api.nvim_set_hl(0, "SnacksNormal", { fg = "#cad3f5", bg = "#24273a" })

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
