{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) hostname username homeDir initialPassword networkInterface enableWakeOnLan;
in
{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = hostname;

  # Timezone and local
  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    useXkbConfig = true;
    earlySetup = true;
  };

  services.xserver = {
    enable = true;

    desktopManager.xfce = {
      enable = true;
      noDesktop = true;
      enableXfwm = true;
    };

    displayManager = {
      lightdm = {
        enable = true;
        greeters.gtk.enable = true;
      };

      autoLogin = {
        enable = true;
        user = username;
      };
      defaultSession = "xfce";
    };
    displayManager.sessionCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-2 --mode 1280x720 --rate 60 --primary || true

      # Disable X11 screen blanking, screensaver, and DPMS power saving.
      ${pkgs.xorg.xset}/bin/xset s off || true
      ${pkgs.xorg.xset}/bin/xset -dpms || true
      ${pkgs.xorg.xset}/bin/xset s noblank || true

      # Disable XFCE screensaver / locker behavior.
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-screensaver -p /lock/enabled -n -t bool -s false || true
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-screensaver -p /saver/enabled -n -t bool -s false || true
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-screensaver -p /lock/saver-activation/enabled -n -t bool -s false || true

      # Disable XFCE session lock command, so xflock4 has nothing useful to call.
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-session -p /general/LockCommand -n -t string -s "" || true
    '';
  };

  services.seatd.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "steam tv";
    home = "${homeDir}";
    createHome = true;
    initialPassword = initialPassword;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "seat" ];
  };

  networking.networkmanager.enable = true;

  networking.interfaces.${networkInterface}.wakeOnLan.enable = enableWakeOnLan;
  networking.firewall.allowedUDPPorts = lib.optionals enableWakeOnLan [ 9 ];

  security.rtkit.enable = true;

  hardware.alsa.enablePersistence = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  systemd.user.services.force-hdmi-audio = {
    description = "Force HDMI audio profile";
    wantedBy = [ "default.target" ];
    after = [ "pipewire.service" "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellScript "force-hdmi-audio" ''
          CARD="$( ${pkgs.pulseaudio}/bin/pactl list cards short | ${pkgs.gnugrep}/bin/grep 'alsa_card.pci-0000_00_1f.3' | ${pkgs.coreutils}/bin/cut -f1 )"
          [ -n "$CARD" ] && exec ${pkgs.pulseaudio}/bin/pactl set-card-profile "$CARD" output:hdmi-stereo
        '';
      in "${script}";
    };
  };

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.fwupd.enable = true;

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 1 * * * root /run/current-system/sw/bin/systemctl poweroff"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.auto-optimise-store = true;

  services.logind.settings.Login = {
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

  services.greetd.enable = false;
  # services.greetd = {
  #   enable = true;
  #   settings = rec {
  #     initial_session = {
  #       user = userName;
  #       # command = "${lib.getExe pkgs.gamescope} -W ${toString steamWidth} -H ${toString steamHeight} -f -e --xwayland-count 2 -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3";
  #       # command = "${lib.getExe pkgs.gamescope} -W ${toString steamWidth} -H ${toString steamHeight} -f -e --xwayland-count 2 -- steam -pipewire-dmabuf -gamepadui";
  #       # command = "${lib.getExe pkgs.gamescope} -W ${toString steamWidth} -H ${toString steamHeight} -r 60 -f -e --xwayland-count 2 -- steam -gamepadui";
  #       # command = "${lib.getExe pkgs.gamescope} -W 1280 -H 720 -w 1280 -h 720 -f -r 60 --disable-color-management -- env ENABLE_GAMESCOPE_WSI=0 steam -gamepadui";
  #       command = "${pkgs.xfce.xfce4-session}/bin/startxfce4";
  #     };
  #     default_session = initial_session;
  #   };
  # };

  services.getty.autologinUser = username;
  # services.getty.autologinUser = lib.mkForce null;

  environment.systemPackages = with pkgs; [
    vim
    helix
    git
    wget
    curl
    pciutils
    usbutils
    firefox
    alsa-utils
    pavucontrol
    pulseaudio
    wireplumber
    xorg.xrandr
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth.enable = true;
  boot.kernelParams = [
    "quiet"
    "splash"
    "i915.enable_psr=0"
    "i915.enable_fbc=0"
  ];

  # DONT TOUCH
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";
}
