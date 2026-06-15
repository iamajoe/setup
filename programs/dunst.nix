{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  dunstTemplate = ../templates/dunst;
in
{
  environment.systemPackages = [
    pkgs.dunst
    pkgs.firefox
  ];

  services.dbus.packages = [
    pkgs.dunst
  ];

  system.activationScripts.dunstConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -rf ${homeDir}/.config/dunst

    cp -r ${dunstTemplate} ${homeDir}/.config/dunst

    chown -R ${username}:users ${homeDir}/.config/dunst
    find ${homeDir}/.config/dunst -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/dunst -type f -exec chmod 0644 {} \;
  '';
}
