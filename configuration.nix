{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-joe";
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
    # windowManager.qtile.enable = true;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.displayManager.ly.enable = true;
  services.displayManager.ly.autoLogin.enable = true;
  services.displayManager.ly.autoLogin.user = "iamajoe";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iamajoe = {
    isNormalUser = true;
    description = "iamajoe";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
  services.getty.autologinUser = "iamajoe";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # auto upgrade packages
  system.autoUpgrade.enable = false;
  system.autoUpgrade.dates = "weekly";

  # automatic cleanup
  nix.gc.automatic = true;
  nix.gc.date = "daily";
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
