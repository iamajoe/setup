{ config, pkgs, inputs, buildEnv, lib, ... }:

assert buildEnv.username != "" && buildEnv.username != null;
assert buildEnv.userFullname != "" && buildEnv.userFullname != null;
assert buildEnv.userEmail != "" && buildEnv.userEmail != null;
assert buildEnv.nixosConfig != "" && buildEnv.nixosConfig != null;

{
  home.username = buildEnv.username;
  home.homeDirectory = "/home/${buildEnv.username}";
  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    shellAliases = {
      nixrebuild = ''
        sudo nixos-rebuild switch --flake "/home/${buildEnv.username}/nixos_config/#${buildEnv.nixosConfig}"
      '';
      hmrebuild = ''
        home-manager switch --flake "/home/${buildEnv.username}/nixos_config/#${buildEnv.nixosConfig}"
      '';
      nixclean = "nix-collect-garbage -d --delete-older-than 5d";

      ll = "ls -la";
    };
  };

  programs.firefox.enable = true;
  programs.git = {
    enable = true;

    userName  = buildEnv.userFullname;
    userEmail = buildEnv.userEmail;

    extraConfig = {
      init.defaultBranch = "main";
      core.editor        = "nvim";
      color.ui           = "auto";
      pull.rebase        = false;
      pager.branch       = false;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      source "/home/${buildEnv.username}/.config/fish/config_dev.fish"
    '';

    shellAliases = {
      nixrebuild = ''
        sudo nixos-rebuild switch --flake "/home/${buildEnv.username}/nixos_config/#${buildEnv.nixosConfig}"
      '';
      hmrebuild = ''
        home-manager switch --flake "/home/${buildEnv.username}/nixos_config/#${buildEnv.nixosConfig}"
      '';
      nixclean = "nix-collect-garbage -d --delete-older-than 5d";

      ll = "ls -la";
    };
  };
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file /home/${buildEnv.username}/.config/tmux/main.conf
    '';
  };
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/home/${buildEnv.username}/.config/alacritty/alacritty_dev.yml" ];
    };
  };

  # $ nix search wget
  home.packages = with pkgs; [
    neovim
    ripgrep
    nixpkgs-fmt
    bat
    tmux

    gcc
    rust-bin.stable.latest.default
    go
    nodejs
    docker
    lazygit

    # TODO: need to select one. generally, i use noto
    nerd-fonts.noto
    nerd-fonts.tinos
    nerd-fonts.code-new-roman
    nerd-fonts.inconsolata
    nerd-fonts.commit-mono
    nerd-fonts.zed-mono
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  # NOTE: we don't want these files versioned and no need for them to be backed up
  # home.activation.cleanupExistingFiles = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
  #   echo "Cleaning pre-existing files before linking..."
  #   rm -f "$HOME/.gitconfig"
  # '';

  #
  # ─── Neovim Config ────────────────────────────────────────────────────────────────
  #
  home.activation.ensureNvimConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    set -eux

    GIT_BIN=${pkgs.git}/bin/git
    NVIM_DIR="$HOME/.config/nvim"

    if [ -d "$NVIM_DIR/.git" ]; then
      echo "Updating Neovim config..."
      cd "$NVIM_DIR"
      "$GIT_BIN" fetch origin barebones
      "$GIT_BIN" reset --hard origin/barebones
    else
      echo "Cloning Neovim config..."
      "$GIT_BIN" clone --branch barebones --depth 1 https://github.com/iamajoe/nvim.git "$NVIM_DIR"
    fi
  '';

  #
  # ─── Alacritty Config ─────────────────────────────────────────────────────────────
  #
  home.activation.getAlacrittyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/alacritty.toml \
      -o "$HOME/.config/alacritty/alacritty_dev.toml"
  '';

  #
  # ─── Fish Config ─────────────────────────────────────────────────────────────────
  #
  home.activation.getFishConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/config_fish.fish \
      -o "$HOME/.config/fish/config_dev.fish"
  '';

  #
  # ─── Tmux Config ─────────────────────────────────────────────────────────────────
  #
  home.activation.getTmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/tmux/catppucin.theme \
      -o "$HOME/.config/tmux/catppuccin.theme"
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/tmux/main.conf \
      -o "$HOME/.config/tmux/main.conf"
  '';
}
