{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username nasHost;
  uid = toString config.users.users.${username}.uid;
in
{
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  fileSystems."/mnt/music" = {
    device = "//${nasHost}/music";
    fsType = "cifs";
    options = [
      "guest"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=10s"
      "uid=${uid}"
      "gid=100"
      "file_mode=0664"
      "dir_mode=0775"
      "iocharset=utf8"
      "vers=3.0"
    ];
  };

  fileSystems."/mnt/video" = {
    device = "//${nasHost}/video";
    fsType = "cifs";
    options = [
      "guest"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=10s"
      "uid=${uid}"
      "gid=100"
      "file_mode=0664"
      "dir_mode=0775"
      "iocharset=utf8"
      "vers=3.0"
    ];
  };
}
