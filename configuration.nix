{ config, pkgs, buildEnv, lib, qtile-flake, ... }:

assert buildEnv.username != "" && buildEnv.username != null;

let
  # Detect architecture
  isX86_64 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
  # isAarch64 = pkgs.stdenv.hostPlatform.system == "aarch64-linux";
  # isParallels = builtins.pathExists /dev/prl_fs;

  # there is an issue where 1060 might not be supported directly and
  # where the gpu might not be ready when service is up
  myOllama = pkgs.ollama-cuda.override {
    cudaArches = [ "61" ];
  };
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl."vm.overcommit_memory" = 1; # fixes memory warning on docker redis

  # Reduce USB error spam on console (hide info/debug messages)
  boot.consoleLogLevel = 3;

  # Try to fix USB timeout issues
  boot.kernelParams = [
    "usbcore.autosuspend=-1"  # Disable USB autosuspend
  ];

  networking.hostName = "nixos-${buildEnv.username}";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nix.settings.download-buffer-size = 268435456; # 256 MiB

  # ─── CLI ───────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  # programs.neovim.enable = true;

  # Create /bin/sh and /bin/zsh symlinks for compatibility
  environment.binsh = "${pkgs.bash}/bin/sh";
  environment.pathsToLink = [ "/bin" ];
  system.activationScripts.binzsh = ''
    ln -sf ${pkgs.zsh}/bin/zsh /bin/zsh || true
  '';

  # ─── DE / WM ──────────────────────────────────────
  # Enable dconf for GTK settings (required for GTK dark mode and theme settings)
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.dconf ];

  services.libinput.enable = true; # required by calibre

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

  services.getty.autologinUser = buildEnv.username;
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

  # ─── USER ──────────────────────────────────────
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${buildEnv.username} = {
    isNormalUser = true;
    description = buildEnv.username;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "libvirtd" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;  # Set zsh as default shell
  };

  # ─── AUDIO ───────────────────────────────────────────────────────────
  # PipeWire (modern audio, replaces PulseAudio + JACK)
  security.rtkit.enable = true; # realtime scheduling for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = isX86_64; # Only on x86_64
    pulse.enable = true; # PulseAudio compatibility
    jack.enable = true; # JACK compatibility
  };

  # ─── HARDWARE & FIRMWARE ─────────────────────────────────────────────
  hardware.enableAllFirmware = true; # enable all firmware (includes non-free)
  # CPU microcode updates (architecture-specific)
  hardware.cpu.amd.updateMicrocode = lib.mkIf isX86_64 true;
  hardware.cpu.intel.updateMicrocode = lib.mkIf isX86_64 true;

  # ─── USB & STORAGE ───────────────────────────────────────────────────
  services.udisks2.enable = true; # disk management service
  services.gvfs.enable = true; # virtual filesystem (for USB automount in file managers)
  security.polkit.enable = true;

  # Filesystem support for various storage types
  boot.supportedFilesystems = [
    "ntfs"      # Windows NTFS
    "exfat"     # exFAT (USB drives, SD cards)
    "vfat"      # FAT32
    "ext4"      # Linux ext4
    "btrfs"     # Linux btrfs
    "xfs"       # Linux XFS
    "f2fs"      # Flash-friendly filesystem (SSDs, SD cards)
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;

  # Allow insecure packages (required for some Electron apps like Discord/Slack)
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # NOTE: required for zoom for example under aarch64
  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [
    # Core CLI tools
    vim
    git
    curl
    wget
    gnumake

    # GTK/dconf support
    dconf
    glib

    # Filesystem utilities (CLI)
    ntfs3g          # NTFS read/write support
    exfatprogs      # exFAT utilities (mkfs, fsck)
    dosfstools      # FAT32 utilities (mkfs.vfat, fsck.vfat)
    e2fsprogs       # ext2/3/4 utilities
    btrfs-progs     # btrfs utilities
    xfsprogs        # XFS utilities
    f2fs-tools      # F2FS utilities
    parted          # CLI partition editor

    # Disk management & monitoring (CLI)
    smartmontools   # S.M.A.R.T. monitoring for drives
    hdparm          # Hard disk parameters
    sdparm          # SCSI/SATA disk parameters

    # Hardware info (CLI)
    lshw
    pciutils # lspci
    usbutils # lsusb

    lxqt.lxqt-policykit

    # AI
    # ollama-cuda
    myOllama
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # auto upgrade packages
  system.autoUpgrade.enable = false;
  system.autoUpgrade.dates = "weekly";

  # automatic cleanup
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.openssh.enable = true;

  # try to fix audio mic shutting down disabling the usb autosuspend
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';

  # ─── FIREWALL ──────────────────────────────────────────────
  networking.firewall.allowedTCPPorts = [
    8384 # syncthing web gui
    4096 # opencode
    3300 # open-webui
    11434 # ollama
    # 21115 21116 21117 21118 21119 # rustdesk
  ];
  networking.firewall.allowedUDPPorts = [
    # 21116 # rustdesk
  ];

  # ─── SYSTEM MAINTENANCE ──────────────────────────────────────────────
  services.fstrim.enable = true; # Automatic SSD TRIM (weekly)

  # ─── BLUETOOTH ───────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # Note: Blueman GUI installed per-user in home.nix

  # ─── PRINTING ────────────────────────────────────────────────────────
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    hplip # HP printers
    epson-escpr # Epson printers
  ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true; # for network printer discovery
  };

  # ─── VIRTUALIZATION (optional, but useful) ──────────────────────────
  virtualisation.docker.enable = true;
  # virtualisation.libvirtd.enable = true; # for VMs (QEMU/KVM)

  # ─── PARALLELS GUEST CONFIGURATION ──────────────────────────────────
  # hardware.parallels = lib.mkIf isParallels {
  #   enable = true;
  #   autoMountShares = true;
  # };

  # # Disable Parallels printing service
  # systemd.services.prlshprint = {
  #   enable = false;
  # };

  # # Enable clipboard sharing service for Parallels (this is important!)
  # systemd.services.parallels-clipboard = lib.mkIf isParallels {
  #   description = "Parallels clipboard service";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'while true; do sleep 3600; done'";
  #     Restart = "on-failure";
  #   };
  # };

  # ───────────────────────────────────────────────────────────────────────────────
  # ─── NEXT CODE IS VERY home.nix
  # NOTE: we set these here because we don't have all of the operations
  #       and options within home.nix
  # ─── Syncthing ────────────────────────────────────────────────────────────────
  services.syncthing = {
    enable = true;
    user = buildEnv.username;
    dataDir = "/home/${buildEnv.username}/.local/share/syncthing";
    configDir = "/home/${buildEnv.username}/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384"; # Listen on all interfaces (not just localhost)
  };

  # ─── Gaming ────────────────────────────────────────────────────────────────
  # Steam is only available on x86_64
  programs.steam = lib.mkIf isX86_64 {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports for Steam Local Network Game Transfers

    # Additional gaming features
    gamescopeSession.enable = true; # GameScope compositor for better gaming performance
    protontricks.enable = true; # Tools for managing Proton prefixes
  };

  # Enable gamemode for better game performance
  programs.gamemode.enable = lib.mkIf isX86_64 true;

  # ─── AI ────────────────────────────────────────────────────────────────
  # Enable Ollama service
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
    loadModels = [ "gemma4:e2b" "gemma4:e4b"];
    # TODO: these are failing need to investigate
    # acceleration = "cuda"; # or "rocm" for AMD, or null for CPU
    # package = pkgs.ollama-cuda;
    package = myOllama;
  };

  # Enable Open WebUI (optional)
  services.open-webui = {
    enable = true;
    port = 3300;
    host = "0.0.0.0";
    # openFirewall = true;
    environment = {
      # OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "True";
    };
  };

  # ───────────────────────────────────────────────────────────────────────────────
  # ─── DONT TOUCH ────────────────────────────────────────────────────────────────
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
