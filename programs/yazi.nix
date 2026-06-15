{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  yaziTemplate = ../templates/yazi;
  yWrapper = pkgs.writeShellScriptBin "y" ''
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      printf '%s\n' "$cwd"
    fi
    rm -f "$tmp"
  '';
in
{
  environment.systemPackages = [
    pkgs.yazi
    pkgs.xdg-utils
    yWrapper
  ];

  system.activationScripts.yaziConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -rf ${homeDir}/.config/yazi

    cp -r ${yaziTemplate} ${homeDir}/.config/yazi

    chown -R ${username}:users ${homeDir}/.config/yazi
    find ${homeDir}/.config/yazi -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/yazi -type f -exec chmod 0644 {} \;
  '';
}
