{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir displayOutput maxResolution autoRunSteamBigPicture neverSleep;

  qtileTemplate = ../templates/qtile;

  # Assumes 16:9 for the derived height (1920 -> 1080, 2560 -> 1440, 3840 -> 2160).
  maxResolutionHeight = (maxResolution * 9) / 16;

  xinitrc = pkgs.replaceVars ../templates/x/xinitrc {
    inherit displayOutput;
    maxResolutionWidth = toString maxResolution;
    maxResolutionHeight = toString maxResolutionHeight;
  };

  autostart = pkgs.replaceVars ../templates/qtile/autostart.sh {
    autoRunSteamBigPicture = if autoRunSteamBigPicture then "true" else "false";
    neverSleep = if neverSleep then "true" else "false";
  };
in
{
  system.activationScripts.qtileConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -f ${homeDir}/.xinitrc
    rm -rf ${homeDir}/.config/qtile

    install -m 0755 -o ${username} -g users ${xinitrc} ${homeDir}/.xinitrc

    cp -r ${qtileTemplate} ${homeDir}/.config/qtile
    install -m 0755 -o ${username} -g users ${autostart} ${homeDir}/.config/qtile/autostart.sh

    chown -R ${username}:users ${homeDir}/.config/qtile
    find ${homeDir}/.config/qtile -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/qtile -type f -exec chmod 0644 {} \;
    chmod 0755 ${homeDir}/.config/qtile/autostart.sh
  '';
}
