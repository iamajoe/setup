#!@bash@
set -euo pipefail

LOG="@steamShortcutsDir@/es-de.log"
ESDE_APPIMAGE="@esDeAppImage@"

export ROMS_DIR="@romsDir@"
export BIOS_DIR="@biosDir@"

mkdir -p "$(dirname "$LOG")"

{
  echo "Launching ES-DE"
  echo "Date: $(date)"
  echo "ESDE_APPIMAGE: $ESDE_APPIMAGE"
  echo "HOME: $HOME"
  echo "---"
} > "$LOG"

unset LD_PRELOAD

exec @appImageRun@ "$ESDE_APPIMAGE" --home "$HOME" >> "$LOG" 2>&1
