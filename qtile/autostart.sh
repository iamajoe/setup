#!/usr/bin/env bash

# Qtile autostart script
# This script runs once when Qtile starts

# Set wallpaper (if you have nitrogen or feh installed)
# nitrogen --restore &
# feh --bg-scale /path/to/wallpaper.jpg &

# Compositor (already handled by home-manager)
# picom &

# Notification daemon (already handled by home-manager)
# dunst &

# Network manager applet
# nm-applet &

# Bluetooth manager
blueman-applet &

# Add any other startup applications here
