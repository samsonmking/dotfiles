# /bin/bash
set -e

if command -v tmux >/dev/null 2>&1; then
    echo "tmux is already installed"
    exit 0
fi

sudo apt-get install xsel tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
