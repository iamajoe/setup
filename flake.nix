{
  description = "dev_machine";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
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

    qtile-flake = {
      url = "github:qtile/qtile";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim: use "nightly" for prerelease from GitHub releases, or "master" for tip of master.
    # Update: nix flake lock --update-input neovim-src
    neovim-src = {
      url = "github:neovim/neovim/nightly";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, hardware, home-manager, userenv, usersecrets, ... }@inputs:
  let
    overlays = [
      (import ./nix/overlays/neovim-nightly.nix { neovim-src = inputs.neovim-src; })
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
        specialArgs = { 
          inherit buildEnv; 
          qtile-flake = inputs.qtile-flake;
        };

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
        specialArgs = { 
          inherit buildEnv; 
          qtile-flake = inputs.qtile-flake;
        };

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

