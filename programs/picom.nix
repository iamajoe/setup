{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  picomTemplate = ../templates/picom;
in
{
  environment.systemPackages = [
    pkgs.picom
  ];

  system.activationScripts.picomConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -rf ${homeDir}/.config/picom

    cp -r ${picomTemplate} ${homeDir}/.config/picom

    chown -R ${username}:users ${homeDir}/.config/picom
    find ${homeDir}/.config/picom -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/picom -type f -exec chmod 0644 {} \;
  '';
}
