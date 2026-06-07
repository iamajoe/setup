{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
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
      gimp
      sublime-merge
      spotify
      vlc
      stripe-cli
      kicad
      orca-slicer

      # Additional editors
      sublime4
      code-cursor

      # Fonts
      nerd-fonts.noto

      # Communication
      discord
      slack

      # Database tools
      mongodb-compass
    ]

    # Linux-specific packages
    ++ lib.optionals isLinux [
      transmission_4-gtk
      google-chrome
      zoom-us
    ]

    # macOS-specific packages
    ++ lib.optionals isDarwin [
      transmission_4
      zoom-us
    ];
}
