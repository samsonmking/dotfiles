# /bin/bash
set -e

NVIM_RELEASE=https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
NVIM_PATH=/usr/local/bin/nvim

sudo rm -f $NVIM_PATH
sudo wget $NVIM_RELEASE -O $NVIM_PATH
sudo chmod +x $NVIM_PATH

sudo update-alternatives --install /usr/bin/editor editor $NVIM_PATH 35 && \
sudo update-alternatives --set editor $NVIM_PATH
