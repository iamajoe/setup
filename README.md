# Setup (nixos)

Nixos setup machine

## Requirements

- [NixOs](https://nixos.org/download/#nix-install-linux)

## Run
In case you want to run under ssh, do this first:
1. `sudo nano /etc/nixos/configuration.nix`
    - Uncomment `services.openssh.enable = true;`
2. `ifconfig` (to know the ip to ssh to)

### Steps
1. `sudo nano /etc/nixos/configuration.nix`
    - Add packages: `git, wget, curl, vim`
2. `git clone --branch nixos --depth 1 https://github.com/iamajoe/setup.git $HOME/nixos_config`
3. `cd $HOME/nixos_config`
4. `cp .env.json.dist .env.json`
5. `nano .env.json` (modify acccordingly)
6. build
    - For x86: `sudo nixos-rebuild switch --flake /home/iamajoe/nixos_config/#nixos-joe-x86_64`
    - For arm64: `sudo nixos-rebuild switch --flake /home/iamajoe/nixos_config/#nixos-joe-aarch64`
7. `sudo reboot`
8. for nix rebuild: `nixrebuild`, or for home manager rebuild: `hmrebuild`
9. for nix garbage collection: `nixclean`

### Parallels
TODO: still need to actually build this
