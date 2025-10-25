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
        sudo nixos-rebuild switch --flake "/home/${buildEnv.username}/nixos-config/#${buildEnv.nixosConfig}"
      '';

      hmrebuild = ''
        home-manager switch --flake "/home/${buildEnv.username}/nixos-config/#${buildEnv.nixosConfig}"
      '';
    };
  };

  programs.firefox.enable = true;
  programs.git.enable = true;

  # $ nix search wget
  home.packages = with pkgs; [
    neovim
    ripgrep
    nixpkgs-fmt
    alacritty
    bat
    tmux
    fish

    gcc
    rust-bin.stable.latest.default
    go
    nodejs
    docker

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
  home.activation.cleanupExistingFiles = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    echo "Cleaning pre-existing files before linking..."
    rm -f "$HOME/.gitconfig"
    rm -f "$HOME/.config/fish/config.fish"
    rm -f "$HOME/.config/alacritty/alacritty.toml"
    rm -f "$HOME/.tmux.conf"
  '';

  #
  # ─── Neovim Config ────────────────────────────────────────────────────────────────
  #
  # home.file.".config/nvim".source = inputs.nvim-config.outPath;
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
  # home.file.".config/alacritty/alacritty.toml".source = ./config/alacritty.toml;
  home.activation.getAlacrittyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/alacritty"
  
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/alacritty.toml \
      -o "$HOME/.config/alacritty/alacritty.toml"
  '';

  #
  # ─── Fish Config ─────────────────────────────────────────────────────────────────
  #
  # home.file.".config/fish/config.fish".source = ./config/config.fish;
  home.activation.getFishConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/fish"

    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/config_fish.fish \
      -o "$HOME/.config/fish/config.fish"
  '';

  #
  # ─── Tmux Config ─────────────────────────────────────────────────────────────────
  #
  # home.file.".config/tmux".source = ./config/tmux.conf
  home.file.".tmux.conf".text = ''
    run-shell "tmux source-file ~/.config/tmux/main.conf"
  '';
  home.activation.getTmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/tmux"
  
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/tmux/catppucin.theme \
      -o "$HOME/.config/tmux/catppuccin.theme"
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/tmux/main.conf \
      -o "$HOME/.config/tmux/main.conf"
  '';

  #
  # ─── Git Config ──────────────────────────────────────────────────────────────────
  #
  home.activation.getGitConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/gitconfig.yml \
    | ${pkgs.gnused}/bin/sed \
        -e "s|{{git_user_fullname}}|${buildEnv.userFullname}|g" \
        -e "s|{{git_user_email}}|${buildEnv.userEmail}|g" \
        -e "s|/home/{{ansible_user}}|$HOME|g" \
        > "$HOME/.gitconfig"
  '';
}
