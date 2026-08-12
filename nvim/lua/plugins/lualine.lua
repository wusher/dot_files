return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local icons = require("lazyvim.config").icons
    return {
      options = {
        theme = "auto",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "branch",
            fmt = function(str)
              if #str > 25 then
                return str:sub(1, 15) .. "..." .. str:sub(-10)
              end
              return str
            end,
          },
        },
        lualine_c = {
          {
            "filename",
            path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
          },
        },
        lualine_x = {
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
          {
            "filetype",
            icon_only = true,
          },
        },
        lualine_y = {
          {
            function()
              if vim.bo.modified then
                return "●"
              elseif vim.bo.readonly then
                return ""
              end
              return "✓"
            end,
            color = function()
              if vim.bo.modified then
                return { fg = require("snacks.util").color("DiagnosticError") }
              elseif vim.bo.readonly then
                return { fg = require("snacks.util").color("DiagnosticWarn") }
              end
              return { fg = require("snacks.util").color("DiagnosticOk") }
            end,
          },
        },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    }
  end,
}
