# /bin/bash
set -e

# https://docs.fedoraproject.org/en-US/quick-docs/fonts/
FONT_PATH=~/.local/share/fonts/jetbrains-mono-nerdfont

mkdir -p $FONT_PATH
cd $FONT_PATH && \
    curl -fLO \
    https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf

fc-cache -v
