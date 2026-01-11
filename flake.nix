{
  description = "dev_machine";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware = {
      url = "path:/etc/nixos/hardware-configuration.nix";
      flake = false;
    };

    userenv = {
      url = "path:/etc/nixos/env.json";
      flake = false;
    };
    usersecrets = {
      url = "path:/etc/nixos/secrets";
      flake = false;
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hardware, home-manager, userenv, usersecrets, ... }@inputs:
  let
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      inputs.rust-overlay.overlays.default
    ];
    buildEnv =
      let
        raw = builtins.readFile "${userenv}";
        clean = builtins.replaceStrings
          [ "\u00A0" "\u202F" "\u2009" "\u00AD" "\uFEFF" "\r" ]  # NBSP, NNBSP, thin space, soft hyphen, BOM, CR
          [ " "      " "      " "      ""       ""      "" ]
          raw;
      in builtins.fromJSON clean;
  in {
    nixosConfigurations = {
      nixos-conf-x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit buildEnv; };

        modules = [ 
          { nixpkgs.overlays = overlays; }
          "${hardware}"
          ./configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { 
                inherit inputs usersecrets;
                buildEnv = buildEnv // {
                  system = "x86_64-linux";
                  nixosConfig = "nixos-conf-x86_64";
                };
              };
              users.${buildEnv.username} = import ./home.nix;
            };
          }
        ];
      };

      nixos-conf-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit buildEnv; };

        modules = [ 
          { nixpkgs.overlays = overlays; }
          "${hardware}"
          ./configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { 
                inherit inputs usersecrets;
                buildEnv = buildEnv // {
                  system = "aarch64-linux";
                  nixosConfig = "nixos-conf-aarch64";
                };
              };
              users.${buildEnv.username} = import ./home.nix;
            };
          }
        ];
      };
    };
  };
}

