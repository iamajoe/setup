{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  templateDir = ../templates/services;
in
{
  environment.systemPackages = [
    pkgs.docker
  ];

  users.users.${username}.linger = true;

  systemd.user.services.userservices = {
    description = "Docker compose stack in ~/services";
    after = [ "default.target" "docker.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "%h/services";
      ExecStart = "${pkgs.docker}/bin/docker compose up -d";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
      TimeoutStartSec = 0;
    };
  };

  system.activationScripts.userservicesConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/services
    install -d -m 0755 -o ${username} -g users ${homeDir}/shared_data/services/docker-config/appflowy

    install -m 0644 -o ${username} -g users ${templateDir}/docker-compose.yml ${homeDir}/services/docker-compose.yml
    install -m 0644 -o ${username} -g users ${templateDir}/appflowy.nginx.conf ${homeDir}/shared_data/services/docker-config/appflowy/nginx.conf
  '';
}
