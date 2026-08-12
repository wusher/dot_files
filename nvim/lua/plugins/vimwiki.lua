local career_notes = vim.fn.expand("/Users/wusher/Obsidian/Primary/4_career/notes/")

return {
  {
    "vimwiki/vimwiki",
    lazy = false,
    init = function()
      vim.g.vimwiki_list = {
        {
          path = career_notes,
          syntax = "markdown",
          ext = "md",
          index = "index",
          diary_rel_path = "diary/",
        },
      }
      vim.g.vimwiki_global_ext = 0
    end,
  },
}
