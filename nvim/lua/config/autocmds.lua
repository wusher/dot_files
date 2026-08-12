-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autosave_group = vim.api.nvim_create_augroup("Autosave", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = autosave_group,
  pattern = "*",
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
  desc = "Autosave on change or insert leave",
})

local crosshair_group = vim.api.nvim_create_augroup("ActiveWindowCrosshair", { clear = true })

local function set_crosshair_highlights()
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "#344a4d", nocombine = true })
  vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#344a4d", nocombine = true })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffd866", bold = true })
end

set_crosshair_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = crosshair_group,
  pattern = "*",
  callback = set_crosshair_highlights,
  desc = "Keep crosshair highlights visible after colorscheme changes",
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
  group = crosshair_group,
  pattern = "*",
  callback = function()
    vim.wo.cursorline = true
    vim.wo.cursorcolumn = true
  end,
  desc = "Enable crosshair in active window",
})

vim.api.nvim_create_autocmd("WinLeave", {
  group = crosshair_group,
  pattern = "*",
  callback = function()
    vim.wo.cursorline = false
    vim.wo.cursorcolumn = false
  end,
  desc = "Disable crosshair in inactive windows",
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = crosshair_group,
  pattern = "*.md",
  callback = function()
    if vim.bo.filetype == "markdown" then
      vim.wo.cursorline = true
      vim.wo.cursorcolumn = true
    end
  end,
  desc = "Keep crosshair enabled while editing markdown",
})
