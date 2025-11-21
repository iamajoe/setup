{ config, pkgs, inputs, usersecrets, buildEnv, lib, ... }:

assert buildEnv.username != "" && buildEnv.username != null;
assert buildEnv.userFullname != "" && buildEnv.userFullname != null;
assert buildEnv.userEmail != "" && buildEnv.userEmail != null;
assert buildEnv.nixosConfig != "" && buildEnv.nixosConfig != null;

{
  home.username = buildEnv.username;
  home.homeDirectory = "/home/${buildEnv.username}";
  home.stateVersion = "25.05";

  #
  # ─── SSH ────────────────────────────────────────────────────────────────
  #
  programs.ssh = {
    enable = true;

    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "/home/${buildEnv.username}/.ssh/id_rsa";
      identitiesOnly = true;
    };
  };
  home.file.".ssh/id_rsa".source = "${usersecrets}/id_rsa";
  home.file.".ssh/id_rsa.pub".source = "${usersecrets}/id_rsa.pub";
  services.ssh-agent.enable = true;

  #
  # ─── Shell ────────────────────────────────────────────────────────────────
  #
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
  home.activation.getFishConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/config_fish.fish \
      -o "$HOME/.config/fish/config_dev.fish"
  '';

  #
  # ─── Terminal software ────────────────────────────────────────────────────────────
  #
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file /home/${buildEnv.username}/.config/tmux/main.conf
    '';
  };
  home.activation.getTmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/tmux/catppucin.theme \
      -o "$HOME/.config/tmux/catppuccin.theme"
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/tmux/main.conf \
      -o "$HOME/.config/tmux/main.conf"
  '';

  programs.git = {
    enable = true;

    userName  = buildEnv.userFullname;
    userEmail = buildEnv.userEmail;

    # config = {
    #   name  = buildEnv.userFullname;
    #   email = buildEnv.userEmail;
    #   init.defaultBranch = "main";
    #   core.editor        = "nvim";
    #   color.ui           = "auto";
    #   pull.rebase        = false;
    #   pager.branch       = false;
    # };

    # TODO: is this working?!
    extraConfig = {
      init.defaultBranch = "main";
      core.editor        = "nvim";
      color.ui           = "auto";
      pull.rebase        = false;
      pager.branch       = false;
    };
  };

  # Neovim
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
  # ─── GUI ────────────────────────────────────────────────────────────────
  #

  programs.firefox.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/home/${buildEnv.username}/.config/alacritty/alacritty_dev.yml" ];
    };
  };
  home.activation.getAlacrittyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.curl}/bin/curl -fsSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/alacritty.toml \
      -o "$HOME/.config/alacritty/alacritty_dev.toml"
  '';

  #
  # ─── Dependencies ────────────────────────────────────────────────────────────────
  #

  # $ nix search wget
  home.packages = with pkgs; [
    neovim
    ripgrep # Improved Grep
    nixpkgs-fmt
    bat
    tmux
    htop # Simple Terminal Based System Monitor
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others

    gcc
    rust-bin.stable.latest.default
    go
    nodejs
    zig
    zola
    jdk # Java Development Kit
    docker
    lazygit

    brightnessctl # For Screen Brightness Control

    ####################
    # GUI RELATED

    niri
    xwayland-satellite
    wl-clipboard          # wayland easy clipboard copy and paste
    udiskie               # auto disk mounter
    thunar

    # TODO: need to config
    #       use as ref: https://github.com/tonybanters/rofi
    rofi # rofi-wayland? or fuzzel?

    # TODO: need to config
    #       use as ref: https://github.com/tonybanters/waybar 
    waybar

    obsidian
    gimp # Great Photo Editor
    hyprpicker # Color Picker
    libnotify # For Notifications
    pavucontrol # For Editing Audio Levels & Devices
    zoom-us # Video Meetings
    google-chrome # Browser

    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files

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
}
