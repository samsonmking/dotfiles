#!/bin/bash
set -e

# Check if tmux is already installed
if command -v tmux >/dev/null 2>&1; then
    echo "tmux is already installed"
    exit 0
fi

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

# Install tmux plugin manager if not already installed
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_PATH" ]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
else
    echo "Tmux Plugin Manager is already installed"
fi

echo "Installation complete!"
