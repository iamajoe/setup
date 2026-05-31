{ config, pkgs, inputs, usersecrets, buildEnv, lib, ... }:

assert buildEnv.username != "" && buildEnv.username != null;
assert buildEnv.userFullname != "" && buildEnv.userFullname != null;
assert buildEnv.userEmail != "" && buildEnv.userEmail != null;
assert buildEnv.nixosConfig != "" && buildEnv.nixosConfig != null;

let
  # isX86_64 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in
{
  imports = [
    ./programs/alacritty.nix
    ./programs/rofi.nix
    ./programs/dunst.nix
    ./programs/picom.nix
    ./programs/firefox.nix
    ./programs/sunshine.nix
    # ./programs/rustdesk.nix
  ];

  home.username = buildEnv.username;
  home.homeDirectory = "/home/${buildEnv.username}";
  home.sessionPath = [ "/home/${buildEnv.username}/.local/bin"];
  home.stateVersion = "25.05";

  # ─── HiDPI Support ────────────────────────────────────────────────────────────────
  # X11 DPI settings for HiDPI displays
  xresources.properties = {
    "Xft.dpi" = 144;  # 1.5x scaling for HiDPI displays
  #   # "Xft.dpi" = 192;  # 2x scaling for HiDPI displays (commented out - was too large)
    "Xcursor.size" = 32;  # Larger cursor for better visibility
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

    # Clipmenu configuration
    CM_LAUNCHER = "rofi";  # Use rofi as the menu launcher for clipmenu
    CM_HISTLENGTH = "10";  # Keep last 10 clipboard items
  };

  # Qt configuration tool
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  # Cursor theme and size
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 32;  # Larger cursor for better visibility
    x11.enable = true;
    gtk.enable = true;
  };

  # GTK scaling and theming (for GTK apps)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # OLD ICON THEME (Adwaita)
    # iconTheme = {
    #   name = "Adwaita";
    #   package = pkgs.adwaita-icon-theme;
    # };
    # NEW ICON THEME (Papirus-Dark with Adwaita fallback)
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-fallback-icon-theme = "Adwaita";  # Fallback if icon not found in Papirus
      gtk-cursor-theme-size = 32;  # Larger cursor for better visibility
      # gtk-xft-dpi = 9834;  # 96 * 1024
      # gtk-xft-dpi = 147456;  # 144 * 1024
      # gtk-xft-dpi = 196608;  # 192 * 1024 (commented out - was too large)
    };
    gtk4.theme = null;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-fallback-icon-theme = "Adwaita";  # Fallback if icon not found in Papirus
      gtk-cursor-theme-size = 32;  # Larger cursor for better visibility
    };
  };

  # ─── SSH ────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      identityFile = "~/.ssh/id_rsa";
      extraOptions = {
        AddKeysToAgent = "yes";
      };
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

  # ─── Shell ────────────────────────────────────────────────────────────────
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
        "colorize"
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

  # ─── Terminal software ────────────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file /home/${buildEnv.username}/.config/tmux/main.conf
    '';
  };

  # Tmux configuration files
  home.file.".config/tmux/main.conf".source = ./templates/tmux/main.conf;
  home.file.".config/tmux/catppuccin.theme".source = ./templates/tmux/catppuccin.theme;

  programs.helix = {
    enable = true;
  };

  # Helix configuration files
  home.file.".config/helix/config.toml".source = ./templates/helix/config.toml;
  home.file.".config/helix/languages.toml".source = ./templates/helix/languages.toml;
  home.file.".config/helix/themes".source = ./templates/helix/themes;

  programs.git = {
    enable = true;

    settings = {
      user.name = buildEnv.userFullname;
      user.email = buildEnv.userEmail;
      init.defaultBranch = "main";
      core.editor = "hx";
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
    shellWrapperName = "y";
    settings = {
      opener = {
        open = [
          { run = "open %s1"; orphan = true; for = "macos"; desc = "Open (default app)"; }
          { run = "xdg-open %s1"; orphan = true; for = "linux"; desc = "Open (default app)"; }
        ];
        edit = [
          { run = "/Users/joel/.cargo/bin/hx %s"; block = true; for = "macos"; }
          { run = "nvim %s"; block = true; for = "linux"; }
        ];
      };
      open = {
        prepend_rules = [
          { mime = "image/*"; use = "open"; }
          { mime = "application/pdf"; use = "open"; }
          { mime = "video/*"; use = "open"; }
          { mime = "audio/*"; use = "open"; }
          { mime = "application/zip"; use = "open"; }
        ];
        rules = [
          { mime = "application/json"; use = "edit"; }
          { mime = "text/*"; use = "edit"; }
          { url = "*.md"; use = "edit"; }
          { url = "*.yml"; use = "edit"; }
          { url = "*.txt"; use = "edit"; }
          { url = "*.json"; use = "edit"; }
        ];
      };
      mgr = {
        show_hidden = true;
        sort_by = "mtime";
      };
    };
  };

  # ─── DE ────────────────────────────────────────────────────────────────
  home.file.".xinitrc".source = ./templates/x/xinitrc;

  # Qtile configuration
  home.file.".config/qtile/config.py".source = ./templates/qtile/config.py;
  home.file.".config/qtile/autostart.sh" = {
    source = ./templates/qtile/autostart.sh;
    executable = true;
  };
  home.file.".config/qtile/shortcuts.txt".source = ./templates/qtile/shortcuts.txt;
  home.file.".config/qtile/keyboard-layout.txt".source = ./templates/qtile/keyboard-layout.txt;
  home.file.".config/qtile/bar_minimal.py".source = ./templates/qtile/bar_minimal.py;

  # Scripts
  home.file.".local/bin/toggle-resolution" = {
    source = ./templates/scripts/toggle-resolution.sh;
    executable = true;
  };

  # ─── Local services ────────────────────────────────────────────────────────────────
  home.file."services/docker-compose.yml".source = ./templates/services/docker-compose.yml;
  systemd.user.services.services-compose = {
    Unit = {
      Description = "Docker compose stack in ~/services";
      After = [ "default.target" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "%h/services";
      ExecStart = "${pkgs.docker}/bin/docker compose up -d";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
      TimeoutStartSec = "0";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # ─── AI ────────────────────────────────────────────────────────────────
  # home.file.".config/opencode/opencode.json".source = ./templates/opencode/opencode.json;
  # home.activation.installOllama = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   set -eu

  #   mkdir -p "$HOME/.local/share/ollama"
  #   mkdir -p "$HOME/.local/bin"

  #   if [ ! -x "$HOME/.local/share/ollama/bin/ollama" ]; then
  #     ${pkgs.curl}/bin/curl -fsSL https://ollama.com/download/ollama-linux-amd64.tar.zst \
  #       | ${pkgs.gnutar}/bin/tar --use-compress-program=${pkgs.zstd}/bin/zstd -x -C "$HOME/.local/share/ollama"
  #   fi

  #   rm -f "$HOME/.local/bin/ollama"
  #   ln -sf "$HOME/.local/share/ollama/bin/ollama" "$HOME/.local/bin/ollama"
  # '';
  # systemd.user.services.ollama = {
  #   Unit = {
  #     Description = "Ollama (user)";
  #     After = [ "default.target" ];
  #   };

  #   Service = {
  #     ExecStart = "${config.home.homeDirectory}/.local/bin/ollama serve";
  #     Restart = "on-failure";
  #     RestartSec = 3;
  #     Environment = [
  #       "OLLAMA_HOST=0.0.0.0:11434"
  #       "OLLAMA_MODELS=${config.home.homeDirectory}/.local/share/ollama/models"
  #       "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
  #     ];
  #     WorkingDirectory = "${config.home.homeDirectory}/.local/share/ollama";
  #   };

  #   Install.WantedBy = [ "default.target" ];
  # };

  home.file.".config/zed/settings.json".source = ./templates/zed/settings.json;

  # ─── Dependencies ────────────────────────────────────────────────────────────────
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
    eslint
    prettier
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
    zstd

    appimage-run # runs AppImage

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
    gsimplecal      # lightweight calendar popup

    xclip           # clipboard utilities
    xsel            # alternative clipboard utility (required by clipmenu)
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
    spotify # music streaming desktop app
    vlc # VLC media player
    stripe-cli
    rpi-imager # raspberry pi sd card installer
    freecad # 3d cad program
    kicad # electronics cad program
    orca-slicer # 3d printer slicer
    transmission_4-gtk # bittorrent client

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

    # Icon themes
    papirus-icon-theme  # Primary icon theme (Papirus-Dark variant)
    adwaita-icon-theme  # Fallback icon theme

    # AI
    # opencode
    zed-editor

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
