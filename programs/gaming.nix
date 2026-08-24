{ config, pkgs, lib, userConfig, ... }:

let
  isX86_64 = userConfig.system == "x86_64-linux";
in
{
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
  hardware.uinput.enable = true;

  # Xbox wireless controller driver (Big Picture controller support)
  hardware.xpadneo.enable = true;

  # Enable gamemode for better game performance
  programs.gamemode.enable = lib.mkIf isX86_64 true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # ─── FIREWALL ──────────────────────────────────────────────
  networking.firewall.allowedTCPPorts = [
    # sunshine / gaming
    47984
    47989
    47990
    48010
  ];
  networking.firewall.allowedUDPPorts = [
    # sunshine / gaming
    47998
    47999
    48000
    48002
    48010
  ];

  # ─── PACKAGES ──────────────────────────────────────────────
  environment.systemPackages =
    with pkgs;
    [
      solaar        # logitech service
    ];
}

