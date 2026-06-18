{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username nasHost nasUser nasPassword;
  uid = toString config.users.users.${username}.uid;

  commonCifsOptions = [
    "username=${nasUser}"
    "password=${nasPassword}"
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
in
{
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  fileSystems."/mnt/music" = {
    device = "//${nasHost}/music";
    fsType = "cifs";
    options = commonCifsOptions;
  };

  fileSystems."/mnt/video" = {
    device = "//${nasHost}/video";
    fsType = "cifs";
    options = commonCifsOptions;
  };

  fileSystems."/mnt/roms" = {
    device = "//${nasHost}/roms";
    fsType = "cifs";
    options = commonCifsOptions;
  };
}
