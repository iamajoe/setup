{ config, pkgs, lib, userConfig, ... }:

let
  isX86_64 = userConfig.system == "x86_64-linux";
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

  networking.hostName = "${userConfig.hostname}";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true;
  services.resolved = {
    enable = true;
    settings.Resolve = {
      FallbackDNS = [ "1.1.1.1" "8.8.8.8" ];
    };
  };
  networking.networkmanager.dns = "systemd-resolved";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

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

  # ─── USER ──────────────────────────────────────
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.username;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "libvirtd" "input" "uinput" ];
    packages = with pkgs; [];
  };

  # ─── HARDWARE & FIRMWARE ─────────────────────────────────────────────
  hardware.enableAllFirmware = true; # enable all firmware (includes non-free)
  # CPU microcode updates (architecture-specific)
  hardware.cpu.amd.updateMicrocode = lib.mkIf isX86_64 true;
  hardware.cpu.intel.updateMicrocode = lib.mkIf isX86_64 true;

  # Use the same keyboard layout on the plain TTY console as X does
  console.useXkbConfig = true;

  # Firmware updates (LVFS)
  services.fwupd.enable = true;

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
    helix
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
    ncdu            # utility for tree disk dimensions

    # Disk management & monitoring (CLI)
    smartmontools   # S.M.A.R.T. monitoring for drives
    hdparm          # Hard disk parameters
    sdparm          # SCSI/SATA disk parameters

    # Hardware info (CLI)
    lshw
    pciutils # lspci
    usbutils # lsusb

    lxqt.lxqt-policykit

    # Secret handling
    libsecret
    seahorse
    gnome-keyring
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

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      curl
    ];
  };

  # ─── SYSTEM MAINTENANCE ──────────────────────────────────────────────
  services.fstrim.enable = true; # Automatic SSD TRIM (weekly)

  # ─── BLUETOOTH ───────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ─── PRINTING ────────────────────────────────────────────────────────
  services.printing.enable = lib.mkIf isX86_64 true;
  services.printing.drivers = with pkgs; [
    gutenprint
    hplip # HP printers
    epson-escpr # Epson printers
  ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true; # for network printer discovery

    publish = {
      enable = true;
      userServices = true;
    };
  };

  # ─── VIRTUALIZATION (optional, but useful) ──────────────────────────
  virtualisation.docker.enable = true;
  # virtualisation.libvirtd.enable = true; # for VMs (QEMU/KVM)

  # ─── POWER MANAGEMENT ────────────────────────────────────────────────
  # neverSleep: TV boxes never suspend/hibernate on idle or power/lid events.
  # Set userConfig.neverSleep = false on a workstation that should suspend/hibernate/lock normally.
  services.logind.settings.Login = lib.mkIf userConfig.neverSleep {
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "poweroff";
    HandleRebootKey = "reboot";
    IdleAction = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # autoPoweroffNightly: power off every night at 01:00 (TV convenience).
  services.cron = lib.mkIf userConfig.autoPoweroffNightly {
    enable = true;
    systemCronJobs = [
      "0 1 * * * root /run/current-system/sw/bin/systemctl poweroff"
    ];
  };

  # ───────────────────────────────────────────────────────────────────────────────
  # ─── DONT TOUCH ────────────────────────────────────────────────────────────────
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
