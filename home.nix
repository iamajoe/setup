{ config, pkgs, inputs, usersecrets, buildEnv, lib, ... }:

assert buildEnv.username != "" && buildEnv.username != null;
assert buildEnv.userFullname != "" && buildEnv.userFullname != null;
assert buildEnv.userEmail != "" && buildEnv.userEmail != null;
assert buildEnv.nixosConfig != "" && buildEnv.nixosConfig != null;

let
  # Detect architecture
  isX86_64 = pkgs.system == "x86_64-linux";
  isAarch64 = pkgs.system == "aarch64-linux";
  isParallels = builtins.pathExists /dev/prl_fs;
in
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
    enable = false;
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
    mkdir -p "$HOME/.config/fish"
    ${pkgs.curl}/bin/curl -sSL \
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
    mkdir -p "$HOME/.config/tmux"
    ${pkgs.curl}/bin/curl -sSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/tmux/catppucin.theme \
      -o "$HOME/.config/tmux/catppuccin.theme"
    ${pkgs.curl}/bin/curl -sSL \
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

  home.activation.getQtileConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/qtile"
    ${pkgs.curl}/bin/curl -sSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/qtile.py \
      -o "$HOME/.config/qtile/config.py"
  '';

  programs.firefox.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/home/${buildEnv.username}/.config/alacritty/alacritty_dev.yml" ];
    };
  };
  home.activation.getAlacrittyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/alacritty"
    ${pkgs.curl}/bin/curl -sSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/alacritty.toml \
      -o "$HOME/.config/alacritty/alacritty_dev.toml"
    
    # Check if file uses deprecated 'import' syntax and update to 'general.import'
    CONFIG_FILE="$HOME/.config/alacritty/alacritty.toml"
    if [ -f "$CONFIG_FILE" ]; then
      if ! ${pkgs.gnugrep}/bin/grep -q "general\.import" "$CONFIG_FILE" && \
         ${pkgs.gnugrep}/bin/grep -q "^import" "$CONFIG_FILE"; then
        echo "Updating deprecated 'import' to 'general.import' in Alacritty config..."
        ${pkgs.gnused}/bin/sed -i 's/^import = /general.import = /g' "$CONFIG_FILE"
      fi
    fi
  '';

  home.activation.getRofiConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/rofi"
    rm -f $HOME/.config/rofi/*
    ${pkgs.curl}/bin/curl -sSL \
      https://raw.githubusercontent.com/iamajoe/setup/refs/heads/master/templates/rofi \
      -o "$HOME/.config/rofi/config.rasi"
  '';

  #
  # ─── Syncthing ────────────────────────────────────────────────────────────────
  #

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings.gui = {
      # user = buildEnv.username;
      # password = "mypassword";
    };
    extraFlags = ["--no-default-folder"];
  };

  #
  # ─── Dependencies ────────────────────────────────────────────────────────────────
  #

  # $ nix search wget
  home.packages = with pkgs; [
    home-manager # cli tool for home manager
    nixpkgs-fmt

    neovim
    ripgrep # improved Grep
    bat
    tmux
    htop # terminal based system monitor
    pkg-config # wrapper script for allowing packages to get info on others

    gcc
    rust-bin.stable.latest.default
    go
    python3
    nodejs
    zig
    zola
    jdk # java development kit
    docker
    lazygit

    brightnessctl # screen brightness control

    unrar # tool for handling .rar files
    unzip # tool for handling .zip files

    ####################
    # GUI RELATED

    # System GUI tools
    blueman         # bluetooth manager GUI
    gparted         # GUI partition editor

    rofi # application launcher
    xclip           # clipboard utilities
    xdotool         # X11 automation for better VM integration

    # TODO: need to config
    #       use as ref: https://github.com/tonybanters/waybar 
    # waybar

    # Miscellaneous
    obsidian
    gimp # photo editor
    hyprpicker # color picker
    libnotify # notifications
    pavucontrol # editing audio levels & devices

    # Fonts
    # TODO: need to select one. generally, i use noto
    nerd-fonts.noto
    nerd-fonts.tinos
    nerd-fonts.code-new-roman
    nerd-fonts.inconsolata
    nerd-fonts.commit-mono
    nerd-fonts.zed-mono
    nerd-fonts.jetbrains-mono
  ] 
  # x86_64-only packages (GPU tools and packages not available on aarch64)
  ++ lib.optionals isX86_64 [
    # GPU & Graphics tools (x86_64-specific)
    nvtopPackages.full # GPU monitoring for NVIDIA/AMD/Intel
    vulkan-tools    # vulkaninfo, vkcube (GPU testing)
    glxinfo         # OpenGL info

    # Applications with limited aarch64 support
    zoom-us # video meetings (needs allowUnsupportedSystem on aarch64)
    google-chrome # browser (may not be available on aarch64)
  ];

  fonts.fontconfig.enable = true;
}
