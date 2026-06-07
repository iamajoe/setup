{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;
in
{
  environment.systemPackages = [
    pkgs.helix
  ];

  system.activationScripts.helixConfig.text = ''
    mkdir -p ${homeDir}/.config/helix

    rm -f ${homeDir}/.config/helix/config.toml
    rm -f ${homeDir}/.config/helix/languages.toml
    rm -rf ${homeDir}/.config/helix/themes

    ln -sfn ${../templates/helix/config.toml} ${homeDir}/.config/helix/config.toml
    ln -sfn ${../templates/helix/languages.toml} ${homeDir}/.config/helix/languages.toml
    ln -sfn ${../templates/helix/themes} ${homeDir}/.config/helix/themes

    chown -h ${username}:staff ${homeDir}/.config/helix/config.toml
    chown -h ${username}:staff ${homeDir}/.config/helix/languages.toml
    chown -h ${username}:staff ${homeDir}/.config/helix/themes
    chown ${username}:staff ${homeDir}/.config/helix
  '';
}
