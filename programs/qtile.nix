{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir displayOutput maxResolution autoRunSteamBigPicture neverSleep;

  qtileTemplate = ../templates/qtile;

  # Assumes 16:9 for the derived height (1920 -> 1080, 2560 -> 1440, 3840 -> 2160).
  maxResolutionHeight = (maxResolution * 9) / 16;

  # TV overscan compensation. Off by default (0/0); set on a per-host basis
  # in userConfig for TVs that clip the edges of the image. Applied via the
  # standard RandR "Border" property (left top right bottom), which is what
  # current NVIDIA drivers expose instead of the old "underscan" property.
  underscanHBorder = userConfig.underscanHBorder or 0;
  underscanVBorder = userConfig.underscanVBorder or 0;
  underscanCmd = lib.optionalString (underscanHBorder != 0 || underscanVBorder != 0) ''
    xrandr --output ${displayOutput} --set Border "${toString underscanHBorder} ${toString underscanVBorder} ${toString underscanHBorder} ${toString underscanVBorder}"
  '';

  xinitrc = pkgs.replaceVars ../templates/x/xinitrc {
    inherit displayOutput underscanCmd;
    maxResolutionWidth = toString maxResolution;
    maxResolutionHeight = toString maxResolutionHeight;
  };

  autostart = pkgs.replaceVars ../templates/qtile/autostart.sh {
    autoRunSteamBigPicture = if autoRunSteamBigPicture then "true" else "false";
    neverSleep = if neverSleep then "true" else "false";
  };

  # Steam/TV setups get a full-width bar with 2 workspaces instead of the
  # centered minimal bar with 9 workspaces used everywhere else.
  configPy = pkgs.replaceVars ../templates/qtile/config.py {
    barModule = if autoRunSteamBigPicture then "bar_steam_tv" else "bar_default";
    workspaceGroupChars = if autoRunSteamBigPicture then "12" else "123456789";
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
    install -m 0644 -o ${username} -g users ${configPy} ${homeDir}/.config/qtile/config.py

    chown -R ${username}:users ${homeDir}/.config/qtile
    find ${homeDir}/.config/qtile -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/qtile -type f -exec chmod 0644 {} \;
    chmod 0755 ${homeDir}/.config/qtile/autostart.sh
  '';
}
