# REF: https://github.com/diogotcorreia/dotfiles/blob/nixos/profiles/graphical/flameshot.nix

{ config, pkgs, ... }:

{
  programs.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = true;
        savePath = "/tmp";
        savePathFixed = false;
        saveAsFileExtension = ".png";
        uiColor = "${lib.my.colors.lightblue}";
        startupLaunch = false;
        antialiasingPinZoom = true;
        uploadWithoutConfirmation = false;
        predefinedColorPaletteLarge = true;
        useGrimAdapter = true;
      };
    };
  };
}
