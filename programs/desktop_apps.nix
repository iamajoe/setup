{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = userConfig.platform == "darwin";
  isLinux = userConfig.platform == "linux";
in
{
  fonts.packages = with pkgs; [
    nerd-fonts.noto
    nerd-fonts.tinos
    nerd-fonts.code-new-roman
    nerd-fonts.inconsolata
    nerd-fonts.commit-mono
    nerd-fonts.zed-mono
    nerd-fonts.jetbrains-mono
    font-awesome # Font Awesome 6 Free (Solid, Regular, Brands)
  ];

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };

  environment.systemPackages =
    with pkgs;
    [
      # Miscellaneous
      obsidian
      spotify

      # Communication
      slack
      zoom-us

      # qtile keybind / autostart dependencies (config.py, bar.py, autostart.sh)
      flameshot       # screenshot tool
      pamixer         # CLI audio mixer, used by volume keybinds
      playerctl       # CLI media player controller, used by media keybinds
      clipmenu        # clipboard manager (clipmenu + clipmenud), used by rofi/autostart
      xsel            # clipboard utility required by clipmenu
      blueman         # bluetooth manager, autostart runs blueman-applet
      xset            # screen blanking/DPMS control, used by autostart
      xsetroot        # root window background, used by autostart
      xinput          # kensington trackball button remap, used by xinitrc
      networkmanagerapplet # nm-applet, used by autostart

      # Desktop utilities
      brightnessctl # screen brightness control
      appimage-run  # runs AppImages
      udiskie       # automounts drives
      gparted       # GUI partition editor
      gnome-disk-utility # hard drive mount
      gsimplecal    # lightweight calendar popup
      xclip         # clipboard utility
      xdotool       # X11 automation
      hyprpicker    # color picker
      pavucontrol   # editing audio levels & devices
      rpi-imager    # raspberry pi sd card installer
      filezilla     # ftp client
      recordbox     # mp3 player
      puddletag     # mp3 metadata tags
      picard        # mp3 metadata tags

      solaar        # logitech service
      pinta         # photoshop alternative
      gimp          # photoshop alternative
      inkscape      # illustrator alternative

      discord # goes crazy with the updates on mac
      transmission_4-gtk
      google-chrome
      vlc
      kicad
      orca-slicer

      # CPU temp sensors for the bar's ThermalSensor widget.
      # Run `sudo sensors-detect` once after first boot to load the right kernel modules.
      lm_sensors

      # package to run the keyboard via app
      via
    ];
}
