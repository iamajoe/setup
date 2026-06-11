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
    rm -f ${homeDir}/.config/alacritty/alacritty.toml
    ln -sfn ${../templates/alacritty/alacritty.toml} ${homeDir}/.config/alacritty/alacritty.toml
    chown -h ${username}:staff ${homeDir}/.config/alacritty
  '';
}
