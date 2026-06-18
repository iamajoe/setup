#!@bash@
set -euo pipefail

LOG="@steamShortcutsDir@/es-de.log"
ESDE_APPIMAGE="@esDeAppImage@"
export ROMS_DIR="@romsDir@"
export BIOS_DIR="@biosDir@"

echo "Launching ES-DE" > "\$LOG"
echo "Date: \$(date)" >> "\$LOG"
unset LD_PRELOAD

exec @appImageRun@ "\$ESDE_APPIMAGE" \
  --home "$HOME" \
  --roms "@romsDir@" \
  --systems "@biosDir@" \
  >> "\$LOG" 2>&1
