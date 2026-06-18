#!@bash@
set -euo pipefail

ESDE_APPIMAGE="@esDeAppImage@"
TMP_JSON="$(mktemp)"
TMP_DOWNLOAD="$(mktemp)"
PROJECT="es-de%2Femulationstation-de"
API_URL="https://gitlab.com/api/v4/projects/${PROJECT}/releases/permalink/latest"

echo "Fetching latest ES-DE release metadata..."
curl -L --fail --silent --show-error "$API_URL" -o "$TMP_JSON"

DOWNLOAD_URL="$(
  python3 - "$TMP_JSON" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
links = data.get("assets", {}).get("links", [])

candidates = []
for link in links:
    name = (link.get("name") or "").lower()
    url = link.get("direct_asset_url") or link.get("url") or ""
    if "appimage" in name and "x64" in name:
        candidates.append(url)
    elif "appimage" in name and "x86_64" in name:
        candidates.append(url)
    elif url.lower().endswith(".appimage") and ("x64" in url.lower() or "x86_64" in url.lower()):
        candidates.append(url)
if not candidates:
    print("Could not find an x86_64/x64 Linux AppImage asset in the latest ES-DE release.", file=sys.stderr)
    sys.exit(1)

print(candidates[0])
PY
)"

echo "Downloading ES-DE AppImage:"
echo "$DOWNLOAD_URL"
curl -L --fail --progress-bar "$DOWNLOAD_URL" -o "$TMP_DOWNLOAD"
install -m 0755 "$TMP_DOWNLOAD" "$ESDE_APPIMAGE"
rm -f "$TMP_JSON" "$TMP_DOWNLOAD"

echo "Installed ES-DE to: $ESDE_APPIMAGE"
