#!@bash@
set -euo pipefail

ESDE_APPIMAGE="@esDeAppImage@"

if [ -x "$ESDE_APPIMAGE" ]; then
  echo "ES-DE AppImage already exists:"
  echo "$ESDE_APPIMAGE"
  echo "Skipping download."
  exit 0
fi

if [ -e "$ESDE_APPIMAGE" ]; then
  echo "ES-DE file already exists but is not executable:"
  echo "$ESDE_APPIMAGE"
  echo "Making it executable and skipping download."
  chmod 0755 "$ESDE_APPIMAGE"
  exit 0
fi

DOWNLOAD_URL="https://gitlab.com/es-de/emulationstation-de/-/package_files/288156961/download"

mkdir -p "$(dirname "$ESDE_APPIMAGE")"
rm -f "$ESDE_APPIMAGE"
curl -L --fail --progress-bar "$DOWNLOAD_URL" -o "$ESDE_APPIMAGE"
chmod 0755 "$ESDE_APPIMAGE"

echo "Installed ES-DE to: $ESDE_APPIMAGE"
