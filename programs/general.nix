{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  macAppWrapper = ../templates/scripts/mac_app_wrapper.sh;
in
{
  # Setups applications as mac wrappers
  system.activationScripts.postActivation.text = lib.mkIf isDarwin (lib.mkAfter ''
    echo "running custom Nix Apps wrapper..." >&2
    echo "source wrapper script: ${macAppWrapper}" >&2

    stamp="$(/bin/date +%Y%m%d-%H%M%S)-$$"
    tmpScript="/tmp/mac_app_wrapper-$stamp.sh"

    echo "using temp wrapper script: $tmpScript" >&2

    cp ${macAppWrapper} "$tmpScript"
    chmod +x "$tmpScript"

    echo "temp script sha256:" >&2
    /usr/bin/shasum -a 256 "$tmpScript" >&2 || true

    echo "first 20 lines of temp script:" >&2
    /usr/bin/sed -n '1,20p' "$tmpScript" >&2

    "$tmpScript" \
      "${config.system.build.applications}/Applications" \
      "/Applications/NixApps"

    rm -f "$tmpScript"
  '');

  environment.systemPackages =
    with pkgs;
    [
      # Archive tools
      unrar
      unzip
      p7zip
      zip

      # Miscellaneous
      obsidian
      spotify

      # Fonts
      nerd-fonts.noto

      # Communication
      discord
      slack
      zoom-us
    ]

    # Linux-specific packages
    ++ lib.optionals isLinux [
      transmission_4-gtk
      google-chrome
      gimp
      vlc
      kicad
      orca-slicer
    ]

    # macOS-specific packages
    ++ lib.optionals isDarwin [
      transmission_4
      # TODO: missing these
      # - vlc
      # - kicad
      # - orca slicer
    ];
}
