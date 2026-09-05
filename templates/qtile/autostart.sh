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

# Compositor
picom &

# Notification daemon
dunst &

# Network manager applet
nm-applet &

# Bluetooth manager (commented out - using qtile-extras Bluetooth widget instead)
blueman-applet &

# Clipboard manager daemon
clipmenud &

# auto mount drives
@hook.subscribe.startup_once
def start_once():
    subprocess.Popen(["udiskie", "--tray"])

# disable screen blanking, screensaver, and DPMS power saving (TV always on)
if [ "@neverSleep@" = "true" ]; then
  xset s off
  xset s noblank
  xset -dpms
fi

# set keyboard repeat rate
# xset r rate 350 60

# launch Steam straight into Big Picture mode (TV setups)
if [ "@autoRunSteamBigPicture@" = "true" ]; then
  sleep 5
  setsid steam -gamepadui &
fi

