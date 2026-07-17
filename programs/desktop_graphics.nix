{ config, pkgs, lib, userConfig, qtile-flake, ... }:

let
  inherit (userConfig) username homeDir dpi cursorSize;
  inherit (userConfig) maxResolution underscanH underscanV;

  # Assumes 16:9 for the derived height (matches programs/qtile.nix).
  maxResolutionHeight = (maxResolution * 9) / 16;

  # TV overscan compensation via NVIDIA viewportout crop: px trimmed from
  # each dimension, split evenly across both edges.
  underscanViewportWidth = maxResolution - underscanH;
  underscanViewportHeight = maxResolutionHeight - underscanV;
  underscanOffsetX = underscanH / 2;
  underscanOffsetY = underscanV / 2;

  cursorTheme = "Adwaita";
  iconTheme = "Papirus-Dark";
  gtkTheme = "Adwaita-dark";

  xresources = ''
    Xft.dpi: ${toString dpi}
    Xcursor.theme: ${cursorTheme}
    Xcursor.size: ${toString cursorSize}
  '';

  gtk3Settings = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=${gtkTheme}
    gtk-icon-theme-name=${iconTheme}
    gtk-fallback-icon-theme=Adwaita
    gtk-cursor-theme-name=${cursorTheme}
    gtk-cursor-theme-size=${toString cursorSize}
  '';

  gtk4Settings = gtk3Settings;
in
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
    # Pre-1.17 behaviour: use the first portal implementation found.
    config.common.default = "*";
  };

  # Sync Qt apps to the GTK dark theme (Adwaita-dark, via adwaita-qt/adwaita-qt6)
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  } // lib.optionalAttrs (userConfig.gpu == "intel") {
    # Pin VA-API to the modern driver; intel-vaapi-driver (i965) doesn't
    # support 11th/12th gen anyway, but this removes any ambiguity.
    LIBVA_DRIVER_NAME = "iHD";
  };

  environment.systemPackages = with pkgs; [
    gnome-themes-extra # Adwaita(-dark) GTK theme
    adwaita-icon-theme
    papirus-icon-theme
    adwaita-qt         # Qt5 Adwaita-dark style
    adwaita-qt6        # Qt6 Adwaita-dark style
    qt6Packages.qt6ct

    # GPU testing/info tools
    vulkan-tools # vulkaninfo, vkcube
    mesa-demos   # glxinfo, glxgears
  ];

  system.activationScripts.desktopThemeConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config/gtk-3.0
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config/gtk-4.0

    # Remove any pre-existing file/symlink (e.g. a stale home-manager symlink
    # into a since-collected /nix/store path) before writing.
    rm -f ${homeDir}/.Xresources
    rm -f ${homeDir}/.config/gtk-3.0/settings.ini
    rm -f ${homeDir}/.config/gtk-4.0/settings.ini

    cat > ${homeDir}/.Xresources <<'EOF'
${xresources}
EOF
    cat > ${homeDir}/.config/gtk-3.0/settings.ini <<'EOF'
${gtk3Settings}
EOF
    cat > ${homeDir}/.config/gtk-4.0/settings.ini <<'EOF'
${gtk4Settings}
EOF

    chown ${username}:users ${homeDir}/.Xresources
    chown -R ${username}:users ${homeDir}/.config/gtk-3.0
    chown -R ${username}:users ${homeDir}/.config/gtk-4.0
  '';

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;

    dpi = dpi;

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
  # Driven by userConfig.gpu ("nvidia" | "intel" | "none") since machines on
  # this repo have different GPUs (e.g. TV box: GTX 1060, workstation: Intel iGPU only).
  # OpenGL/graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit app support (x86_64 only, required for Steam)
    extraPackages = lib.optionals (userConfig.gpu == "intel") (with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for some)
      libva-vdpau-driver # VDPAU backend for VA-API (renamed from vaapiVdpau)
      libvdpau-va-gl
      vpl-gpu-rt          # oneVPL for 11th gen+ Intel iGPUs (Quick Sync)
    ]);
  };

  # NVIDIA-specific configuration (x86_64 only)
  services.xserver.videoDrivers = lib.optional (userConfig.gpu == "nvidia") "nvidia";
  hardware.nvidia = lib.mkIf (userConfig.gpu == "nvidia") {
    modesetting.enable = true;
    open = false; # GTX 1060 is too old for NVIDIA's open kernel module path
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # TV overscan compensation via NVIDIA viewportout crop (see local-config
  # flake.nix.dist underscanH/underscanV). Generated from an xorg.conf saved
  # manually via nvidia-settings.
  services.xserver.screenSection = lib.mkIf
    (userConfig.gpu == "nvidia" && (underscanH > 0 || underscanV > 0)) ''
    Option "metamodes" "${toString maxResolution}x${toString maxResolutionHeight}_60 +0+0 {viewportout=${toString underscanViewportWidth}x${toString underscanViewportHeight}+${toString underscanOffsetX}+${toString underscanOffsetY}}"
  '';

  # Intel iGPU: fixes for display flicker/tearing on some 11th/12th gen chips
  boot.kernelParams = lib.optionals (userConfig.gpu == "intel") [
    "i915.enable_psr=0"
    "i915.enable_fbc=0"
  ];
}

