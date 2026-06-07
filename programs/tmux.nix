{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;
in
{
  environment.systemPackages = [
    pkgs.tmux
  ];

  system.activationScripts.tmuxConfig.text = ''
    mkdir -p ${homeDir}/.config/tmux

    rm -f ${homeDir}/.tmux.conf
    rm -f ${homeDir}/.config/tmux/main.conf
    rm -f ${homeDir}/.config/tmux/catppuccin.theme

    # Minimal tmux entrypoint.
    # tmux reads ~/.tmux.conf by default, then this loads your real config.
    printf '%s\n' 'run-shell "tmux source-file ~/.config/tmux/main.conf"' > ${homeDir}/.tmux.conf

    ln -sfn ${../templates/tmux/main.conf} ${homeDir}/.config/tmux/main.conf
    ln -sfn ${../templates/tmux/catppuccin.theme} ${homeDir}/.config/tmux/catppuccin.theme

    chown -h ${username}:staff ${homeDir}/.tmux.conf
    chown -h ${username}:staff ${homeDir}/.config/tmux/main.conf
    chown -h ${username}:staff ${homeDir}/.config/tmux/catppuccin.theme
    chown ${username}:staff ${homeDir}/.config/tmux
  '';
}
