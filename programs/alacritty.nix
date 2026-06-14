{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;
in
{
  environment.systemPackages = [
    pkgs.alacritty
    pkgs.zsh
  ];

  system.activationScripts.alacrittyConfig.text = ''
    mkdir -p ${homeDir}/.config/alacritty
    ln -sfn ${../templates/alacritty/alacritty.toml} ${homeDir}/.config/alacritty/alacritty.toml
    chown -R ${username}:staff ${homeDir}/.config/alacritty
  '';
}
