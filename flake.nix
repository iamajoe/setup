{
  description = "dev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    local-config.url = "path:/etc/nix-darwin/local.nix";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, local-config }:
  let
    userConfig = local-config.userConfig;

    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.vim
      ];

      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;

      nixpkgs.hostPlatform = userConfig.system;
    };
  in
  {
    darwinConfigurations.${userConfig.flakeName} = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit userConfig;
      };

      modules = [
        configuration
        ./programs/alacritty.nix
        ./programs/helix.nix
        ./programs/bash.nix
        ./programs/zsh.nix
        ./programs/tmux.nix
        ./programs/yazi.nix
        ./programs/dev.nix
        ./programs/zed.nix
        ./programs/general.nix
      ];
    };
  };
}
