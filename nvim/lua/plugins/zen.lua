return {
  "folke/snacks.nvim",
  opts = {
    zen = {
      -- disable paragraph focus (Snacks.dim dims code out of scope)
      -- toggles config is NOT merged, so keep the other defaults here too
      toggles = {
        dim = false,
        git_signs = false,
        mini_diff_signs = false,
      },
    },
    styles = {
      zen = {
        -- solid sides matching the editor background color
        -- bg is the Normal highlight bg; update if the colorscheme changes
        backdrop = { transparent = false, bg = "#24273a", blend = 0 },
      },
    },
  },
}
