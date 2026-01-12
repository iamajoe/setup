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
  home.username = buildEnv.username;
  home.homeDirectory = "/home/${buildEnv.username}";
  home.stateVersion = "25.05";

  #
  # ─── HiDPI Support ────────────────────────────────────────────────────────────────
  #
  
  # X11 DPI settings for HiDPI displays
  xresources.properties = {
    "Xft.dpi" = 144;  # Common for 4K displays (change to 192 for higher DPI)
    "Xcursor.size" = 24;  # Larger cursor
    "Xft.autohint" = 0;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintfull";
    "Xft.hinting" = 1;
    "Xft.antialias" = 1;
    "Xft.rgba" = "rgb";
  };
  
  # Qt scaling (for Qt apps)
  home.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR = "1.5";  # Adjust to 1.5 or 2 based on your preference
  };
  
  # GTK scaling (for GTK apps)
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-cursor-theme-size = 24;
      gtk-xft-dpi = 147456;  # 144 * 1024
    };
    gtk4.extraConfig = {
      gtk-cursor-theme-size = 24;
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
  '';

  # Rofi - application launcher
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    extraConfig = {
      modi = "run,drun,window";
      icon-theme = "Oranchelo";
      show-icons = false;
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "";
      dpi = 220;
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
        bg-col = mkLiteral "#1e1e2e";
        bg-col-light = mkLiteral "#1e1e2e";
        border-col = mkLiteral "#1e1e2e";
        selected-col = mkLiteral "#1e1e2e";
        blue = mkLiteral "#89b4fa";
        fg-col = mkLiteral "#cdd6f4";
        fg-col2 = mkLiteral "#f38ba8";
        grey = mkLiteral "#6c7086";
        
        width = 1200;
        font = "NotoSansM Nerd Font 9";
      };
      
      "element-text, element-icon, mode-switcher" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      
      window = {
        height = mkLiteral "360px";
        border = mkLiteral "3px";
        border-color = mkLiteral "@border-col";
        background-color = mkLiteral "@bg-col";
      };
      
      mainbox = {
        background-color = mkLiteral "@bg-col";
      };
      
      inputbar = {
        children = map mkLiteral ["prompt" "entry"];
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "5px";
        padding = mkLiteral "2px";
      };
      
      prompt = {
        background-color = mkLiteral "@blue";
        padding = mkLiteral "6px";
        text-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "3px";
        margin = mkLiteral "20px 0px 0px 20px";
      };
      
      "textbox-prompt-colon" = {
        expand = false;
        str = ":";
      };
      
      entry = {
        padding = mkLiteral "6px";
        margin = mkLiteral "20px 0px 0px 10px";
        text-color = mkLiteral "@fg-col";
        background-color = mkLiteral "@bg-col";
      };
      
      listview = {
        border = mkLiteral "0px 0px 0px";
        padding = mkLiteral "6px 0px 0px";
        margin = mkLiteral "10px 0px 0px 20px";
        columns = 2;
        lines = 5;
        background-color = mkLiteral "@bg-col";
      };
      
      element = {
        padding = mkLiteral "5px";
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@fg-col";
      };
      
      element-icon = {
        size = mkLiteral "25px";
      };
      
      "element selected" = {
        background-color = mkLiteral "@selected-col";
        text-color = mkLiteral "@fg-col2";
      };
      
      mode-switcher = {
        spacing = 0;
      };
      
      button = {
        padding = mkLiteral "10px";
        background-color = mkLiteral "@bg-col-light";
        text-color = mkLiteral "@grey";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.5";
      };
      
      "button selected" = {
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@blue";
      };
      
      message = {
        background-color = mkLiteral "@bg-col-light";
        margin = mkLiteral "2px";
        padding = mkLiteral "2px";
        border-radius = mkLiteral "5px";
      };
      
      textbox = {
        padding = mkLiteral "6px";
        margin = mkLiteral "20px 0px 0px 20px";
        text-color = mkLiteral "@blue";
        background-color = mkLiteral "@bg-col-light";
      };
    };
  };

  # Dunst - notification daemon
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "10x50";
        scale = 0;
        notification_limit = 5;
        
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        
        indicate_hidden = "yes";
        transparency = 10;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 2;
        frame_color = "#89B4FA";
        gap_size = 5;
        separator_color = "frame";
        sort = "yes";
        
        font = "Noto Sans 12";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 128;
        
        sticky_history = "yes";
        history_length = 20;
        
        browser = "${pkgs.firefox}/bin/firefox";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 10;
        ignore_dbusclose = false;
        
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
      
      # Catppuccin Mocha theme colors
      urgency_low = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        frame_color = "#89B4FA";
        timeout = 5;
      };
      
      urgency_normal = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        frame_color = "#89B4FA";
        timeout = 10;
      };
      
      urgency_critical = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        frame_color = "#F38BA8";
        timeout = 0;
      };
    };
  };

  # Picom - compositor for X11
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    
    fade = true;
    fadeSteps = [ 0.03 0.03 ];
    fadeDelta = 10;
    
    shadow = true;
    shadowOpacity = 0.75;
    shadowOffsets = [ (-15) (-15) ];
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
    
    settings = {
      # Rounded corners
      corner-radius = 10;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      
      # Opacity rules
      inactive-opacity = 0.95;
      active-opacity = 1.0;
      frame-opacity = 0.9;
      
      # Blur
      blur-method = "dual_kawase";
      blur-strength = 5;
      blur-background = true;
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      
      # Performance
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      log-level = "warn";
    };
  };

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

    unrar # tool for handling .rar files
    unzip # tool for handling .zip files

    ####################
    # GUI RELATED

    # System GUI tools
    blueman         # bluetooth manager GUI
    gparted         # GUI partition editor
    flameshot       # screenshot tool

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
  # x86_64-only packages (GPU tools and packages not available on aarch64)
  ++ (with pkgs; lib.optionals isX86_64 [
    # GPU & Graphics tools (x86_64-specific)
    vulkan-tools    # vulkaninfo, vkcube (GPU testing)
    mesa-demos      # OpenGL info (includes glxinfo, glxgears, etc.)

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
