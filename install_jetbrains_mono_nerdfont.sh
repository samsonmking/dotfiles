# /bin/bash
set -e

FONT_PATH=~/.local/share/fonts

mkdir -p $FONT_PATH
cd $FONT_PATH && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf
