{
  description = "dev_machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    local-config.url = "path:/etc/nixos/local-config";

    qtile-flake = {
      # master
      # url = "github:qtile/qtile";
      # v0.36
      url = "github:qtile/qtile/8ec00d083cc39098aa149e785d9fec85b593b49c";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr/346411fa21afd297f5ed3b3fa56f9e3fbf7654b7";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-compass.url = "github:NixOS/nixpkgs/61e6900d4bbf3dc13c7444f7521296a4cdbde6e2";
  };

  outputs = inputs@{ self, nixpkgs, local-config, qtile-flake, herdr, nixpkgs-compass }:
  let
    lib = nixpkgs.lib;
    userConfig = local-config.userConfig;
  in
  {
    nixosConfigurations.${userConfig.flakeName} = nixpkgs.lib.nixosSystem {
      system = userConfig.system;
      specialArgs = {
        inherit userConfig qtile-flake herdr nixpkgs-compass;
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
        ./programs/services.nix
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
        ./programs/via.nix
      ]
      ++ lib.optionals userConfig.addDevApplications [
        ./programs/sublime.nix
        ./programs/compass.nix
        ./programs/cursor.nix
        ./programs/claude.nix
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
