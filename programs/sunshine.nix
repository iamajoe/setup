{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  sunshineTemplate = ../templates/sunshine;
in
{
  environment.systemPackages = [
    pkgs.sunshine
  ];

  system.activationScripts.sunshineConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config/sunshine
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config/systemd/user

    rm -f ${homeDir}/.config/sunshine/apps.json
    rm -f ${homeDir}/.config/systemd/user/sunshine.service

    install -m 0644 -o ${username} -g users ${sunshineTemplate}/apps.json ${homeDir}/.config/sunshine/apps.json
    install -m 0644 -o ${username} -g users ${sunshineTemplate}/sunshine.service ${homeDir}/.config/systemd/user/sunshine.service

    chown -R ${username}:users ${homeDir}/.config/sunshine
    chown -R ${username}:users ${homeDir}/.config/systemd/user

    systemctl --user -M ${username}@ daemon-reload || true
  '';
}
