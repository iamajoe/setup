#!/usr/bin/env bash
set -euo pipefail

srcApps="$1"
dstApps="${2:-/Applications/Nix Apps}"

echo "setting up $dstApps..." >&2

rm -rf "$dstApps"
mkdir -p "$dstApps"

if [ ! -d "$srcApps" ]; then
  echo "no Nix apps found at $srcApps" >&2
  exit 0
fi

find "$srcApps" -maxdepth 1 -name "*.app" -print0 |
while IFS= read -r -d "" srcApp; do
  appName="$(basename "$srcApp")"
  appBase="${appName%.app}"
  dstApp="$dstApps/$appName"

  echo "wrapping $appName" >&2

  realApp="$(readlink "$srcApp" || true)"
  if [ -z "$realApp" ]; then
    realApp="$srcApp"
  fi

  executableName="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$realApp/Contents/Info.plist" 2>/dev/null || true)"

  if [ -z "$executableName" ]; then
    echo "skipping $appName: no CFBundleExecutable" >&2
    continue
  fi

  realExecutable="$realApp/Contents/MacOS/$executableName"

  if [ ! -x "$realExecutable" ]; then
    echo "skipping $appName: executable not found at $realExecutable" >&2
    continue
  fi

  mkdir -p "$dstApp/Contents/MacOS"
  mkdir -p "$dstApp/Contents/Resources"

  cp "$realApp/Contents/Info.plist" "$dstApp/Contents/Info.plist"

  /usr/libexec/PlistBuddy \
    -c "Set :CFBundleIdentifier org.nixos.wrapper.$appBase" \
    "$dstApp/Contents/Info.plist" 2>/dev/null || true

  /usr/libexec/PlistBuddy \
    -c "Set :CFBundleExecutable wrapper" \
    "$dstApp/Contents/Info.plist"

  if [ -d "$realApp/Contents/Resources" ]; then
    cp -R "$realApp/Contents/Resources/." "$dstApp/Contents/Resources/" 2>/dev/null || true
  fi

  cat > "$dstApp/Contents/MacOS/wrapper" <<EOF
#!/bin/sh

export TERMINFO_DIRS="/run/current-system/sw/share/terminfo:/usr/share/terminfo:/etc/terminfo"
export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/\$USER/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin"

exec "$realExecutable" "\$@"
EOF

  chmod +x "$dstApp/Contents/MacOS/wrapper"
done

chown -R root:wheel "$dstApps"
