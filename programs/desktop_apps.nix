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

  environment.systemPackages =
    with pkgs;
    [
      # Miscellaneous
      obsidian
      spotify

      # Communication
      slack
      zoom-us

      # qtile keybind / autostart dependencies (config.py, bar_default.py, autostart.sh)
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
      gparted       # GUI partition editor
      gsimplecal    # lightweight calendar popup
      xclip         # clipboard utility
      xdotool       # X11 automation
      hyprpicker    # color picker
      pavucontrol   # editing audio levels & devices
      rpi-imager    # raspberry pi sd card installer
    ]

    # Linux-specific packages
    ++ lib.optionals isLinux [
      discord # goes crazy with the updates on mac
      transmission_4-gtk
      google-chrome
      gimp
      vlc
      kicad
      orca-slicer

      thunar                # file manager, used by qtile keybind
      thunar-volman         # automatic management of removable devices
      thunar-archive-plugin # archive support (unzip, unrar, etc.)

      # CPU temp sensors for the bar's ThermalSensor widget.
      # Run `sudo sensors-detect` once after first boot to load the right kernel modules.
      lm_sensors
    ]

    # macOS-specific packages
    ++ lib.optionals isDarwin [
      transmission_4
      # TODO: missing these
      # - vlc
      # - kicad
      # - orca slicer
    ];
}
