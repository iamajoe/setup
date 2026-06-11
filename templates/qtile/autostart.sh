#!/usr/bin/env bash

# Qtile autostart script
# This script runs once when Qtile starts

eval "$(/run/current-system/sw/bin/gnome-keyring-daemon --start --components=secrets,pkcs11)"
export SSH_AUTH_SOCK

# Set root window background color
xsetroot -solid "#121312" &

# Force dark mode for all applications
export GTK_THEME=Adwaita:dark
export QT_STYLE_OVERRIDE=Adwaita-Dark

# Set wallpaper (if you have nitrogen or feh installed)
# nitrogen --restore &
# feh --bg-scale /path/to/wallpaper.jpg &

# Compositor (already handled by home-manager)
# picom &

# Notification daemon (already handled by home-manager)
# dunst &

# Network manager applet
# nm-applet &

# Bluetooth manager (commented out - using qtile-extras Bluetooth widget instead)
blueman-applet &

# Clipboard manager daemon
clipmenud &

# Remote desktop
# rustdesk --silent &

# set display timeout, sleep, and poweroff
# xset s off
# xset s noblank
# xset -dpms

# set keyboard repeat rate
# xset r rate 350 60
