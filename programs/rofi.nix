{ config, pkgs, ... }:

{
  # Custom Rofi helper scripts
  home.packages = with pkgs; [
    # Web search script
    (pkgs.writeShellScriptBin "rofi-web-search" ''
      #!/usr/bin/env bash
      
      # Prompt for search query
      query=$(echo "" | rofi -dmenu -p "  Search")
      
      if [ -n "$query" ]; then
        # URL encode the query
        encoded=$(echo "$query" | sed 's/ /+/g')
        
        # Show search options (DuckDuckGo first as default)
        option=$(echo -e "DuckDuckGo\nGoogle\nWikipedia\nYouTube\nGitHub\nRust Docs\nCrates.io\nNPM\nReddit\nGoogle Translate\nGoogle Maps\nAmazon" | rofi -dmenu -p "󰍉 Search Engine")
        
        case "$option" in
          "DuckDuckGo")
            firefox "https://duckduckgo.com/?q=$encoded"
            ;;
          "Google")
            firefox "https://www.google.com/search?q=$encoded"
            ;;
          "Wikipedia")
            firefox "https://en.wikipedia.org/wiki/Special:Search?search=$encoded"
            ;;
          "YouTube")
            firefox "https://www.youtube.com/results?search_query=$encoded"
            ;;
          "GitHub")
            firefox "https://github.com/search?q=$encoded"
            ;;
          "Rust Docs")
            firefox "https://docs.rs/releases/search?query=$encoded"
            ;;
          "Crates.io")
            firefox "https://crates.io/search?q=$encoded"
            ;;
          "NPM")
            firefox "https://www.npmjs.com/search?q=$encoded"
            ;;
          "Reddit")
            firefox "https://www.reddit.com/search/?q=$encoded"
            ;;
          "Google Translate")
            firefox "https://translate.google.com/?sl=auto&tl=en&text=$encoded"
            ;;
          "Google Maps")
            firefox "https://www.google.com/maps/search/$encoded"
            ;;
          "Amazon")
            firefox "https://www.amazon.es/s?k=$encoded"
            ;;
        esac
      fi
    '')
    
    # Quick notes script
    (pkgs.writeShellScriptBin "rofi-quick-notes" ''
      #!/usr/bin/env bash
      
      NOTES_DIR="$HOME/.local/share/quick-notes"
      mkdir -p "$NOTES_DIR"
      
      # Show options
      option=$(echo -e "📝 New Note\n📋 View Notes\n🔍 Search Notes" | rofi -dmenu -p " Notes")
      
      case "$option" in
        "📝 New Note")
          title=$(echo "" | rofi -dmenu -p "Note Title")
          if [ -n "$title" ]; then
            note=$(echo "" | rofi -dmenu -p "Note Content")
            if [ -n "$note" ]; then
              timestamp=$(date '+%Y-%m-%d %H:%M:%S')
              echo "[$timestamp] $title" >> "$NOTES_DIR/notes.txt"
              echo "$note" >> "$NOTES_DIR/notes.txt"
              echo "" >> "$NOTES_DIR/notes.txt"
              rofi -e "Note saved!"
            fi
          fi
          ;;
        "📋 View Notes")
          if [ -f "$NOTES_DIR/notes.txt" ]; then
            alacritty -e less "$NOTES_DIR/notes.txt"
          else
            rofi -e "No notes found"
          fi
          ;;
        "🔍 Search Notes")
          if [ -f "$NOTES_DIR/notes.txt" ]; then
            query=$(echo "" | rofi -dmenu -p "Search")
            if [ -n "$query" ]; then
              result=$(grep -i "$query" "$NOTES_DIR/notes.txt")
              if [ -n "$result" ]; then
                echo "$result" | rofi -dmenu -p "Results"
              else
                rofi -e "No results found"
              fi
            fi
          else
            rofi -e "No notes found"
          fi
          ;;
      esac
    '')
  ];

  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    extraConfig = {
      modi = "run,drun,window";
      icon-theme = "Oranchelo";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      window-format = "{w} {c} {t}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "  ";
      display-window = "  ";
      display-run = "  ";
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
        height = mkLiteral "500px";
        border = mkLiteral "3px";
        border-color = mkLiteral "@border-col";
        border-radius = mkLiteral "8px";
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
        columns = 1;
        lines = 8;
        background-color = mkLiteral "@bg-col";
      };

      element = {
        padding = mkLiteral "5px";
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@fg-col";
      };

      element-icon = {
        size = mkLiteral "32px";
        margin = mkLiteral "0px 10px 0px 0px";
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
}
