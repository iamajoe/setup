{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;

  bashrc = ../templates/shell/bashrc.sh;

  aliasSh = pkgs.substituteAll {
    src = ../templates/shell/alias.sh;
    inherit flakePath flakeName;
  };

  devEnv = pkgs.substituteAll {
    src = ../templates/shell/dev-env.sh;
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

    ln -sfn ${bashrc} ${homeDir}/.bashrc
    ln -sfn ${../templates/shell/bash_profile.sh} ${homeDir}/.bash_profile

    ln -sfn ${aliasSh} ${homeDir}/.config/shell/alias.sh
    ln -sfn ${devEnv} ${homeDir}/.config/shell/dev-env.sh
    ln -sfn ${../templates/shell/tool-integrations.sh} ${homeDir}/.config/shell/tool-integrations.sh

    chown -h ${username}:staff ${homeDir}/.bashrc
    chown -h ${username}:staff ${homeDir}/.bash_profile
    chown -h ${username}:staff ${homeDir}/.config/shell/alias.sh
    chown -h ${username}:staff ${homeDir}/.config/shell/dev-env.sh
    chown -h ${username}:staff ${homeDir}/.config/shell/tool-integrations.sh
    chown ${username}:staff ${homeDir}/.config/shell
  '';
}
