# Dotfiles
A collection of configuration files for various development tools. This repository uses GNU Stow to manage symlinks to configuration files.

## Components

### Neovim
- A minimal configuration with sensible defaults. The focus is on providing a productive environment for editing small projects in the terminal, without requiring a lot of dependencies. Specific features include:
  * File navigation with nvim-tree
  * Fuzzy finder with fzf-lua
  * Treesitter for improved syntax highlighting
  * Integration with tmux
  * Indentation detection and formatting

### Tmux
- Custom keybindings with a focus on Vim style navigation:
  * `ctrl-space` as prefix (instead of default `ctrl-b`)
  * `ctrl-alt + arrow/vim keys` -> resize panes
  * `alt-shift + vim keys` -> swap panes
  * `alt + h/l` or `number/vim keys` -> navigate windows
- Mouse mode enabled
- 256 color support
- Increased history limit
- Custom status bar

### Bash
- Enhanced history settings:
  * Extra large bash history
  * Timestamped history entries
  * History search with up/down arrows
- Custom configuration directory structure with `~/.bashrc.d/`

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

### Git
- Custom aliases for recent branch navigation using fzf

### Obsidian
- Vim keybindings for Obsidian note-taking app:
  * System clipboard integration with `set clipboard=unnamed`
  * Unmap space key to allow for custom mappings and simulate the use of space as leader key
  * `<Space>q` opens context menu (for spell check corrections and more)

## Installation

The repository includes a setup script that can install and configure various components:

```bash
# Show available commands
./setup.sh help

# Install and configure tmux
./setup.sh tmux

# Install Neovim AppImage
./setup.sh nvim

# Configure bash with custom settings
./setup.sh bash

# Install JetBrains Mono Nerd Font
./setup.sh nerdfont

# Install terminal color schemes
./setup.sh terminal-colors
```

## Usage

1. Clone this repository to your home directory:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the setup script with desired components:
   ```bash
   ./setup.sh tmux
   ./setup.sh nvim
   ./setup.sh bash
   ```

3. To manually create symlinks for a specific package:
   ```bash
   stow -R -v -t $HOME nvim
   ```
