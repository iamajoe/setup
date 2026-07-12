{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  yaziTemplate = ../templates/yazi;
in
{
  environment.systemPackages = [
    pkgs.yazi
    pkgs.xdg-utils
  ];

  system.activationScripts.yaziConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -rf ${homeDir}/.config/yazi

    cp -r ${yaziTemplate} ${homeDir}/.config/yazi

    chown -R ${username}:users ${homeDir}/.config/yazi
    find ${homeDir}/.config/yazi -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/yazi -type f -exec chmod 0644 {} \;
  '';
}
