{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = userConfig.platform == "darwin";
  isLinux = userConfig.platform == "linux";
in
{
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
      slack
      zoom-us
    ]

    # Linux-specific packages
    ++ lib.optionals isLinux [
      discord # goes crazy with the updates on mac
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
