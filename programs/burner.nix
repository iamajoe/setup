{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;
in
{
  environment.systemPackages = [
    pkgs.k3b
  ];
}
