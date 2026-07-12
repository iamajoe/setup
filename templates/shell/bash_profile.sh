# Auto-start the X session on the primary console after autologin
# (not on SSH logins or when already inside a graphical session).
if command -v startx >/dev/null 2>&1 && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi

if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
