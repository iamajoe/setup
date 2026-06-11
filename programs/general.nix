{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  macAppWrapper = ../templates/scripts/mac_app_wrapper.sh;
in
{
  # Setups applications as mac wrappers
  system.activationScripts.zzNixApps.text = lib.mkIf isDarwin ''
    tmpScript="$(mktemp /tmp/mac_app_wrapper.XXXXXX.sh)"

    cp ${macAppWrapper} "$tmpScript"
    chmod +x "$tmpScript"

    "$tmpScript" \
      "${config.system.build.applications}/Applications" \
      "/Applications/Nix Apps"

    rm -f "$tmpScript"
  '';

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
