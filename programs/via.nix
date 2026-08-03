{ config, pkgs, ... }:

{
  hardware.keyboard.qmk.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      via
    ];

  # Add udev rules so VIA can detect your keyboard via hidraw
  services.udev.packages = [ pkgs.via pkgs.qmk-udev-rules ];
}
