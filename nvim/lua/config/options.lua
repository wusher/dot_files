-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Put mise shims first so LSP servers (ruby-lsp, etc.) use the project's tool versions
local mise_shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(mise_shims) == 1 then
  vim.env.PATH = mise_shims .. ":" .. vim.env.PATH
end
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.cursorlineopt = "line,number"

vim.diagnostic.config({ virtual_text = false })
