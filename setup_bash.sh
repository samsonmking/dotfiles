#!/bin/bash

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

# Get the directory where this script is located
script_dir="$(dirname "$(readlink -f "$0")")"

# Check if GNU Stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed. Please install it first."
    exit 1
fi

# Use stow to create/update symlinks for bash configuration
echo "Using GNU Stow to symlink bash configuration files..."
stow -R -v -d "$script_dir" -t "$HOME" bash

echo "Bash configuration files have been successfully linked using GNU Stow."
