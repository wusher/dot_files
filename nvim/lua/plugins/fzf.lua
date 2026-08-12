return {
  "ibhagwan/fzf-lua",
  opts = {
    -- find files (<leader><leader>): always case-insensitive match,
    -- not fzf's default smart-case (which only ignores case for all-lowercase queries)
    files = {
      fzf_opts = { ["--ignore-case"] = true },
    },
  },
}
