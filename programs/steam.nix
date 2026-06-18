{ config, pkgs, lib, userConfig, ... }:

let
  inherit (
    userConfig
  )
    username
    homeDir
    enableCEC
    moonlightHost
    moonlightApp
    ;
in
{
  # Start Steam automatically.
  environment.etc."xdg/autostart/steam.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Steam
    Comment=Start Steam automatically
    Exec=${pkgs.bash}/bin/bash -lc 'sleep 1; exec steam -gamepadui'
    Terminal=false
    X-GNOME-Autostart-enabled=true
    Hidden=false
  '';

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;

    # Disable this for the XFCE path.
    gamescopeSession.enable = false;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  programs.gamemode.enable = true;
  programs.xwayland.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  system.activationScripts.moonlightSteamShortcut = ''
    mkdir -p ${homeDir}/SteamShortcuts
    cat > ${homeDir}/SteamShortcuts/moonlight-steam-big-picture.sh <<'EOF'
#!/bin/bash
LOG=${homeDir}/SteamShortcuts/moonlight.log
echo "Launching Moonlight" > "$LOG"
exec /run/current-system/sw/bin/moonlight stream ${moonlightHost} "${moonlightApp}" >> "$LOG" 2>&1
EOF

    chmod +x ${homeDir}/SteamShortcuts/moonlight-steam-big-picture.sh
    chown -R ${username}:users ${homeDir}/SteamShortcuts
  '';

  environment.systemPackages =
    with pkgs;
    [
      mangohud
      gamescope
      steam
      steam-run
      moonlight-embedded
      moonlight-qt
    ]
    ++ lib.optionals enableCEC [
      libcec
      # (writeShellScriptBin "tv-on" ''
      #   echo "on 0" | ${libcec}/bin/cec-client -s -d 1
      # '')
      (writeShellScriptBin "tv-off" ''
        echo "standby 0" | ${libcec}/bin/cec-client -s -d 1
      '')
    ];
}
