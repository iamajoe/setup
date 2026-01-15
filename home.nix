{ config, pkgs, inputs, usersecrets, buildEnv, lib, ... }:

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
  imports = [
    ./programs/alacritty.nix
    ./programs/rofi.nix
    ./programs/dunst.nix
    ./programs/picom.nix
    ./programs/firefox.nix
    ./programs/rustdesk.nix
  ];

  home.username = buildEnv.username;
  home.homeDirectory = "/home/${buildEnv.username}";
  home.stateVersion = "25.05";

  #
  # ─── HiDPI Support ────────────────────────────────────────────────────────────────
  #

  # X11 DPI settings for HiDPI displays
  xresources.properties = {
    "Xft.dpi" = 144;  # 1.5x scaling for HiDPI displays
  #   # "Xft.dpi" = 192;  # 2x scaling for HiDPI displays (commented out - was too large)
  #   "Xcursor.size" = 48;  # Larger cursor for HiDPI (doubled from 24)
  #   "Xft.autohint" = 0;
  #   "Xft.lcdfilter" = "lcddefault";
  #   "Xft.hintstyle" = "hintfull";
  #   "Xft.hinting" = 1;
  #   "Xft.antialias" = 1;
  #   "Xft.rgba" = "rgb";
  };

  # Qt scaling and dark mode (for Qt apps)
  home.sessionVariables = {
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # QT_SCALE_FACTOR = "1";  # Normal scaling for Qt apps (Flameshot dialogs)
    # QT_SCALE_FACTOR = "2";  # 2x scaling for HiDPI displays (commented out - was too large for some apps)
    # Force dark mode for various toolkits
    GTK_THEME = "Adwaita:dark";
  };

  # Qt configuration tool
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
  
  # GTK scaling and theming (for GTK apps)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      # gtk-cursor-theme-size = 48;  # Doubled for HiDPI
      # gtk-xft-dpi = 9834;  # 96 * 1024
      # gtk-xft-dpi = 147456;  # 144 * 1024
      # gtk-xft-dpi = 196608;  # 192 * 1024 (commented out - was too large)
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      # gtk-cursor-theme-size = 48;  # Doubled for HiDPI
    };
  };

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
      vim = "nvim";

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
      ];
      theme = "robbyrussell";  # or "agnoster", "powerlevel10k/powerlevel10k", etc.
    };

    # Fix keyboard bindings for Home, End, Alt+Left/Right
    initContent = ''
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
      vim = "nvim";

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
  
  # Tmux configuration files
  home.file.".config/tmux/main.conf".source = ./tmux/main.conf;
  home.file.".config/tmux/catppuccin.theme".source = ./tmux/catppuccin.theme;

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

  programs.htop = {
    enable = true;
    settings = {
      show_cpu_frequency = true;
      show_cpu_usage = true;
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
    };
  };
  
  # Better git diffs with delta
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Neovim
  home.activation.ensureNvimConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    set -eu

    export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new -o BatchMode=yes"
    GIT_BIN=${pkgs.git}/bin/git
    NVIM_DIR="$HOME/.config/nvim"

    if [ -d "$NVIM_DIR/.git" ]; then
      echo "Updating Neovim config..."
      cd "$NVIM_DIR"
      if "$GIT_BIN" fetch origin barebones 2>/dev/null; then
        "$GIT_BIN" reset --hard origin/barebones
      else
        echo "Warning: Failed to update Neovim config, keeping existing version"
      fi
    else
      echo "Cloning Neovim config..."
      "$GIT_BIN" clone --branch barebones --depth 1 https://github.com/iamajoe/nvim.git "$NVIM_DIR" || echo "Warning: Failed to clone Neovim config"
    fi
  '';

  programs.fzf.enable = true; # Fuzzy finder (Ctrl+R for history)
  programs.bat.enable = true; # Better cat with syntax highlighting
  programs.eza = {
    enable = true;
    icons = "never";
    git = true;
  };
  programs.zoxide.enable = true; # Smart cd - use 'z <partial-name>' to jump

  programs.yazi = {
    enable = true;
    enableZshIntegration = true; # or Bash/Fish/Nushell
    settings = {
      mgr = {
        show_hidden = false;
        sort_by = "mtime";
      };
    };
  };

  #
  # ─── GUI ────────────────────────────────────────────────────────────────
  #

  # Qtile configuration
  home.file.".config/qtile/config.py".source = ./qtile/config.py;
  home.file.".config/qtile/autostart.sh" = {
    source = ./qtile/autostart.sh;
    executable = true;
  };
  home.file.".config/qtile/shortcuts.txt".source = ./qtile/shortcuts.txt;
  home.file.".config/qtile/keyboard-layout.txt".source = ./qtile/keyboard-layout.txt;
  # Modular bar configurations
  home.file.".config/qtile/bar_default.py".source = ./qtile/bar_default.py;
  home.file.".config/qtile/bar_rounded.py".source = ./qtile/bar_rounded.py;

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
    pkg-config # wrapper script for allowing packages to get info on others

    gcc
    rustc
    cargo
    rust-analyzer
    go
    gopls
    python3
    lua-language-server
    nodejs
    typescript-language-server
    vscode-langservers-extracted  # includes eslint, html, css, json language servers
    zig
    zola
    jdk # java development kit
    docker
    lazygit

    # JSON/YAML/data tools
    jq      # JSON processor
    yq-go   # YAML processor

    brightnessctl # screen brightness control

    # Archive tools (for Thunar archive plugin)
    unrar # tool for handling .rar files
    unzip # tool for handling .zip files
    p7zip # 7z archive support
    zip   # create zip files

    ####################
    # GUI RELATED

    # GTK/Qt theming for dark mode
    gnome-themes-extra  # Adwaita dark theme
    adwaita-icon-theme  # Adwaita icons
    adwaita-qt          # Qt5 Adwaita theme
    adwaita-qt6         # Qt6 Adwaita theme
    qt6Packages.qt6ct   # Qt6 configuration tool

    # System GUI tools
    blueman         # bluetooth manager GUI
    gparted         # GUI partition editor

    xclip           # clipboard utilities
    xdotool         # X11 automation for better VM integration
    flameshot       # screenshot tool
    clipmenu        # Clipboard manager with rofi integration
    clipnotify      # Clipboard change notifications

    thunar                  # file manager
    thunar-volman           # Automatic management of removable devices
    thunar-archive-plugin   # Archive support (works with unzip, unrar, etc.)

    # Miscellaneous
    obsidian
    gimp # photo editor
    hyprpicker # color picker
    libnotify # notifications
    pavucontrol # editing audio levels & devices
    pamixer # CLI audio mixer for PipeWire/PulseAudio
    playerctl # CLI media player controller (MPRIS)
    sublime-merge # git helper interface
    tidal-hifi # Tidal music streaming desktop app
    vlc # VLC media player
    stripe-cli
    
    # Additional editors (not default, but available when needed)
    sublime4 # Sublime Text editor
    code-cursor # Cursor

    # Fonts
    # TODO: need to select one. generally, i use noto
    nerd-fonts.noto
    nerd-fonts.tinos
    nerd-fonts.code-new-roman
    nerd-fonts.inconsolata
    nerd-fonts.commit-mono
    nerd-fonts.zed-mono
    nerd-fonts.jetbrains-mono
    font-awesome  # Font Awesome 6 Free (includes Solid, Regular, Brands)
  ]) 
  # x86_64-only packages (GPU tools and packages not available on aarch64)
  ++ (with pkgs; lib.optionals isX86_64 [
    # GPU & Graphics tools (x86_64-specific)
    vulkan-tools    # vulkaninfo, vkcube (GPU testing)
    mesa-demos      # OpenGL info (includes glxinfo, glxgears, etc.)

    # Applications with limited aarch64 support
    zoom-us # video meetings (needs allowUnsupportedSystem on aarch64)
    # TODO: try this out on aarch64, we want it
    google-chrome # browser (may not be available on aarch64)

    # Communication apps (x86_64 only - no aarch64-linux support)
    discord
    slack
    # chatgpt desktop app not in nixpkgs - use web or unofficial packages

    # Database tools (x86_64 only - no aarch64-linux support)
    # TODO: try this out on aarch64, we want it
    mongodb-compass # MongoDB GUI
  ]);

  fonts.fontconfig.enable = true;
}
