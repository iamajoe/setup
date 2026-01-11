{ config, pkgs, buildEnv, ... }:

assert buildEnv.username != "" && buildEnv.username != null;

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    
    # GPU drivers - all major vendors for easy GPU swapping
    videoDrivers = [ "nvidia" "amdgpu" "intel" ];
    
    # windowManager.qtile.enable = true;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.displayManager.ly.enable = true;

  # ─── GPU DRIVERS ─────────────────────────────────────────────────────
  # OpenGL/graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # for 32-bit apps/games
    extraPackages = with pkgs; [
      # Intel
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for some)
      vaapiVdpau
      libvdpau-va-gl
      
      # AMD
      rocmPackages.clr.icd # OpenCL
      amdvlk # Vulkan
    ];
  };

  # NVIDIA-specific configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # proprietary driver (set to true for open-source)
    nvidiaSettings = true; # nvidia-settings tool
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${buildEnv.username} = {
    isNormalUser = true;
    description = buildEnv.username;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "libvirtd" ];
    packages = with pkgs; [];
  };
  services.getty.autologinUser = buildEnv.username;

  # ─── AUDIO ───────────────────────────────────────────────────────────
  # PipeWire (modern audio, replaces PulseAudio + JACK)
  security.rtkit.enable = true; # realtime scheduling for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # PulseAudio compatibility
    jack.enable = true; # JACK compatibility
  };

  # ─── HARDWARE & FIRMWARE ─────────────────────────────────────────────
  hardware.enableAllFirmware = true; # enable all firmware (includes non-free)
  hardware.cpu.amd.updateMicrocode = true; # AMD microcode updates
  hardware.cpu.intel.updateMicrocode = true; # Intel microcode updates

  # ─── USB & STORAGE ───────────────────────────────────────────────────
  services.udisks2.enable = true; # disk management service
  services.gvfs.enable = true; # virtual filesystem (for USB automount in file managers)
  
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

  # NOTE: required for zoom for example under aarch64
  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [
    # Core CLI tools
    vim
    git
    curl
    wget
    
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
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # auto upgrade packages
  system.autoUpgrade.enable = false;
  system.autoUpgrade.dates = "weekly";

  # automatic cleanup
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";
  nix.settings.auto-optimise-store = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.openssh.enable = true;

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
