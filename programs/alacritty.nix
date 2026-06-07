{ config, pkgs, lib, ... }:

let
  username = "joe";
  homeDir = "/Users/${username}";

  alacrittyToml = pkgs.formats.toml { }.generate "alacritty.toml" {
    general = {
      live_config_reload = true;
    };

    colors = {
      draw_bold_text_with_bright_colors = true;

      primary = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        dim_foreground = "#7f849c";
        bright_foreground = "#cdd6f4";
      };

      cursor = {
        text = "#0F0F16";
        cursor = "#f5e0dc";
      };

      vi_mode_cursor = {
        text = "#0F0F16";
        cursor = "#b4befe";
      };

      search = {
        matches = {
          foreground = "#0F0F16";
          background = "#a6adc8";
        };

        focused_match = {
          foreground = "#0F0F16";
          background = "#a6e3a1";
        };
      };

      footer_bar = {
        foreground = "#0F0F16";
        background = "#a6adc8";
      };

      hints = {
        start = {
          foreground = "#0F0F16";
          background = "#f9e2af";
        };

        end = {
          foreground = "#0F0F16";
          background = "#a6adc8";
        };
      };

      selection = {
        text = "#0F0F16";
        background = "#f5e0dc";
      };

      normal = {
        black = "#45475a";
        red = "#f38ba8";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        blue = "#89b4fa";
        magenta = "#f5c2e7";
        cyan = "#94e2d5";
        white = "#bac2de";
      };

      bright = {
        black = "#585b70";
        red = "#f38ba8";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        blue = "#89b4fa";
        magenta = "#f5c2e7";
        cyan = "#94e2d5";
        white = "#a6adc8";
      };

      indexed_colors = [
        {
          index = 16;
          color = "#fab387";
        }
        {
          index = 17;
          color = "#f5e0dc";
        }
      ];
    };

    window = {
      decorations = "transparent";

      padding = {
        x = 10;
        y = 10;
      };

      dynamic_title = true;
    };

    cursor = {
      style = "Block";
    };

    font = {
      size = 12;

      offset = {
        x = 1;
        y = 2;
      };

      normal = {
        family = "NotoSansM Nerd Font";
        style = "Regular";
      };

      bold = {
        family = "NotoSansM Nerd Font";
        style = "SemiBold";
      };
    };

    terminal.shell = {
      program = "${pkgs.zsh}/bin/zsh";
      args = [ "--login" ];
    };

    keyboard.bindings = [
      {
        key = "K";
        mods = "Command";
        action = "ClearHistory";
      }
      {
        key = "V";
        mods = "Command";
        action = "Paste";
      }
      {
        key = "C";
        mods = "Command";
        action = "Copy";
      }
      {
        key = "Key0";
        mods = "Command";
        action = "ResetFontSize";
      }
      {
        key = "Equals";
        mods = "Command";
        action = "IncreaseFontSize";
      }
      {
        key = "Plus";
        mods = "Command";
        action = "IncreaseFontSize";
      }
      {
        key = "NumpadAdd";
        mods = "Command";
        action = "IncreaseFontSize";
      }
      {
        key = "Minus";
        mods = "Command";
        action = "DecreaseFontSize";
      }
      {
        key = "NumpadSubtract";
        mods = "Command";
        action = "DecreaseFontSize";
      }
    ];
  };
in
{
  environment.systemPackages = [
    pkgs.alacritty
    pkgs.zsh
  ];

  system.activationScripts.alacrittyConfig.text = ''
    mkdir -p ${homeDir}/.config/alacritty
    cp ${alacrittyToml} ${homeDir}/.config/alacritty/alacritty.toml
    chown -R ${username}:staff ${homeDir}/.config/alacritty
  '';
}
