{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  helixTemplate = ../templates/helix;
in
{
  environment.systemPackages = [
    pkgs.helix
  ];

  system.activationScripts.helixConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -rf ${homeDir}/.config/helix

    cp -r ${helixTemplate} ${homeDir}/.config/helix

    chown -R ${username}:users ${homeDir}/.config/helix
    find ${homeDir}/.config/helix -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/helix -type f -exec chmod 0644 {} \;
  '';
}
