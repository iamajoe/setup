{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  composeTemplate = ../templates/services;
in
{
  environment.systemPackages = [
    pkgs.docker
  ];

  system.activationScripts.dockerComposeConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/services
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config/systemd/user

    rm -f ${homeDir}/.config/systemd/user/docker-compose.service

    install -m 0644 -o ${username} -g users ${composeTemplate}/docker-compose.yml ${homeDir}/services/docker-compose.yml
    install -m 0644 -o ${username} -g users ${composeTemplate}/docker-compose.service ${homeDir}/.config/systemd/user/docker-compose.service

    chown ${username}:users ${homeDir}/services/docker-compose.yml
    chown -R ${username}:users ${homeDir}/.config/systemd/user

    systemctl --user -M ${username}@ daemon-reload || true
    systemctl --user -M ${username}@ enable --now docker-compose.service || true
  '';
}
