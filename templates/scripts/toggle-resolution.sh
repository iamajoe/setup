#!/bin/sh

OUTPUT="DP-2"

CURRENT="$(xrandr | awk -v output="$OUTPUT" '
  $1 == output { active=1; next }
  active && /\*/ { print $1; exit }
')"

case "$CURRENT" in
  "1920x1080")
    xrandr --output "$OUTPUT" --auto
    xrdb -merge "$HOME/.Xresources"
    notify-send "Display" "Switched to 3840x2160"
    ;;
  "3840x2160")
    xrandr --output "$OUTPUT" --mode 1920x1080 --rate 60
    xrdb -merge "$HOME/.Xresources"
    notify-send "Display" "Switched to 1920x1080"
    ;;
  *)
    xrandr --output "$OUTPUT" --mode 1920x1080 --rate 60
    xrdb -merge "$HOME/.Xresources"
    notify-send "Display" "Unknown mode $CURRENT, switched to 1920x1080"
    ;;
esac
