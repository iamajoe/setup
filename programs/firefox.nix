{ config, pkgs, lib, userConfig, ... }:

{
  environment.systemPackages = [
    pkgs.firefox
  ];
}
