#!/usr/bin/env bash

# Qtile autostart script
# This script runs once when Qtile starts

# restart the logs for the autostart
rm -rf $HOME/.config/qtile/autostart.log

eval "$(/run/current-system/sw/bin/gnome-keyring-daemon --start --components=secrets,pkcs11)"
export SSH_AUTH_SOCK

# Set root window background color
xsetroot -solid "#121312" &

# Force dark mode for all applications
export GTK_THEME=Adwaita:dark
export QT_STYLE_OVERRIDE=Adwaita-Dark

# Compositor
echo "$(date) AUTOSTART: launching picom" >> $HOME/.config/qtile/autostart.log
picom &

# Notification daemon
echo "$(date) AUTOSTART: launching dunst" >> $HOME/.config/qtile/autostart.log
dunst &

# Network manager applet
echo "$(date) AUTOSTART: launching network manager" >> $HOME/.config/qtile/autostart.log
nm-applet &

# Bluetooth manager (commented out - using qtile-extras Bluetooth widget instead)
echo "$(date) AUTOSTART: launching bluetooth" >> $HOME/.config/qtile/autostart.log
blueman-applet &

# Clipboard manager daemon
echo "$(date) AUTOSTART: launching clipmenu" >> $HOME/.config/qtile/autostart.log
clipmenud &

# disable screen blanking, screensaver, and DPMS power saving (TV always on)
if [ "@neverSleep@" = "true" ]; then
  echo "$(date) AUTOSTART: disable never sleep" >> $HOME/.config/qtile/autostart.log
  xset s off
  xset s noblank
  xset -dpms
fi

# set keyboard repeat rate
# xset r rate 350 60

# launch Steam straight into Big Picture mode (TV setups)
if [ "@autoRunSteamBigPicture@" = "true" ]; then
  sleep 5
  echo "$(date) AUTOSTART: launching Steam" >> $HOME/.config/qtile/autostart.log
  setsid steam -gamepadui &
fi

# auto mount drives
echo "$(date) AUTOSTART: launching udiskie" >> $HOME/.config/qtile/autostart.log
subprocess.Popen(["udiskie", "--tray"])
