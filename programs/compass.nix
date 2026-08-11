{ config, pkgs, nixpkgs-compass, lib, userConfig, ... }:

let
  compassPkgs = import nixpkgs-compass {
    system = pkgs.system;

    config = {
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "mongodb-compass"
        ];
    };
  };
in
{
  environment.systemPackages = [
    compassPkgs.mongodb-compass
  ];
}
