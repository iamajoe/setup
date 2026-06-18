#!/usr/bin/env bash
set -euo pipefail

LOG="@steamShortcutsDir@/es-de.log"
ESDE_APPIMAGE="@esDeAppImage@"
export ROMS_DIR="@romsDir@"
export BIOS_DIR="@biosDir@"

echo "Launching ES-DE" > "\$LOG"
echo "Date: \$(date)" >> "\$LOG"
unset LD_PRELOAD

if [ ! -x "\$ESDE_APPIMAGE" ]; then
  echo "ES-DE AppImage not found. Installing..." >> "\$LOG"
  "@steamShortcutsDir@/install-es-de.sh" >> "\$LOG" 2>&1
fi

exec @appImageRun@ "\$ESDE_APPIMAGE" \
  --home "$HOME" \
  --roms "@romsDir@" \
  --systems "@biosDir@" \
  >> "\$LOG" 2>&1
