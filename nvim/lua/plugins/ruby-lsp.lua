-- Mason bakes the ruby version that was active at install time into the
-- shebang of its binstubs, so its ruby tools break every time ruby is
-- upgraded (Bundler::RubyVersionMismatch). Run them out of the bundle instead,
-- and keep Mason from reinstalling the ones it owns.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          mason = false,
          cmd = { "bundle", "exec", "ruby-lsp" },
        },
        rubocop = {
          mason = false,
          cmd = { "bundle", "exec", "rubocop", "--lsp" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- erb-lint is dead weight here: nvim-lint is disabled in this config.
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return pkg ~= "erb-lint"
      end, opts.ensure_installed or {})
    end,
  },
}
