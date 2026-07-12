{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  tmuxTemplate = ../templates/tmux;
in
{
  environment.systemPackages = [
    pkgs.tmux
  ];

  system.activationScripts.tmuxConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config

    rm -f ${homeDir}/.tmux.conf
    rm -rf ${homeDir}/.config/tmux

    printf '%s\n' 'run-shell "tmux source-file ~/.config/tmux/main.conf"' > ${homeDir}/.tmux.conf

    cp -r ${tmuxTemplate} ${homeDir}/.config/tmux

    chown ${username}:users ${homeDir}/.tmux.conf
    chmod 0644 ${homeDir}/.tmux.conf

    chown -R ${username}:users ${homeDir}/.config/tmux
    find ${homeDir}/.config/tmux -type d -exec chmod 0755 {} \;
    find ${homeDir}/.config/tmux -type f -exec chmod 0644 {} \;
  '';
}
