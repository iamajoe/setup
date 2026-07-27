{
  description = "dev_machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    local-config.url = "path:/etc/nixos/local-config";

    qtile-flake = {
      url = "github:qtile/qtile";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, local-config, qtile-flake, herdr }:
  let
    lib = nixpkgs.lib;
    userConfig = local-config.userConfig;
  in
  {
    nixosConfigurations.${userConfig.flakeName} = nixpkgs.lib.nixosSystem {
      system = userConfig.system;
      specialArgs = {
        inherit userConfig qtile-flake herdr;
      };

      modules = [
        userConfig.hardwareModule
        ./configuration.nix

        ./programs/basic.nix
        ./programs/git.nix
        ./programs/ssh.nix
        ./programs/bash.nix
        ./programs/zsh.nix
        ./programs/helix.nix
        ./programs/tmux.nix
        ./programs/herdr.nix
        ./programs/yazi.nix
        ./programs/dev.nix
        ./programs/docker-compose.nix
      ]
      ++ lib.optionals userConfig.addSyncBackup [
        ./programs/syncdrive.nix
      ]
      ++ lib.optionals userConfig.addDesktop [
        ./programs/audio.nix
        ./programs/desktop_graphics.nix
        ./programs/desktop_apps.nix
        ./programs/qtile.nix
        ./programs/firefox.nix
        ./programs/dunst.nix
        ./programs/picom.nix
        ./programs/rofi.nix
        ./programs/gaming.nix
        ./programs/sunshine.nix
        ./programs/alacritty.nix
        ./programs/zed.nix
      ]
      ++ lib.optionals userConfig.addDevApplications [
        ./programs/sublime.nix
        ./programs/compass.nix
        ./programs/cursor.nix
        ./programs/claude.nix
        ./programs/chatgpt.nix
        ./programs/stripe.nix
        ./programs/dbeaver.nix
      ]
      ++ lib.optionals userConfig.addNasMounts [
        ./programs/drives.nix
      ]
      ++ lib.optionals userConfig.addEmulation [
        ./programs/emulation.nix
        ./programs/clonehero.nix
        ./programs/icons.nix
      ]
      ;
    };
  };
}
