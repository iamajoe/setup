#!/usr/bin/env bash

# Qtile autostart script
# This script runs once when Qtile starts

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
# blueman-applet &

# Clipboard manager daemon
clipmenud &

# Remote desktop
# rustdesk --silent &

# Add any other startup applications here
