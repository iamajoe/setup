{ config, pkgs, neovim-pkg, inputs, usersecrets, buildEnv, lib, ... }:

assert buildEnv.username != "" && buildEnv.username != null;
assert buildEnv.userFullname != "" && buildEnv.userFullname != null;
assert buildEnv.userEmail != "" && buildEnv.userEmail != null;
assert buildEnv.nixosConfig != "" && buildEnv.nixosConfig != null;

let
  # Detect architecture
  isX86_64 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
  isAarch64 = pkgs.stdenv.hostPlatform.system == "aarch64-linux";
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
    enableDefaultConfig = false;

    matchBlocks."*" = {
      identityFile = "~/.ssh/id_rsa";
    };

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
      nixupdate = "cd ~/nixos_config && nix flake update && cd -";
      
      # Better defaults (eza is enabled via programs.eza)
      ls = "eza";
      ll = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      find = "fd";
      
      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Enable oh-my-zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "sudo" 
        "docker" 
        "kubectl" 
        "terraform"
        "colorize"
        "aws"
        "tmux"
        "fast-syntax-highlighting"
      ];
      theme = "robbyrussell";  # or "agnoster", "powerlevel10k/powerlevel10k", etc.
    };
    
    # Fix keyboard bindings for Home, End, Alt+Left/Right
    initExtra = ''
      # Fix Home/End keys
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[OH" beginning-of-line
      bindkey "^[OF" end-of-line
      
      # Fix Delete key
      bindkey "^[[3~" delete-char
      
      # Alt+Left/Right for word jumping
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word
      
      # Alternative bindings that might work better in some terminals
      bindkey "^[^[[C" forward-word
      bindkey "^[^[[D" backward-word
      
      # Ctrl+Left/Right for word jumping (alternative)
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
    '';
    
    shellAliases = {
      nixrebuild = ''
        sudo nixos-rebuild switch --flake "/home/${buildEnv.username}/nixos_config/#${buildEnv.nixosConfig}"
      '';
      hmrebuild = ''
        home-manager switch --flake "/home/${buildEnv.username}/nixos_config/#${buildEnv.nixosConfig}"
      '';
      nixclean = "nix-collect-garbage -d --delete-older-than 5d";
      nixupdate = "cd ~/nixos_config && nix flake update && cd -";
      
      # Better defaults (eza is enabled via programs.eza)
      ls = "eza";
      ll = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      find = "fd";
      
      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
    };
    
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

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

    settings = {
      user.name = buildEnv.userFullname;
      user.email = buildEnv.userEmail;
      init.defaultBranch = "main";
      core.editor = "nvim";
      color.ui = "auto";
      pull.rebase = false;
      pager.branch = false;
    };
  };
  
  # Better git diffs with delta
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
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

  programs.fzf.enable = true; # Fuzzy finder (Ctrl+R for history)
  programs.bat.enable = true; # Better cat with syntax highlighting
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };
  programs.zoxide.enable = true; # Smart cd - use 'z <partial-name>' to jump

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
    rm -f $HOME/.config/alacritty/*.backup
    rm -f $HOME/.config/alacritty/*_dev.toml
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
  # ─── Dependencies ────────────────────────────────────────────────────────────────
  #

  # $ nix search wget
  home.packages = (with pkgs; [
    home-manager # cli tool for home manager
    nixpkgs-fmt

    ripgrep # improved Grep
    fd      # Better find
    sd      # Better sed
    tmux
    htop # terminal based system monitor
    btop    # Beautiful system monitor
    pkg-config # wrapper script for allowing packages to get info on others

    gcc
    rustc
    cargo
    go
    python3
    nodejs
    zig
    zola
    jdk # java development kit
    docker
    lazygit
    
    # JSON/YAML/data tools
    jq      # JSON processor
    yq-go   # YAML processor

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

    # Miscellaneous
    obsidian
    gimp # photo editor
    hyprpicker # color picker
    libnotify # notifications
    pavucontrol # editing audio levels & devices
    sublime-merge # git helper interface
    
    # Additional editors (not default, but available when needed)
    sublime4 # Sublime Text editor
    # cursor # Not in nixpkgs yet - install via their official method

    # Fonts
    # TODO: need to select one. generally, i use noto
    nerd-fonts.noto
    nerd-fonts.tinos
    nerd-fonts.code-new-roman
    nerd-fonts.inconsolata
    nerd-fonts.commit-mono
    nerd-fonts.zed-mono
    nerd-fonts.jetbrains-mono
  ]) 
  # Neovim nightly (0.12.0+)
  ++ [ neovim-pkg ]
  # x86_64-only packages (GPU tools and packages not available on aarch64)
  ++ (with pkgs; lib.optionals isX86_64 [
    # GPU & Graphics tools (x86_64-specific)
    nvtopPackages.full # GPU monitoring for NVIDIA/AMD/Intel
    vulkan-tools    # vulkaninfo, vkcube (GPU testing)
    glxinfo         # OpenGL info

    # Applications with limited aarch64 support
    zoom-us # video meetings (needs allowUnsupportedSystem on aarch64)
    google-chrome # browser (may not be available on aarch64)
    
    # Communication apps (x86_64 only - no aarch64-linux support)
    discord
    slack
    # chatgpt desktop app not in nixpkgs - use web or unofficial packages
    
    # Database tools (x86_64 only - no aarch64-linux support)
    mongodb-compass # MongoDB GUI
  ]);

  fonts.fontconfig.enable = true;
}
