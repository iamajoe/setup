{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;
in
{
  environment.systemPackages = [
    pkgs.rclone
    pkgs.openssl
  ];

  # systemd.services.rclone-bisync-joe-mac = {
  #   description = "rclone bisync with Joe's Mac";

  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "${username}";

  #     ExecStart = "${pkgs.rclone}/bin/rclone bisync ${homeDir}/shared_data joe_mac:/Users/joel/shared_data";
  #   };
  # };

  # systemd.timers.rclone-bisync-joe-mac = {
  #   description = "Run rclone bisync with Joe's Mac";

  #   wantedBy = [ "timers.target" ];

  #   timerConfig = {
  #     OnCalendar = "*-*-* *:00:00";
  #     Persistent = true;
  #   };
  # };

  # systemd.services.rclone-bisync-tv-steam = {
  #   description = "rclone bisync with tv steam";

  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "${username}";

  #     ExecStart = "${pkgs.rclone}/bin/rclone bisync ${homeDir}/shared_data tv_steam:/home/${username}/shared_data";
  #   };
  # };

  # systemd.timers.rclone-bisync-tv-steam = {
  #   description = "Run rclone bisync with tv steam";

  #   wantedBy = [ "timers.target" ];

  #   timerConfig = {
  #     OnCalendar = "*-*-* *:00:00";
  #     Persistent = true;
  #   };
  # };

  # systemd.services.rclone-bisync-joe-workstation = {
  #   description = "rclone bisync with Joe's workstation";

  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "${username}";

  #     ExecStart = "${pkgs.rclone}/bin/rclone bisync ${homeDir}/shared_data joe_workstation:/home/${username}/shared_data";
  #   };
  # };

  # systemd.timers.rclone-bisync-joe-workstation = {
  #   description = "Run rclone bisync with Joe's workstation";

  #   wantedBy = [ "timers.target" ];

  #   timerConfig = {
  #     OnCalendar = "*-*-* *:00:00";
  #     Persistent = true;
  #   };
  # };
}
