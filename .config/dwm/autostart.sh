#!/bin/sh

# Kill any existing instances to avoid duplicates if dwm or X is re-launched
killall -q dunst slstatus xcompmgr udiskie unclutter

# Display & wallpaper settings
xset r rate 300 50 &
xwallpaper --output all --zoom ~/.local/share/wallpaper/wallpaper.jpg &

# Background daemons & status bar
xcompmgr &
dunst &
unclutter &
udiskie &
# Clear status bar (replaced by tmux status)
xsetroot -name " " &
