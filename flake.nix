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
        userConfig.hardwareModule
        ./configuration.nix

        ./programs/general.nix
        ./programs/git.nix
        ./programs/bash.nix
        ./programs/zsh.nix
        ./programs/helix.nix
        ./programs/tmux.nix
        ./programs/yazi.nix
        ./programs/dev.nix
      ]
      # ++ lib.optionals userConfig.addDesktop [
        # ./programs/audio.nix
        # ./programs/desktop_graphics.nix
        # ./programs/dunst.nix
        # ./programs/picom.nix
        # ./programs/rofi.nix
        # ./programs/gaming.nix
        # ./programs/sunshine.nix
        # ./programs/alacritty.nix
        # ./programs/zed.nix
      # ]
      ;
    };
  };
}
