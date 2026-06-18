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
  echo "ROMS_DIR: $ROMS_DIR"
  echo "BIOS_DIR: $BIOS_DIR"
  echo "HOME: $HOME"
  echo "---"
} > "$LOG"

unset LD_PRELOAD

exec @appImageRun@ "$ESDE_APPIMAGE" \
  --home "$HOME" \
  --roms "$ROMS_DIR" \
  --systems "$BIOS_DIR" \
  >> "$LOG" 2>&1
