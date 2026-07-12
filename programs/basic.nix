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
    ]

    # Linux-specific packages
    ++ lib.optionals isLinux [
    ]

    # macOS-specific packages
    ++ lib.optionals isDarwin [
    ];
}
