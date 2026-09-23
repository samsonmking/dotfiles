# Dotfiles

Personal development environment configuration managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package whose contents mirror their destination under `$HOME`.

## Packages

| Package | Destination | Description |
| --- | --- | --- |
| `nvim` | `~/.config/nvim` | Neovim 0.12+ configuration |
| `tmux` | `~/.tmux.conf` | tmux configuration |
| `bash` | `~/.bashrc.d` | Bash history, editor, and nvm setup |
| `vscode` | `~/.config/Code/User` | VSCode settings and keybindings |
| `code-flags` | `~/.config/code-flags.conf` | VSCode Wayland flags |
| `obsidian` | `~/.obsidian.vimrc` | Obsidian Vim keybindings |

Git settings are applied directly by `setup.sh` rather than through Stow.

## Neovim

The Neovim configuration is contained in a single `init.lua`. Plugins are installed with Neovim's built-in `vim.pack` package manager and pinned in `nvim-pack-lock.json`.

### Language support

- LSP servers:
  - `lua_ls` for Lua
  - `tsgo` for JavaScript and TypeScript
  - `ty` for Python
- Mason installs `lua_ls`, `tsgo`, and the `stylua` formatter.
- `ty` must be installed separately and available on `$PATH` for Python LSP support.
- blink.cmp provides LSP, path, and buffer completion with automatic documentation.
- Completion is disabled for Markdown and Git commit messages.
- Diagnostics use virtual text, severity sorting, warning-and-higher underlines, rounded floating windows, and automatic floats after diagnostic jumps.
- Tree-sitter parsers are installed automatically by tree-sitter-manager when a supported filetype is opened.
- Neovim's bundled parsers are reused instead of being installed again.
- Installing additional parsers requires Git, the tree-sitter CLI, and a C compiler; `setup.sh nvim` installs the CLI through npm or Cargo when needed.

LSP keybindings:

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `<leader>q` | Open diagnostics in the location list |

### Formatting

Conform formats supported buffers on save and falls back to LSP formatting when no configured formatter is available.

| Filetype | Formatter |
| --- | --- |
| Lua | `stylua` |
| Python | `ruff_organize_imports`, then `ruff_format` |
| JavaScript and TypeScript | `oxfmt` |

Use `<leader>f` to format the current buffer manually. `ruff` and `oxfmt` must be available on `$PATH` when working with their corresponding languages.

### Navigation and search

| Key | Action |
| --- | --- |
| `<C-n>` | Toggle nvim-tree and reveal the current file |
| `<C-p>` | Open the fzf-lua global picker for files, buffers, and symbols |
| `<C-g>` | Search project text |
| `<C-\>` | Switch buffers |
| `<leader>gs` | Browse files from Git status |
| `<leader>gd` | Browse files from the Git diff |
| `<leader>sh` | Search help tags |
| `<leader>sk` | Search keybindings |
| `<leader>rc` | Reload `init.lua` |
| `<leader>yp` | Copy the current file's relative path |

Insert-mode completion:

| Key | Action |
| --- | --- |
| `<C-x><C-f>` | Fuzzy-complete a file path |
| `<C-x><C-g>` | Insert a Git commit hash |
| `<C-x><C-a>` | Fuzzy-complete an `@file` reference |

fzf-lua uses the system `fzf` binary. `setup.sh nvim` installs the pinned version expected by this configuration.

### Git integration

- gitsigns displays changes and current-line blame.
- `<leader>hd` previews the current hunk inline.
- `<leader>hr` resets the current hunk.
- `<leader>yg` copies a permalink for the current line or visual selection.

### Appearance and editing

- Darker onedark color scheme.
- mini.statusline with Git, diagnostics, LSP, filetype, search, and position information.
- Cursor-line and cursor-word highlighting.
- Indentation guides and automatic indentation detection with vim-sleuth.
- Markdown rendering with render-markdown.nvim.
- Seamless `<C-h/j/k/l>` navigation between Neovim splits and tmux panes.
- English spell checking.
- Per-project `.nvim.lua` files through the `exrc` option.
- OSC52 copy support for remote sessions through tmux and the outer terminal. Paste uses terminal bracketed paste instead.

### Plugin management

The temporary user commands below provide a convenient interface until their built-in equivalents reach the installed stable Neovim release. Plugin names support command-line completion.

| Command | Action |
| --- | --- |
| `:PackUpdate` | Review updates for every plugin |
| `:PackUpdate plugin...` | Review updates for selected plugins |
| `:PackUpdate! [plugin...]` | Apply updates immediately without review |
| `:PackDelete plugin...` | Delete inactive plugins |
| `:PackDelete! plugin...` | Delete plugins even if active in the current session |

In the update review buffer, use `:write` to apply the selected updates or `:quit` to cancel. Commit the resulting `nvim-pack-lock.json` change after updating. A deleted plugin that remains in `init.lua` will be installed again on the next startup.

## tmux

The tmux package uses TPM with tmux-sensible, vim-tmux-navigator, and tmux-yank.

Keybindings:

| Key | Action |
| --- | --- |
| `Alt-Space` | Prefix key |
| `Ctrl-Alt-h/j/k/l` | Resize the current pane |
| `Alt-Shift-h/l` | Move the current window |
| `Alt-Shift-g`, then `Alt-Shift-h/j/k/l` | Move the current pane |
| `Alt-h/l` or `Alt-i/o` | Move between windows |
| `Alt-0` through `Alt-9` | Select a window |
| `Ctrl-h/j/k/l` | Move between tmux panes and Neovim splits |
| `prefix + "` | Split vertically in the current directory |
| `prefix + %` | Split horizontally in the current directory |
| `prefix + r` | Reload the tmux configuration |
| `prefix + T` | Arrange panes in an even vertical layout |

Additional behavior:

- Windows and panes are numbered from 1 and windows are renumbered automatically.
- Vi-style copy mode uses `v` to select, `Ctrl-v` for rectangular selection, and `y` to copy.
- Mouse support, true color, styled underlines, extended keys, focus events, and OSC52 forwarding are enabled.
- Scrollback history is increased to 100,000 lines.
- The status bar displays the session, windows, and hostname.

After the first `./setup.sh tmux`, press `prefix + I` inside tmux to install the configured TPM plugins.

## Bash and Node.js

The Bash package expects `~/.bashrc` to source files from `~/.bashrc.d`; `./setup.sh bash` adds that loader once if necessary.

- Unlimited persistent history in `~/.bash_eternal_history`.
- Timestamps for history entries.
- Up/down-arrow prefix search through history.
- History is appended after every command.
- Neovim is exported as `$EDITOR`.
- nvm and its Bash completion are loaded when installed.

`./setup.sh node` installs or updates nvm, installs the latest Node.js LTS release, and makes that LTS line the default.

## VSCode

- VSCode Vim leader is Space.
- Search highlighting, sticky scroll, and inline suggestions are enabled.
- The minimap and suggestion acceptance on commit characters are disabled.
- `Ctrl-w` returns focus from the sidebar to the active editor.

Vim-mode keybindings:

| Key | Action |
| --- | --- |
| `gr` | Find references |
| `gi` | Go to implementation |
| `<leader>f` | Format the document |
| `<leader>b` | Toggle the sidebar |
| `<leader>n` | Open Explorer |

The `code-flags` package enables VSCode's native Wayland backend through Ozone.

## Git

`./setup.sh git` configures:

- Neovim as the Git editor.
- `git recent-switch` and `git rsw` aliases for selecting recently updated branches with fzf.
- delta as the pager for diffs and interactive commands.
- Line numbers, hunk navigation, a dark OneHalfDark syntax theme, and non-side-by-side output in delta.
- `zdiff3` merge-conflict markers.

## Obsidian

The Obsidian Vim configuration:

- Uses the system clipboard for yanks.
- Frees Space for custom mappings.
- Maps `<Space>q` to the editor context menu for spelling corrections and other actions.

## Installation

Clone the repository, then run setup commands from its root:

```bash
./setup.sh nvim
./setup.sh tmux
./setup.sh bash
./setup.sh node
./setup.sh git
```

Available commands:

| Command | Description |
| --- | --- |
| `./setup.sh nvim [--update]` | Install or update Neovim, tree-sitter CLI, pinned fzf, native plugins, and links |
| `./setup.sh tmux` | Install tmux and TPM, then link the configuration |
| `./setup.sh bash` | Configure `~/.bashrc.d` loading and link Bash files |
| `./setup.sh node [--update]` | Install or update nvm and the latest Node.js LTS |
| `./setup.sh git` | Configure Git aliases, delta, merge style, pager, and editor |
| `./setup.sh nerdfont` | Install JetBrains Mono Nerd Font |
| `./setup.sh terminal-colors` | Run the Gogh terminal color-scheme installer |
| `./setup.sh help` | Show command help |

The setup script supports apt-based and Fedora/RHEL-based systems where applicable. It installs GNU Stow automatically before linking a package.

VSCode, code flags, and Obsidian do not currently have dedicated setup commands. Link them directly with Stow:

```bash
stow -R -d "$PWD" -t "$HOME" vscode code-flags obsidian
```

Running setup commands repeatedly is intended to be safe and converge on the same configuration.
