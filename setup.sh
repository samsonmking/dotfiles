#!/bin/bash
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Show help menu
show_help() {
    echo "Usage: $0 COMMAND [OPTIONS]"
    echo ""
    echo "Available commands:"
    echo "  tmux              - Install tmux and tmux plugin manager"
    echo "  nvim              - Install Neovim"
    echo "                      Options:"
    echo "                        --update  Force reinstallation even if already installed"
    echo "  node              - Install or update nvm and the latest LTS Node.js"
    echo "  bash              - Configure bash with custom settings"
    echo "  git               - Configure Git aliases, delta pager, and Neovim as editor"
    echo "  nerdfont          - Install JetBrains Mono Nerd Font"
    echo "  terminal-colors   - Install terminal color schemes"
    echo "  help              - Show this help message"
}

# Check and install stow if needed
ensure_stow() {
    if ! command -v stow >/dev/null 2>&1; then
        echo "GNU Stow is not installed. Installing it now..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y stow
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y stow
        else
            echo "Error: Unable to install GNU Stow. Unsupported package manager."
            exit 1
        fi
    fi
}

# Create symlinks using stow
create_symlinks() {
    local package=$1
    echo "Creating symlinks for $package..."
    
    # Ensure stow is installed
    ensure_stow
    
    # Ensure ~/.config exists as a real directory before stowing packages that
    # target paths inside it. If it is missing, stow will fold the tree and
    # create ~/.config -> <package>/.config, pulling unrelated apps into the repo.
    case "$package" in
        nvim|vscode|code-flags)
            mkdir -p "$HOME/.config"
            ;;
    esac
    
    # Use stow to create symlinks
    stow -R -v -d "$SCRIPT_DIR" -t "$HOME" "$package"
    echo "Symlinks created successfully for $package"
}

# Helper function to install Neovim AppImage
install_nvim_appimage() {
    # Detect architecture
    ARCH=$(uname -m)
    
    echo "Installing Neovim from AppImage for $ARCH architecture..."

    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        # ARM64 architecture
        NVIM_RELEASE=https://github.com/neovim/neovim/releases/download/stable/nvim-linux-arm64.appimage
    else
        # x86_64 architecture (default)
        NVIM_RELEASE=https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage
    fi
    
    NVIM_PATH=/usr/local/bin/nvim

    sudo rm -f $NVIM_PATH
    sudo wget $NVIM_RELEASE -O $NVIM_PATH
    sudo chmod +x $NVIM_PATH

    # Only run update-alternatives on Debian-based systems
    if command -v update-alternatives >/dev/null 2>&1; then
        echo "Setting up Neovim as an alternative for editor..."
        sudo update-alternatives --install /usr/bin/editor editor $NVIM_PATH 35 && \
        sudo update-alternatives --set editor $NVIM_PATH
    else
        echo "update-alternatives not found, skipping editor configuration."
    fi
    
    echo "Neovim installation completed via AppImage!"
}

# Remove plugin clones and state left behind by lazy.nvim.
cleanup_legacy_lazy() {
    local nvim_data="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    local nvim_state="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
    local path

    for path in \
        "$nvim_data/lazy" \
        "$nvim_data/lazy-rocks" \
        "$nvim_state/lazy"
    do
        if [ -d "$path" ]; then
            echo "Removing legacy lazy.nvim files from $path..."
            rm -rf -- "$path"
        fi
    done
}

# Retarget tree-sitter query links created before migrating from lazy.nvim.
migrate_legacy_treesitter_queries() {
    local nvim_data="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    local query_dir="$nvim_data/site/queries"
    local legacy_root="$nvim_data/lazy/tree-sitter-manager.nvim/runtime/queries"
    local native_root="$nvim_data/site/pack/core/opt/tree-sitter-manager.nvim/runtime/queries"
    local query_path
    local target
    local language

    if [ ! -d "$query_dir" ] || [ ! -d "$native_root" ]; then
        return
    fi

    for query_path in "$query_dir"/*; do
        if [ ! -L "$query_path" ]; then
            continue
        fi

        target=$(readlink "$query_path")
        case "$target" in
            "$legacy_root"/*)
                language=${target#"$legacy_root"/}
                if [ -d "$native_root/$language" ]; then
                    echo "Migrating Tree-sitter queries for $language..."
                    ln -sfn -- "$native_root/$language" "$query_path"
                fi
                ;;
        esac
    done
}

# Return success when npm can install global packages without elevated
# permissions. Version managers generally provide a user-writable prefix,
# while distro-provided npm commonly uses a root-owned prefix such as /usr.
npm_global_prefix_is_writable() {
    local prefix=$1
    local path

    if [ -z "$prefix" ] || [ ! -w "$prefix" ]; then
        return 1
    fi

    for path in \
        "$prefix/bin" \
        "$prefix/lib" \
        "$prefix/lib/node_modules"
    do
        if [ -e "$path" ] && [ ! -w "$path" ]; then
            return 1
        fi
    done
}

# Install the tree-sitter CLI without assuming a particular Node.js manager.
ensure_tree_sitter_cli() {
    local npm_prefix
    local user_prefix="$HOME/.local"

    if command -v tree-sitter >/dev/null 2>&1; then
        echo "tree-sitter CLI is already installed"
        return
    fi

    echo "Installing tree-sitter CLI..."
    if ! command -v npm >/dev/null 2>&1; then
        echo "Error: npm is required to install tree-sitter-cli."
        exit 1
    fi

    npm_prefix=$(npm prefix -g 2>/dev/null || true)
    if npm_global_prefix_is_writable "$npm_prefix"; then
        npm install -g tree-sitter-cli
    else
        echo "npm's global prefix is not user-writable; installing under $user_prefix..."
        npm install -g --prefix "$user_prefix" tree-sitter-cli

        case ":$PATH:" in
            *":$user_prefix/bin:"*) ;;
            *) export PATH="$user_prefix/bin:$PATH" ;;
        esac
    fi

    if ! command -v tree-sitter >/dev/null 2>&1; then
        echo "Error: tree-sitter CLI was installed but is not available on PATH."
        exit 1
    fi
}

# Function for Neovim
nvim_setup() {
    UPDATE_FLAG=false
    
    # Check for update flag
    if [ "$1" = "--update" ]; then
        UPDATE_FLAG=true
        echo "Update flag detected. Will reinstall Neovim if it exists."
    fi
    
    # Check if nvim is already installed
    if command -v nvim >/dev/null 2>&1 && [ "$UPDATE_FLAG" = false ]; then
        echo "Neovim is already installed. Use --update flag to force reinstallation."
    else
        # If update flag is set and nvim exists, remove it first
        if [ "$UPDATE_FLAG" = true ] && command -v nvim >/dev/null 2>&1; then
            echo "Updating existing Neovim installation..."
        fi
        
        # Detect if dnf is available, otherwise use AppImage
        if command -v dnf >/dev/null 2>&1; then
            echo "Fedora/RHEL-based system detected"
            echo "Installing Neovim using dnf..."
            sudo dnf install -y neovim python3-neovim
            echo "Neovim installation completed via dnf!"
        else
            # Use AppImage for all other systems
            install_nvim_appimage
        fi
    fi
    
    # Install tree-sitter CLI (required by tree-sitter-manager.nvim).
    ensure_tree_sitter_cli

    # fzf-lua uses the system fzf binary.
    ensure_fzf

    # Create symlinks (stow will automatically create the required directories)
    create_symlinks "nvim"

    # Install and load the locked native packages before removing lazy.nvim.
    echo "Installing and validating Neovim plugins..."
    nvim --headless \
        "+lua if not vim.g.dotfiles_config_loaded then vim.cmd.cquit() end" \
        "+qa"
    migrate_legacy_treesitter_queries
    cleanup_legacy_lazy

    echo "Neovim configuration symlinks created successfully!"
}

# Function for Node.js via nvm
node_setup() {
    if [ "$#" -ne 0 ]; then
        echo "Error: The node command does not accept options."
        echo "Usage: $0 node"
        exit 1
    fi

    echo "Setting up Node.js with nvm..."

    local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
    local nvm_script="$nvm_dir/nvm.sh"

    if [ -s "$nvm_script" ]; then
        echo "nvm is already installed. Updating to latest..."
    else
        echo "Installing nvm..."
    fi

    # Install/update nvm and let its installer add the loader to the active
    # Bash or Zsh profile. This keeps the node command independent of the
    # optional Bash configuration package in this repository.
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

    # Load nvm for the current session
    export NVM_DIR="$nvm_dir"
    if [ ! -s "$nvm_script" ]; then
        echo "Error: nvm installation did not create $nvm_script."
        exit 1
    fi

    # shellcheck source=/dev/null
    \. "$nvm_script"

    if ! command -v nvm >/dev/null 2>&1; then
        echo "Error: nvm was installed but could not be loaded."
        exit 1
    fi

    # Install latest LTS Node.js
    echo "Installing latest LTS Node.js..."
    nvm install --lts

    # Set LTS as default
    echo "Setting LTS Node.js as default..."
    nvm alias default 'lts/*'
    nvm use default

    # Verify
    node --version
    npm --version

    echo "Node.js setup complete!"
}

# Function for tmux
tmux_setup() {
    echo "Installing tmux and its plugins..."
    
    # Check if tmux is already installed
    if command -v tmux >/dev/null 2>&1; then
        echo "tmux is already installed"
    else
        # Detect package manager
        if command -v apt-get >/dev/null 2>&1; then
            echo "Debian/Ubuntu-based system detected"
            PKG_MANAGER="apt-get"
            INSTALL_CMD="sudo apt-get install -y"
            PACKAGES="xsel tmux"
        elif command -v dnf >/dev/null 2>&1; then
            echo "Fedora/RHEL-based system detected"
            PKG_MANAGER="dnf"
            INSTALL_CMD="sudo dnf install -y"
            PACKAGES="xsel tmux"
        else
            echo "Error: Unsupported package manager. This script supports apt-get and dnf."
            exit 1
        fi

        # Install packages
        echo "Installing tmux and dependencies using $PKG_MANAGER..."
        $INSTALL_CMD $PACKAGES
    fi

    # Install tmux plugin manager if not already installed
    TPM_PATH="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_PATH" ]; then
        echo "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    else
        echo "Tmux Plugin Manager is already installed"
    fi
    
    # Create symlinks
    create_symlinks "tmux"
    
    echo "tmux installation complete!"
}

# Function for bash
bash_setup() {
    echo "Setting up bash configuration..."
    
    # Define the code block to add
    bashrcd_block="
# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f \"\$rc\" ]; then
            . \"\$rc\"
        fi
    done
fi
unset rc
"

    # Path to the user's .bashrc file
    bashrc_file="$HOME/.bashrc"

    # Check if the file exists, exit with error if not
    if [ ! -f "$bashrc_file" ]; then
        echo "Error: $bashrc_file does not exist."
        exit 1
    fi

    # Check if the code block is already in the file
    if ! grep -q "if \[ -d ~/.bashrc.d \]; then" "$bashrc_file"; then
        echo "Applying bash configuration to $bashrc_file..."
        echo "$bashrcd_block" >> "$bashrc_file"
        echo "Successfully applied bash configuration to $bashrc_file"
    else
        echo "Bash configuration already applied"
    fi

    # Create symlinks
    create_symlinks "bash"

    echo "Bash configuration files have been successfully linked."
}

# Helper function to install the fzf version used by Neovim and Git aliases
ensure_fzf() (
    local fzf_version="0.74.0"
    local current_version=""

    if command -v fzf >/dev/null 2>&1; then
        current_version=$(fzf --version | awk '{print $1}')
    fi

    if [ "$current_version" = "$fzf_version" ]; then
        echo "fzf $fzf_version is already installed"
        return
    fi

    local machine_arch
    local fzf_arch
    machine_arch=$(uname -m)
    case "$machine_arch" in
        x86_64)
            fzf_arch="amd64"
            ;;
        aarch64|arm64)
            fzf_arch="arm64"
            ;;
        *)
            echo "Error: Unsupported architecture for fzf: $machine_arch"
            exit 1
            ;;
    esac

    local archive="fzf-${fzf_version}-linux_${fzf_arch}.tar.gz"
    local release_url="https://github.com/junegunn/fzf/releases/download/v${fzf_version}"
    local fzf_tmp_dir
    fzf_tmp_dir=$(mktemp -d)
    trap 'rm -rf "$fzf_tmp_dir"' EXIT

    echo "Installing fzf $fzf_version for $fzf_arch..."
    wget -O "$fzf_tmp_dir/$archive" "$release_url/$archive"

    tar -xzf "$fzf_tmp_dir/$archive" -C "$fzf_tmp_dir"
    sudo install -m 0755 "$fzf_tmp_dir/fzf" /usr/local/bin/fzf
    echo "fzf $fzf_version installed successfully"
)

# Helper function to install delta (syntax-highlighting pager for git)
ensure_delta() {
    if command -v delta >/dev/null 2>&1; then
        echo "delta is already installed"
        return
    fi

    echo "delta is not installed. Installing it now..."

    if command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y git-delta
    elif command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu repos often lack git-delta, so install the release .deb
        DELTA_VERSION=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest |
            grep -m1 '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

        if [ -z "$DELTA_VERSION" ]; then
            echo "Error: Unable to determine the latest delta release."
            exit 1
        fi

        # Detect architecture
        ARCH=$(uname -m)
        if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            DELTA_ARCH=arm64
        else
            DELTA_ARCH=amd64
        fi

        DELTA_DEB=$(mktemp --suffix=.deb)
        echo "Installing delta $DELTA_VERSION for $DELTA_ARCH..."
        wget -O "$DELTA_DEB" \
            "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${DELTA_ARCH}.deb"
        sudo dpkg -i "$DELTA_DEB"
        rm -f "$DELTA_DEB"
    else
        echo "Error: Unable to install delta. Unsupported package manager."
        exit 1
    fi
}

# Function for Git configuration
git_setup() {
    echo "Setting up Git configuration..."

    # Ensure fzf is installed (needed for recent-switch alias)
    ensure_fzf

    # Ensure delta is installed (used as the git pager)
    ensure_delta

    # Configure Git aliases using git config --global
    echo "Configuring Git aliases..."
    git config --global alias.recent-switch '!f() { git checkout $(git branch --sort=-committerdate | fzf); }; f'
    git config --global alias.rsw 'recent-switch'

    # Configure delta as the pager for diffs
    echo "Configuring delta as the Git pager..."
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global delta.side-by-side false
    git config --global delta.dark true
    git config --global delta.syntax-theme OneHalfDark
    git config --global merge.conflictStyle zdiff3

    # Set Neovim as the default Git editor
    echo "Setting Neovim as the default Git editor..."
    if command -v nvim >/dev/null 2>&1; then
        git config --global core.editor "nvim"
        echo "Neovim set as the default Git editor"
    else
        echo "Warning: Neovim not found. Editor not set. Install Neovim first with './setup.sh nvim'"
    fi
    
    echo "Git configuration complete!"
}

# Function for JetBrains Mono Nerd Font
nerdfont_setup() {
    echo "Installing JetBrains Mono Nerd Font..."
    
    # Create font directory
    FONT_PATH=~/.local/share/fonts/jetbrains-mono-nerdfont
    
    mkdir -p $FONT_PATH
    cd $FONT_PATH && \
        curl -fLO \
        https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf
    
    # Update font cache
    fc-cache -v
    
    echo "JetBrains Mono Nerd Font installation complete!"
}

# Function for terminal color schemes
terminal_colors_setup() {
    echo "Installing terminal color schemes..."
    
    # Install dependencies
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y dconf-cli uuid-runtime
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y dconf uuid
    else
        echo "Error: Unsupported package manager. This script supports apt-get and dnf."
        exit 1
    fi
    
    # Download and run Gogh color scheme installer
    bash -c "$(wget -qO- https://git.io/vQgMr)"
    
    echo "Terminal color schemes installation complete!"
}

# Main execution
case "$1" in
    tmux)
        tmux_setup
        ;;
    nvim)
        # Check for --update flag as second argument
        nvim_setup "$2"
        ;;
    node)
        node_setup "${@:2}"
        ;;
    bash)
        bash_setup
        ;;
    git)
        git_setup
        ;;
    nerdfont)
        nerdfont_setup
        ;;
    terminal-colors)
        terminal_colors_setup
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Invalid command."
        show_help
        exit 1
        ;;
esac

exit 0
