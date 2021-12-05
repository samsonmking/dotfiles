# https://github.com/regolith-linux/regolith-desktop/issues/417#:~:text=Open%20Settings.,mouse%20cursor%20selection%20pop%2Dup.
sudo apt-get update && sudo apt-get install adwaita-icon-them-full
gsettings set org.gnome.desktop.interface cursor-size 48
gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
cat <<EOT >> $HOME/.config/regolith/Xresources
Xft.dpi: 144
Xcursor.size: 48
i3-wm.bar.position: top
EOT
