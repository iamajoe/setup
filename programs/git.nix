{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir userFullname userEmail;

  gitConfigText = ''
    [user]
      name = ${userFullname}
      email = ${userEmail}

    [init]
      defaultBranch = main

    [core]
      editor = hx
      pager = delta

    [color]
      ui = auto

    [pull]
      rebase = false

    [pager]
      branch = false

    [interactive]
      diffFilter = delta --color-only

    [delta]
      navigate = true
      light = false
      side-by-side = false

    [merge]
      conflictstyle = zdiff3

    [diff]
      colorMoved = default
  '';
in
{
  environment.systemPackages = [
    pkgs.git
    pkgs.delta
  ];

  system.activationScripts.gitConfig.text = ''
    mkdir -p ${homeDir}
    rm -f ${homeDir}/.gitconfig
    cat > ${homeDir}/.gitconfig <<'EOF'
${gitConfigText}
EOF
    chown -h ${username}:users ${homeDir}/.gitconfig
  '';
}
