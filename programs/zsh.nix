{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir flakePath flakeName;

  zprofile = ../templates/shell/zprofile.sh;
  toolIntegrations = ../templates/shell/tool_integrations.sh;

  zshrc = pkgs.replaceVars ../templates/shell/zshrc.sh {
    ohMyZsh = pkgs.oh-my-zsh;
    zshAutosuggestions = pkgs.zsh-autosuggestions;
    zshSyntaxHighlighting = pkgs.zsh-syntax-highlighting;
  };

  aliasSh = pkgs.replaceVars ../templates/shell/alias.sh {
    inherit flakePath flakeName;
  };

  devEnv = pkgs.replaceVars ../templates/shell/dev_env.sh {
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
    install -d -m 0755 -o ${username} -g users ${homeDir}
    install -d -m 0755 -o ${username} -g users ${homeDir}/.local/share/zsh
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config/shell

    rm -f ${homeDir}/.zshrc
    rm -f ${homeDir}/.zprofile
    rm -f ${homeDir}/.config/shell/alias.sh
    rm -f ${homeDir}/.config/shell/dev_env.sh
    rm -f ${homeDir}/.config/shell/tool_integrations.sh

    install -m 0644 -o ${username} -g users ${zshrc} ${homeDir}/.zshrc
    install -m 0644 -o ${username} -g users ${zprofile} ${homeDir}/.zprofile
    install -m 0644 -o ${username} -g users ${aliasSh} ${homeDir}/.config/shell/alias.sh
    install -m 0644 -o ${username} -g users ${devEnv} ${homeDir}/.config/shell/dev_env.sh
    install -m 0644 -o ${username} -g users ${toolIntegrations} ${homeDir}/.config/shell/tool_integrations.sh

    chown -R ${username}:users ${homeDir}/.local
  '';
}
