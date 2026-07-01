# AGENTS.md

Guidance for AI agents working in this repository.

## Overview

This is a personal dotfiles repository. Configuration files for various development tools are managed as symlinks into `$HOME` using [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow "package" whose internal layout mirrors the target location under `$HOME`.

`setup.sh` orchestrates installation: it installs the underlying tool (where applicable), then runs `stow` to link the package's files into place.

## Repository layout

Each package directory mirrors the paths it will occupy relative to `$HOME`:

| Package      | Links to                              | What it configures |
|--------------|---------------------------------------|--------------------|
| `nvim/`      | `~/.config/nvim/`                     | Neovim (Lua config, lazy.nvim plugins) |
| `tmux/`      | `~/.tmux.conf`                        | tmux |
| `bash/`      | `~/.bashrc.d/`                        | Bash (sourced via `~/.bashrc.d/`) |
| `vscode/`    | `~/.config/Code/User/`                | VSCode settings & keybindings |
| `code-flags/`| `~/.config/code-flags.conf`           | VSCode/Electron launch flags (Wayland) |
| `obsidian/`  | `~/.obsidian.vimrc`                   | Obsidian Vim keybindings |

Git is configured imperatively (aliases + default editor) by `setup.sh git`, not via a Stow package.

## Working with this repo

- **Editing config**: Edit files in place within their package directory. Because Stow creates symlinks, changes are reflected immediately in the linked location (no re-stow needed for edits to existing files).
- **Adding a new file** to a package: the file will be picked up on the next `stow -R` (i.e. `./setup.sh <package>`).
- **Adding a new package**: create a directory mirroring the target `$HOME` layout, then add a corresponding `*_setup()` function and `case` entry in `setup.sh`, plus a `create_symlinks "<package>"` call.
- **`setup.sh` must be idempotent** unless otherwise specified: running any command repeatedly should be safe and converge to the same state (e.g. detect already-installed tools, guard against duplicate edits to files like `~/.bashrc`). Preserve this property when adding or modifying setup logic.
- **Neovim plugins** are managed by lazy.nvim; `nvim/.config/nvim/lazy-lock.json` pins versions. Plugin specs live in `nvim/.config/nvim/lua/plugins/`.
- Keep `README.md` in sync when adding or meaningfully changing a component — it documents each component's features and keybindings for humans.

## Commit conventions

This repository uses [Angular-style Conventional Commits](https://www.conventionalcommits.org/), with a bracketed scope tag identifying the configuration being changed.

Format:

```
<type>: [<scope>] <description>
```

- **type** — one of `feat`, `fix`, `chore`, `style`, `docs`, `refactor`, etc.
- **scope** — the configuration component in square brackets: `[nvim]`, `[tmux]`, `[bash]`, `[vscode]`, `[git]`, `[obsidian]`, etc. Omit the scope only for repo-wide changes (e.g. `chore: update README`).
- **description** — imperative, lower-case, no trailing period.

Examples (from history):

```
feat: [nvim] configure gitlinker
fix: [nvim] bump formatter timeout
style: [nvim] change to onedark theme
chore: [tmux] bind prefix to M-space to avoid conflict with blink.cmp
chore: update README
```
