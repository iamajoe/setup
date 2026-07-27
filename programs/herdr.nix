{ pkgs, herdr, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  herdrTemplate = ../templates/herdr;
in
{
  environment.systemPackages = [
    herdr.packages.${userConfig.system}.default
  ];

  system.activationScripts.herdrConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -rf ${homeDir}/.config/herdr/config.toml
    cp -r ${herdrTemplate}/config.toml ${homeDir}/.config/herdr/config.toml
    chown -R ${username}:users ${homeDir}/.config/herdr/config.toml
  '';
}
