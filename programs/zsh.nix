{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;

  zshrc = pkgs.substituteAll {
    src = ../templates/shell/zshrc.sh;
    ohMyZsh = pkgs.oh-my-zsh;
    zshAutosuggestions = pkgs.zsh-autosuggestions;
    zshSyntaxHighlighting = pkgs.zsh-syntax-highlighting;
  };

  aliasSh = pkgs.substituteAll {
    src = ../templates/shell/alias.sh;
    inherit flakePath flakeName;
  };

  devEnv = pkgs.substituteAll {
    src = ../templates/shell/dev_env.sh;
    jdk = pkgs.jdk;
  };
in
{
  programs.zsh.enable = true;
  users.users.${username}.shell = pkgs.zsh;

  environment.systemPackages = [
    pkgs.zsh
    pkgs.oh-my-zsh
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
    pkgs.eza
    pkgs.bat
    pkgs.fd
    pkgs.neovim
    pkgs.git
  ];

  system.activationScripts.zshConfig.text = ''
    mkdir -p ${homeDir}
    mkdir -p ${homeDir}/.local/share/zsh
    mkdir -p ${homeDir}/.config/shell

    rm -f ${homeDir}/.zshrc
    rm -f ${homeDir}/.zprofile

    ln -sfn ${zshrc} ${homeDir}/.zshrc
    ln -sfn ${../templates/shell/zprofile.sh} ${homeDir}/.zprofile

    ln -sfn ${aliasSh} ${homeDir}/.config/shell/alias.sh
    ln -sfn ${devEnv} ${homeDir}/.config/shell/dev_env.sh
    ln -sfn ${../templates/shell/tool_integrations.sh} ${homeDir}/.config/shell/tool_integrations.sh

    chown -h ${username}:staff ${homeDir}/.zshrc
    chown -h ${username}:staff ${homeDir}/.zprofile
    chown -h ${username}:staff ${homeDir}/.config/shell/alias.sh
    chown -h ${username}:staff ${homeDir}/.config/shell/dev_env.sh
    chown -h ${username}:staff ${homeDir}/.config/shell/tool_integrations.sh
    chown -R ${username}:staff ${homeDir}/.local
    chown ${username}:staff ${homeDir}/.config/shell
  '';
}
