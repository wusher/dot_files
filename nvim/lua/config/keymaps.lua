-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set({ "n", "v" }, ";", ":", { desc = "Command-line mode" })
vim.keymap.set("n", "Y", "yy", { desc = "Yank full line" })
vim.keymap.set("n", "<leader><space>", function()
  Snacks.picker.files({ matcher = { ignorecase = true, smartcase = false } })
end, { desc = "Find Files (Root Dir)" })

vim.keymap.set("n", "<leader>fI", function()
  Snacks.picker.files({ hidden = true, ignored = true })
end, { desc = "Find Files (incl. gitignored)" })

local function current_file_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("No file for current buffer", vim.log.levels.WARN)
    return nil
  end
  return vim.fn.fnamemodify(path, ":p")
end

local function url_encode_path(path)
  path = path:gsub("\\", "/")
  return (path:gsub("([^%w%-_%.~/])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

vim.api.nvim_create_user_command("CopyRelativeUrl", function()
  local abs_path = current_file_path()
  if not abs_path then
    return
  end

  local rel_path = vim.fn.fnamemodify(abs_path, ":.")
  local relative_url = url_encode_path(rel_path)

  vim.fn.setreg("+", relative_url)
  vim.fn.setreg('"', relative_url)
  vim.notify("Copied relative URL: " .. relative_url)
end, { desc = "Copy current file path as relative URL" })

vim.api.nvim_create_user_command("OpenInDefaultEditor", function()
  local abs_path = current_file_path()
  if not abs_path then
    return
  end

  local ok = pcall(vim.ui.open, abs_path)
  if ok then
    return
  end

  if vim.fn.has("mac") == 1 then
    vim.fn.jobstart({ "open", abs_path }, { detach = true })
  elseif vim.fn.has("win32") == 1 then
    vim.fn.jobstart({ "cmd", "/c", "start", "", abs_path }, { detach = true })
  else
    vim.fn.jobstart({ "xdg-open", abs_path }, { detach = true })
  end
end, { desc = "Open current file in system default editor" })
