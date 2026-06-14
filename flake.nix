{
  description = "dev_machine";

  inputs = {
    # TODO: this changes if darwin
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    local-config.url = "path:/etc/nixos/local-config";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, local-config }:
  let
    userConfig = local-config.userConfig;
  in
  {
    nixosConfigurations.${userConfig.flakeName} = nixpkgs.lib.nixosSystem {
      system = userConfig.system;
      specialArgs = {
        inherit userConfig;
      };

      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        configuration
        # ./programs/audio.nix
        # ./programs/desktop_graphics.nix
        # ./programs/gaming.nix
      ];
    };
  };
}
