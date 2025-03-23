#!/bin/bash
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Show help menu
show_help() {
    echo "Usage: $0 COMMAND"
    echo ""
    echo "Available commands:"
    echo "  tmux              - Install tmux and tmux plugin manager"
    echo "  nvim              - Install Neovim AppImage"
    echo "  bash              - Configure bash with custom settings"
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

# Function for Neovim
nvim_setup() {
    echo "Installing Neovim from AppImage..."
    
    NVIM_RELEASE=https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage
    NVIM_PATH=/usr/local/bin/nvim

    sudo rm -f $NVIM_PATH
    sudo wget $NVIM_RELEASE -O $NVIM_PATH
    sudo chmod +x $NVIM_PATH

    sudo update-alternatives --install /usr/bin/editor editor $NVIM_PATH 35 && \
    sudo update-alternatives --set editor $NVIM_PATH
    
    # Create required directory for nvim config
    mkdir -p "$HOME/.config/nvim"
    
    # Create symlinks
    create_symlinks "nvim"
    
    echo "Neovim installation complete!"
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
        nvim_setup
        ;;
    bash)
        bash_setup
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
