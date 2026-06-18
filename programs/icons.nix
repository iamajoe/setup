{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  steamShortcutsDir = "${homeDir}/SteamShortcuts";
  iconsDir = "${steamShortcutsDir}/icons";

  moonlightIcon = "${iconsDir}/moonlight.svg";
  esDeIcon = "${iconsDir}/es-de.svg";

  installIconsSh = pkgs.writeShellScript "install-icons.sh" ''
    set -euo pipefail

    ICONS_DIR="${iconsDir}"
    MOONLIGHT_ICON="${moonlightIcon}"
    ESDE_ICON="${esDeIcon}"

    mkdir -p "$ICONS_DIR"

    download_icon() {
      local name="$1"
      local url="$2"
      local output="$3"
      local tmp

      tmp="$(mktemp)"

      echo "Fetching $name icon..."
      if ${pkgs.curl}/bin/curl -L --fail --silent --show-error "$url" -o "$tmp"; then
        ${pkgs.coreutils}/bin/install -m 0644 "$tmp" "$output"
        echo "Installed $name icon to: $output"
      else
        echo "Warning: failed to download $name icon from $url" >&2
        rm -f "$tmp"
        return 1
      fi

      rm -f "$tmp"
    }

    # Official Moonlight SVG from the Moonlight website repo.
    download_icon \
      "Moonlight" \
      "https://raw.githubusercontent.com/moonlight-stream/moonlight-stream.github.io/master/images/moonlight.svg" \
      "$MOONLIGHT_ICON" || true

    # ES-DE icon.
    # This URL may need adjusting if upstream moves the icon.
    download_icon \
      "ES-DE" \
      "https://cdn2.steamgriddb.com/logo/65904bcd52a06cd64e57fc80b4b042d0.png" \
      "$ESDE_ICON" || true
  '';
in
{
  environment.systemPackages = with pkgs; [
    curl
  ];

  system.activationScripts.shortcutIcons = ''
    set -e

    mkdir -p "${steamShortcutsDir}"
    mkdir -p "${iconsDir}"

    install -m 0755 -o ${username} -g users ${installIconsSh} "${steamShortcutsDir}/install-icons.sh"

    "${steamShortcutsDir}/install-icons.sh"

    chown -R ${username}:users "${steamShortcutsDir}"
  '';
}
