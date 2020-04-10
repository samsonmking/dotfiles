## Alacritty
### Features
* Ayu Dark Color Scheme
### Install
```
sudo add-apt-repository ppa:mmstick76/alacritty
sudo apt install alacritty
```

Use Alacritty as default terminal (Ctrl + Alt + T)
`gsettings set org.gnome.desktop.default-a pplications.terminal exec 'alacritty'`

`ln -s $PWD/alacritty/.alacritty.yml /home/$USER/.alacritty.yml`

## OhMyZsh
### Features
* Powerlevel10k theme
* auto-complete
* tmux config (256-colors)
### Install
`ln -s $PWD/zsh/.zshrc /home/$USER/.zshrc`
### Install [Powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh)

## tmux
### Features
* Keybindings
  * cntrl-b + |                 -> vertical split
  * cntrl-b + -                 -> horizontal split
  * cntrl-b + alt + arrow keys  -> resize panes
  * vim bindings
* Increased history size
### Install
`ln -s $PWD/tmux/.tmux/conf /home/$USER/.tmux.conf`

## vim
### Features
* Syntax highlighting
* Auto-indent
* Line numbers
* `:Vexplore` opens netrw vertically, on left - similar to NERDTree
### Install
`ln-s $PWD/vim/.vimrc /home/$USER/.vimrc`
