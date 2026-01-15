{ config, pkgs, ... }:

{
  # Custom Rofi helper scripts
  home.packages = with pkgs; [
    # Web search script
    (pkgs.writeShellScriptBin "rofi-web-search" ''
      #!/usr/bin/env bash
      
      # Prompt for search query with faster response
      query=$(rofi -dmenu -i -p "  Search" -no-lazy-grab)
      
      if [ -n "$query" ]; then
        # URL encode the query
        encoded=$(printf %s "$query" | jq -sRr @uri)
        
        # Show search options (DuckDuckGo first as default) with faster menu
        option=$(printf "DuckDuckGo\nGoogle\nWikipedia\nYouTube\nGitHub\nRust Docs\nCrates.io\nNPM\nReddit\nGoogle Translate\nGoogle Maps\nAmazon" | rofi -dmenu -i -p "󰍉 Search Engine" -no-lazy-grab)
        
        case "$option" in
          "DuckDuckGo")
            firefox "https://duckduckgo.com/?q=$encoded" &
            ;;
          "Google")
            firefox "https://www.google.com/search?q=$encoded" &
            ;;
          "Wikipedia")
            firefox "https://en.wikipedia.org/wiki/Special:Search?search=$encoded" &
            ;;
          "YouTube")
            firefox "https://www.youtube.com/results?search_query=$encoded" &
            ;;
          "GitHub")
            firefox "https://github.com/search?q=$encoded" &
            ;;
          "Rust Docs")
            firefox "https://docs.rs/releases/search?query=$encoded" &
            ;;
          "Crates.io")
            firefox "https://crates.io/search?q=$encoded" &
            ;;
          "NPM")
            firefox "https://www.npmjs.com/search?q=$encoded" &
            ;;
          "Reddit")
            firefox "https://www.reddit.com/search/?q=$encoded" &
            ;;
          "Google Translate")
            firefox "https://translate.google.com/?sl=auto&tl=en&text=$encoded" &
            ;;
          "Google Maps")
            firefox "https://www.google.com/maps/search/$encoded" &
            ;;
          "Amazon")
            firefox "https://www.amazon.es/s?k=$encoded" &
            ;;
        esac
      fi
    '')
    
    # Quick notes script
    (pkgs.writeShellScriptBin "rofi-quick-notes" ''
      #!/usr/bin/env bash
      
      NOTES_DIR="$HOME/.local/share/quick-notes"
      mkdir -p "$NOTES_DIR"
      
      # Show options with faster response
      option=$(printf "📝 New Note\n📋 View Notes\n🔍 Search Notes" | rofi -dmenu -i -p " Notes" -no-lazy-grab)
      
      case "$option" in
        "📝 New Note")
          # Combined title and note input for faster workflow
          title=$(rofi -dmenu -i -p "Note Title" -no-lazy-grab)
          if [ -n "$title" ]; then
            note=$(rofi -dmenu -i -p "Note Content" -lines 5 -no-lazy-grab)
            if [ -n "$note" ]; then
              timestamp=$(date '+%Y-%m-%d %H:%M:%S')
              {
                echo "[$timestamp] $title"
                echo "$note"
                echo ""
              } >> "$NOTES_DIR/notes.txt"
              notify-send "Note Saved" "$title" -t 2000
            fi
          fi
          ;;
        "📋 View Notes")
          if [ -f "$NOTES_DIR/notes.txt" ] && [ -s "$NOTES_DIR/notes.txt" ]; then
            alacritty -e less -R "$NOTES_DIR/notes.txt"
          else
            notify-send "No Notes" "No notes found" -t 2000
          fi
          ;;
        "🔍 Search Notes")
          if [ -f "$NOTES_DIR/notes.txt" ] && [ -s "$NOTES_DIR/notes.txt" ]; then
            query=$(rofi -dmenu -i -p "Search" -no-lazy-grab)
            if [ -n "$query" ]; then
              result=$(grep -i "$query" "$NOTES_DIR/notes.txt" || echo "")
              if [ -n "$result" ]; then
                echo "$result" | rofi -dmenu -i -p "Search Results" -no-lazy-grab
              else
                notify-send "No Results" "No matches found for: $query" -t 2000
              fi
            fi
          else
            notify-send "No Notes" "No notes to search" -t 2000
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
      placeholder = "Search...";
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
        bg-col = mkLiteral "#1e1e2e";
        bg-col-light = mkLiteral "#1e1e2e";
        bg-col-dark = mkLiteral "#11111b";  # Darker background for input bar
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
        background-color = mkLiteral "@bg-col-dark";  # Darker background
        border-radius = mkLiteral "5px";
        padding = mkLiteral "8px";
        margin = mkLiteral "2px";  # 2px margin from edges
      };

      prompt = {
        background-color = mkLiteral "transparent";
        padding = mkLiteral "6px";
        text-color = mkLiteral "@blue";
        border-radius = mkLiteral "3px";
        margin = mkLiteral "0px";
      };

      "textbox-prompt-colon" = {
        expand = false;
        str = ":";
      };

      entry = {
        padding = mkLiteral "6px";
        margin = mkLiteral "0px 0px 0px 10px";
        text-color = mkLiteral "@fg-col";
        background-color = mkLiteral "transparent";  # Transparent to show darker inputbar
        placeholder-color = mkLiteral "@grey";
        placeholder = "Search...";
      };

      listview = {
        border = mkLiteral "0px 0px 0px";
        padding = mkLiteral "6px 0px 0px";
        margin = mkLiteral "8px 20px 0px 20px";  # Spacing after input bar
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
