# Dotfiles
A collection of configuration files for various development tools. This repository uses GNU Stow to manage symlinks to configuration files.

## Components

### Neovim
- A single-file Neovim 0.12+ configuration using the built-in `vim.pack` package manager and a committed lockfile. The focus is on providing a productive environment for editing small projects in the terminal, without requiring a lot of dependencies. Specific features include:
  * Plugin management commands with plugin-name completion:
    - `:PackUpdate` -> review updates for all plugins; use `:write` to apply or `:quit` to cancel
    - `:PackUpdate plugin...` -> review updates for specific plugins
    - `:PackUpdate! [plugin...]` -> apply updates immediately without review
    - `:PackDelete plugin...` -> delete inactive plugins
    - `:PackDelete! plugin...` -> delete plugins even when active in the current session
  * File navigation with nvim-tree
  * Fuzzy finder with fzf-lua using the pinned `fzf` installed by `setup.sh`, including:
    - `<C-p>` -> find files
    - `<C-g>` -> grep project
    - `<C-\>` -> switch buffers
    - `<C-x><C-f>` (insert) -> fuzzy complete file path
    - `<C-x><C-g>` (insert) -> fuzzy insert git commit hash
    - `<C-x><C-a>` (insert) -> fuzzy complete `@file` reference
  * Darker onedark color scheme via onedark.nvim
  * Markdown rendering with render-markdown.nvim
  * Treesitter for improved syntax highlighting
  * Integration with tmux via vim-tmux-navigator
  * Indentation detection with vim-sleuth and formatting with conform.nvim via `<leader>f`
  * Yank to the host clipboard over SSH via OSC52 (forwarded by tmux to the outer terminal)

### Tmux
- Custom keybindings with a focus on Vim style navigation:
  * `ctrl-space` as prefix (instead of default `ctrl-b`)
  * `ctrl-alt + vim keys` -> resize panes
  * `alt-shift + h/l` -> swap windows left/right
  * `alt-shift-g` then `alt-shift + vim keys` -> swap panes
  * `alt + h/l`, `alt + i/o`, or `alt + 0-9` -> navigate windows
  * `ctrl + vim keys` -> navigate between panes and Neovim instances
  * `prefix + T` -> equally size all panes (even-vertical layout)
- Mouse mode enabled
- 256 color support
- OSC52 clipboard forwarding from inner programs (e.g. Neovim) to the outer terminal
- Focus events enabled (needed for Claude Code)
- Extended key support for modern terminals (e.g. shift+enter in Ghostty)
- Increased history limit
- Custom status bar showing session name and hostname

### Bash
- Enhanced history settings:
  * Extra large bash history
  * Timestamped history entries
  * History search with up/down arrows
- Sets Neovim as the default editor
- Custom configuration directory structure with `~/.bashrc.d/`

### Node.js
- Installs and manages Node.js via [nvm](https://github.com/nvm-sh/nvm)
- Installs or updates to the latest LTS Node.js release
- Sets LTS as the default Node.js version
- Loads nvm automatically from `~/.bashrc.d/`

### VSCode

> [!NOTE]
> Configurations can often vary across development environments. This is intended to be a starting point for commonly reused settings.

- Vim extension configuration with custom keybindings:
  * Leader key set to space
  * `gr` -> find references
  * `gi` -> go to implementation
  * `<leader>f` -> format document
  * `<leader>b` -> toggle sidebar visibility
  * `<leader>n` -> open explorer view
  * `ctrl+w` when sidebar is focused -> focus active editor group
- Wayland support via `code-flags.conf` (Ozone platform)

### Git
- Custom aliases for recent branch navigation using fzf (`git recent-switch` / `git rsw`)
- Sets Neovim as the default Git editor
- Installs [delta](https://github.com/dandavison/delta) and sets it as the pager for diffs:
  * Side-by-side view with line numbers
  * Onedark syntax theme (`OneHalfDark`), matching the Neovim colorscheme
  * `n` / `N` to navigate between diff hunks
  * `zdiff3` merge conflict style

### Obsidian
- Vim keybindings for Obsidian note-taking app:
  * System clipboard integration with `set clipboard=unnamed`
  * Unmap space key to allow for custom mappings and simulate the use of space as leader key
  * `<Space>q` opens context menu (for spell check corrections and more)

## Installation
The `setup.sh` script can automate installation and configuration:

```bash
# Show available commands
./setup.sh help

# Available commands:
#   tmux              - Install tmux and tmux plugin manager
#   nvim              - Install Neovim
#                       Options:
#                         --update  Force reinstallation even if already installed
#   node              - Install or update nvm and the latest LTS Node.js
#   bash              - Configure bash with custom settings
#   git               - Configure Git aliases, delta pager, and Neovim as editor
#   nerdfont          - Install JetBrains Mono Nerd Font
#   terminal-colors   - Install terminal color schemes
```
