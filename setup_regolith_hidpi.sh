#!/bin/bash
gsettings set org.gnome.desktop.interface cursor-size 48
gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
cat <<EOT >> $HOME/.config/regolith2/Xresources
Xft.dpi: 144
Xcursor.size: 48
i3-wm.bar.position: top
EOT
regolith-look refresh
