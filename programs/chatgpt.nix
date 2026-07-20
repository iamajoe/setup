{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = userConfig.platform == "darwin";
  isLinux = userConfig.platform == "linux";
in
{
  environment.systemPackages = with pkgs; [
    mongodb-compass
  ]
}
