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
    echo "  bash              - Configure bash with custom settings"
    echo "  git               - Configure Git with custom aliases"
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
    
    # Create symlinks (stow will automatically create the required directories)
    create_symlinks "nvim"
    
    echo "Neovim configuration symlinks created successfully!"
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

# Helper function to install fzf
ensure_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf is not installed. Installing it now..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y fzf
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y fzf
        else
            echo "Error: Unable to install fzf. Unsupported package manager."
            exit 1
        fi
    else
        echo "fzf is already installed"
    fi
}

# Function for Git configuration
git_setup() {
    echo "Setting up Git configuration..."
    
    # Ensure fzf is installed (needed for recent-switch alias)
    ensure_fzf
    
    # Configure Git aliases using git config --global
    echo "Configuring Git aliases..."
    git config --global alias.recent-switch '!f() { git checkout $(git branch --sort=-committerdate | fzf); }; f'
    git config --global alias.rsw 'recent-switch'

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
