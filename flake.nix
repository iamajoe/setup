{
  description = "steamtv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    local-config.url = "path:/etc/nixos/local-config";
  };

  outputs = inputs@{ self, nixpkgs, local-config }:
  let
    lib = nixpkgs.lib;
    userConfig = local-config.userConfig;
  in
  {
    nixosConfigurations.${userConfig.flakeName} = nixpkgs.lib.nixosSystem {
      system = userConfig.system;
      specialArgs = {
        inherit userConfig;
      };

      modules = [
        userConfig.hardwareModule
        ./configuration.nix
        ./programs/drives.nix
        ./programs/clonehero.nix
      ];
    };
  };
}
