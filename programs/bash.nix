{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;

  bashrc = ../templates/shell/bashrc.sh;
  bashProfile = ../templates/shell/bash_profile.sh;
  toolIntegrations = ../templates/shell/tool_integrations.sh;

  aliasSh = pkgs.replaceVars ../templates/shell/alias.sh {
    inherit flakePath flakeName;
  };

  devEnv = pkgs.replaceVars ../templates/shell/dev_env.sh {
    jdk = pkgs.jdk;
  };
in
{
  programs.bash.enable = true;

  environment.systemPackages = [
    pkgs.bash
    pkgs.eza
    pkgs.bat
    pkgs.fd
    pkgs.neovim
    pkgs.git
  ];

  system.activationScripts.bashConfig.text = ''
    mkdir -p ${homeDir}
    mkdir -p ${homeDir}/.config/shell

    rm -f ${homeDir}/.bashrc
    rm -f ${homeDir}/.bash_profile
    rm -f ${homeDir}/.config/shell/alias.sh
    rm -f ${homeDir}/.config/shell/dev_env.sh
    rm -f ${homeDir}/.config/shell/tool_integrations.sh

    install -m 0644 -o ${username} -g users ${bashrc} ${homeDir}/.bashrc
    install -m 0644 -o ${username} -g users ${bashProfile} ${homeDir}/.bash_profile
    install -m 0644 -o ${username} -g users ${aliasSh} ${homeDir}/.config/shell/alias.sh
    install -m 0644 -o ${username} -g users ${devEnv} ${homeDir}/.config/shell/dev_env.sh
    install -m 0644 -o ${username} -g users ${toolIntegrations} ${homeDir}/.config/shell/tool_integrations.sh

    chown ${username}:users ${homeDir}/.bashrc
    chown ${username}:users ${homeDir}/.bash_profile
    chown ${username}:users ${homeDir}/.config/shell/alias.sh
    chown ${username}:users ${homeDir}/.config/shell/dev_env.sh
    chown ${username}:users ${homeDir}/.config/shell/tool_integrations.sh
    chown ${username}:users ${homeDir}/.config/shell
  '';
}
