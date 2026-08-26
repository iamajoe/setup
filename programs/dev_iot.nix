{ config, pkgs, lib, userConfig, ... }:

let
  isLinux = userConfig.platform == "linux";
in
{
  environment.systemPackages = with pkgs; [
    git
    gcc
    clang
    gdb
    cmake
    ninja
    gnumake

    python3
    python3Packages.pyserial

    usbutils
    picocom
    minicom

    platformio

    avrdude
    esptool

    openocd
    mosquitto
    mqttx
    meshtastic
  ];

  services.udev.packages = [
    pkgs.platformio-core.udev
  ];
}
