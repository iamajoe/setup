{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  rofiTemplate = ../templates/rofi;
in
{
  environment.systemPackages = [
    pkgs.rofi
    pkgs.alacritty
    pkgs.firefox
    pkgs.jq
    pkgs.libnotify
  ];

  system.activationScripts.rofiConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config
    install -d -m 0755 -o ${username} -g users ${homeDir}/.local/bin
    install -d -m 0755 -o ${username} -g users ${homeDir}/.local/share/quick-notes

    rm -rf ${homeDir}/.config/rofi
    rm -f ${homeDir}/.local/bin/rofi-web-search
    rm -f ${homeDir}/.local/bin/rofi-quick-notes

    cp -r ${rofiTemplate} ${homeDir}/.config/rofi

    install -m 0755 -o ${username} -g users ${rofiTemplate}/scripts/rofi-web-search ${homeDir}/.local/bin/rofi-web-search
    install -m 0755 -o ${username} -g users ${rofiTemplate}/scripts/rofi-quick-notes ${homeDir}/.local/bin/rofi-quick-notes

    rm -rf ${homeDir}/.config/rofi/scripts

    chown -R ${username}:users ${homeDir}/.config/rofi
    chown -R ${username}:users ${homeDir}/.local/share/quick-notes

    find ${homeDir}/.config/rofi -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/rofi -type f -exec chmod 0644 {} \;
  '';
}
