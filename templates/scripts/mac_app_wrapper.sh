#!/usr/bin/env bash
set -euo pipefail

srcApps="$1"
dstApps="${2:-/Applications/NixApps}"

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

  infoPlist="$realApp/Contents/Info.plist"

  if [ ! -f "$infoPlist" ]; then
    echo "skipping $appName: no Info.plist" >&2
    continue
  fi

  executableName="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$infoPlist" 2>/dev/null || true)"

  if [ -z "$executableName" ]; then
    echo "skipping $appName: no CFBundleExecutable" >&2
    continue
  fi

  realExecutable="$realApp/Contents/MacOS/$executableName"
  binCandidate="/run/current-system/sw/bin/$executableName"

  if [ -x "$binCandidate" ]; then
    launchExecutable="$binCandidate"
    echo "  using command: $launchExecutable" >&2
  elif [ -x "$realExecutable" ]; then
    launchExecutable="$realExecutable"
    echo "  using app executable: $launchExecutable" >&2
  else
    echo "skipping $appName: no executable found" >&2
    echo "  tried $binCandidate" >&2
    echo "  tried $realExecutable" >&2
    continue
  fi

  rm -rf "$dstApp"
  mkdir -p "$dstApp/Contents/MacOS"
  mkdir -p "$dstApp/Contents/Resources"

  if [ -d "$realApp/Contents/Resources" ]; then
    cp -R "$realApp/Contents/Resources/." "$dstApp/Contents/Resources/" 2>/dev/null || true
  fi

  iconFile="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$infoPlist" 2>/dev/null || true)"

  cat > "$dstApp/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>CFBundleName</key>
    <string>$appBase</string>

    <key>CFBundleDisplayName</key>
    <string>$appBase</string>

    <key>CFBundleIdentifier</key>
    <string>org.nixos.nix-apps.$appBase</string>

    <key>CFBundleExecutable</key>
    <string>wrapper</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>NSHighResolutionCapable</key>
    <true/>

    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
EOF

  if [ -n "$iconFile" ]; then
    cat >> "$dstApp/Contents/Info.plist" <<EOF
    <key>CFBundleIconFile</key>
    <string>$iconFile</string>
EOF
  fi

  cat >> "$dstApp/Contents/Info.plist" <<EOF
  </dict>
</plist>
EOF

  cat > "$dstApp/Contents/MacOS/wrapper" <<EOF
#!/bin/sh

export TERMINFO_DIRS="/run/current-system/sw/share/terminfo:/usr/share/terminfo:/etc/terminfo"
export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/\$USER/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin"

exec "$launchExecutable" "\$@"
EOF

  chmod +x "$dstApp/Contents/MacOS/wrapper"
done

chown -R root:wheel "$dstApps"

find "$dstApps" -maxdepth 1 -name "*.app" -print0 |
while IFS= read -r -d "" app; do
  /usr/bin/touch "$app"
done
