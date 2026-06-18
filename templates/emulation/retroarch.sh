#!/usr/bin/env bash
set -e

LOG="@steamShortcutsDir@/retroarch.log"

echo "Launching RetroArch" > "$LOG"
echo "Date: $(date)" >> "$LOG"

unset LD_PRELOAD
exec retroarch >> "$LOG" 2>&1
