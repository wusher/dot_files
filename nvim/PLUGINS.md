# Neovim plugins

This config is [LazyVim](https://www.lazyvim.org/). Most plugins come from LazyVim
itself. Only the files in this folder are mine.

Plugins are **not** committed to this repo. `lazy.nvim` downloads them on first
start. There is no lock file here on purpose, so a fresh machine gets the latest
version of everything.

## New machine setup

Run this from the repo root:

```
rake -f Rakefile.rb nvim
```

That clones the LazyVim starter into `~/.config/nvim`, then links my files over
the top of it. Then open `nvim`. Lazy downloads every plugin listed below. It
takes a minute or two the first time.

## Plugins I add

These are not in LazyVim. They only exist because a file here asks for them.

| Plugin | File | What it does |
| --- | --- | --- |
| `catppuccin/nvim` | `lua/plugins/colorscheme.lua` | Colors. Set to the `catppuccin-macchiato` flavor. |
| `vimwiki/vimwiki` | `lua/plugins/vimwiki.lua` | Wiki links in my Obsidian career notes. |
| `command-palette` | `lua/plugins/command-palette.lua` | My own plugin. Not downloaded. See below. |

### The local plugin

`command-palette` is loaded off my disk, not off GitHub:

```lua
dir = "/Users/wusher/src/cybersyn",
```

On a new machine that folder will not exist and Lazy will complain. Either clone
`cybersyn` to that path first, or delete `lua/plugins/command-palette.lua`.

## Plugins I turn off

| Plugin | File | Why |
| --- | --- | --- |
| `akinsho/bufferline.nvim` | `lua/plugins/disable-bufferline.lua` | No tab bar wanted. |
| `mfussenegger/nvim-lint` | `lua/plugins/disable-linting.lua` | LSP already reports problems. |

## Plugins I only reconfigure

These already ship with LazyVim. My files change their settings, they do not add
them.

| Plugin | File | Change |
| --- | --- | --- |
| `ibhagwan/fzf-lua` | `lua/plugins/fzf.lua` | File search always ignores case. |
| `nvim-lualine/lualine.nvim` | `lua/plugins/lualine.lua` | Status bar layout, saved/unsaved dot. |
| `folke/snacks.nvim` | `lua/plugins/zen.lua` | Zen mode: solid sides, no dimming. |
| `neovim/nvim-lspconfig` | `lua/plugins/ruby-lsp.lua` | Ruby LSP runs through `bundle exec`. |
| `mason-org/mason.nvim` | `lua/plugins/ruby-lsp.lua` | Stops it installing `erb-lint`. |

## LazyVim extras

`lazyvim.json` lists the LazyVim extras that are switched on. Each extra is a
bundle of plugins that LazyVim maintains. Right now that is:

- AI: `claudecode`
- Editor: `fzf`, `harpoon2`, `illuminate`, `mini-diff`, `navic`
- Languages: `json`, `markdown`, `ruby`, `sql`, `tailwind`, `typescript`, `yaml`
- UI: `mini-animate`, `mini-indentscope`, `treesitter-context`
- Utils: `dot`, `mini-hipatterns`

Do not hand edit that file. Turn extras on and off inside nvim with `:LazyExtras`,
then commit the change it makes.

## How to add a plugin

### 1. Make a file

One file per plugin, in `lua/plugins/`. Name it after the plugin.

```
nvim/lua/plugins/my-plugin.lua
```

Do **not** create it in `~/.config/nvim/lua/plugins/`. That folder is not tracked.
Files there are lost when the machine is rebuilt.

### 2. Write the spec

The file returns a table. The first string is the GitHub `owner/repo`.

```lua
return {
  "owner/repo",
  opts = {},
}
```

`opts` is the plugin's settings. An empty table is fine and means "use the
defaults, but do turn it on".

Common extra keys:

| Key | Use it for |
| --- | --- |
| `keys` | Keys that load the plugin the first time they are pressed. |
| `dependencies` | Other plugins that must load first. |
| `event` | Load on an event instead, like `"VeryLazy"`. |
| `lazy = false` | Load at startup. Slower. Only if the plugin needs it. |
| `priority = 1000` | Load before everything else. Colorschemes need this. |

### 3. Link it

New files are not picked up on their own. Add the path to `@nvim_files` in
`Rakefile.rb`, then run the task again:

```
rake -f Rakefile.rb nvim
```

This is the step that is easy to forget.

### 4. Restart nvim

Lazy sees the new file and downloads the plugin. Run `:Lazy` to watch it or to
check for errors.

## How to change a LazyVim plugin

Same steps, but leave out any keys you do not want to change. LazyVim merges your
`opts` into its own.

```lua
return {
  "folke/which-key.nvim",
  opts = {
    delay = 500,
  },
}
```

Everything else about `which-key` stays as LazyVim set it.

## How to turn a plugin off

```lua
return {
  { "owner/repo", enabled = false },
}
```

## Hardcoded paths

Two files point at folders that only exist on my Mac. Fix these on a new machine.

| File | Path |
| --- | --- |
| `lua/plugins/command-palette.lua` | `/Users/wusher/src/cybersyn` |
| `lua/plugins/vimwiki.lua` | `/Users/wusher/Obsidian/Primary/4_career/notes/` |
