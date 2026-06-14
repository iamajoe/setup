{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  yaziConfig = pkgs.formats.toml { }.generate "yazi.toml" {
    opener = {
      open = [
        {
          run = "open \"$1\"";
          orphan = true;
          desc = "Open default app";
        }
      ];

      edit = [
        {
          run = "hx \"$@\"";
          block = true;
        }
      ];
    };

    open = {
      prepend_rules = [
        {
          mime = "image/*";
          use = "open";
        }
        {
          mime = "application/pdf";
          use = "open";
        }
        {
          mime = "video/*";
          use = "open";
        }
        {
          mime = "audio/*";
          use = "open";
        }
        {
          mime = "application/zip";
          use = "open";
        }
      ];

      rules = [
        {
          mime = "application/json";
          use = "edit";
        }
        {
          mime = "text/*";
          use = "edit";
        }
        {
          url = "*.md";
          use = "edit";
        }
        {
          url = "*.yml";
          use = "edit";
        }
        {
          url = "*.txt";
          use = "edit";
        }
        {
          url = "*.json";
          use = "edit";
        }
      ];
    };

    mgr = {
      show_hidden = true;
      sort_by = "mtime";
    };
  };

  yWrapper = pkgs.writeShellScriptBin "y" ''
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      printf '%s\n' "$cwd"
    fi
    rm -f "$tmp"
  '';
in
{
  environment.systemPackages = [
    pkgs.yazi
    yWrapper
  ];

  system.activationScripts.yaziConfig.text = ''
    mkdir -p ${homeDir}/.config/yazi

    rm -f ${homeDir}/.config/yazi/yazi.toml
    ln -sfn ${yaziConfig} ${homeDir}/.config/yazi/yazi.toml

    chown ${username}:staff ${homeDir}/.config/yazi
    chown -h ${username}:staff ${homeDir}/.config/yazi/yazi.toml
  '';
}
