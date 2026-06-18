#!/usr/bin/env bash
set -e

LOG="@steamShortcutsDir@/es-de.log"

echo "Launching ES-DE" > "$LOG"
echo "Date: $(date)" >> "$LOG"

export ROMS_DIR="@romsDir@"
export BIOS_DIR="@biosDir@"

# Some NixOS/Steam environments carry LD_PRELOAD values that can break apps.
unset LD_PRELOAD

# ES-DE's binary name in nixpkgs is normally "emulationstation".
if command -v emulationstation >/dev/null 2>&1; then
  exec emulationstation >> "$LOG" 2>&1
fi

# Fallback in case the package name changes upstream.
if command -v es-de >/dev/null 2>&1; then
  exec es-de >> "$LOG" 2>&1
fi

echo "Could not find ES-DE binary. Tried: emulationstation, es-de" >> "$LOG"
exit 1
