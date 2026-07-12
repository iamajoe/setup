{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;
in
{
  environment.systemPackages = [
    pkgs.zed-editor
  ];

  system.activationScripts.zedConfig.text = ''
    mkdir -p ${homeDir}/.config/zed

    rm -f ${homeDir}/.config/zed/settings.json

    ln -sfn ${../templates/zed/settings.json} ${homeDir}/.config/zed/settings.json

    chown ${username}:users ${homeDir}/.config/zed
    chown -h ${username}:users ${homeDir}/.config/zed/settings.json
  '';
}
