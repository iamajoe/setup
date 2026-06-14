{ config, pkgs, lib, userConfig, ... }:

{
  # ─── DE / WM ──────────────────────────────────────
  # Enable dconf for GTK settings (required for GTK dark mode and theme settings)
  programs.dconf.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.dconf ];

  services.libinput.enable = true; # required by calibre

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    # HiDPI support
    dpi = 96;  # 1.5x scaling for HiDPI displays
    # dpi = 144;  # 1.5x scaling for HiDPI displays
    # dpi = 192;  # 2x scaling for HiDPI displays (commented out - was too large)

    # Configure keymap in X11
    xkb = {
      layout = "us,pt";  # Multiple layouts: US English and Portuguese
      variant = "";
      options = "ctrl:nocaps";  # Caps Lock acts as Control
      # options = "grp:alt_shift_toggle,ctrl:nocaps";  # Alt+Shift to switch layouts + Caps→Ctrl
    };

    windowManager.qtile = {
      enable = true;
      # package = qtile-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
      package =
    (qtile-flake.packages.${pkgs.stdenv.hostPlatform.system}.default).overrideAttrs
      (old: {
        doCheck = false;
      });
      extraPackages = python3Packages: with python3Packages; [
        qtile-extras
      ];
    };

    displayManager.startx.enable = true;

    # Parallels-specific X11 configuration for proper resolution
    # resolutions = lib.mkIf isParallels [
    #   { x = 1920; y = 1080; }
    #   { x = 2560; y = 1440; }
    #   { x = 3840; y = 2160; }
    # ];
  };

  # auto login going in
  services.displayManager.ly.enable = false;
  # services.displayManager = {
  #   ly.enable = true;
  #   defaultSession = "qtile";
  #   ly.settings = {
  #     save = true;               # Save last session/user choice
  #     save_file = "/var/cache/ly/save";
  #   };
  # };

  # Ensure ly save directory exists
  systemd.tmpfiles.rules = [
    "d /var/cache/ly 0755 root root -"
  ];

  services.getty.autologinUser = userConfig.username;
  services.gnome.gnome-keyring.enable = true;

  # ─── GPU DRIVERS ──────────────────────────────────────
  # OpenGL/graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit app support (x86_64 only, required for Steam)
    # extraPackages = with pkgs; [
    #   # Intel
    #   intel-media-driver # LIBVA_DRIVER_NAME=iHD
    #   intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for some)
    #   libva-vdpau-driver # VDPAU backend for VA-API (renamed from vaapiVdpau)
    #   libvdpau-va-gl
    #   # Note: ROCm packages commented out due to build issues
    #   # rocmPackages.clr.icd # AMD OpenCL
    #   # amdvlk # AMD Vulkan
    # ];
  };

  # NVIDIA-specific configuration (x86_64 only)
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # GTX 1060 is too old for NVIDIA's open kernel module path
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}

