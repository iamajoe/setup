{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;
in
{
  environment.systemPackages = with pkgs; [
    kdePackages.k3b
    cdrtools
    dvdplusrwtools
    cdrkit
  ];
}
