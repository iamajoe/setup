# Setup (nixos)

Nixos setup machine

## Requirements

- [NixOs](https://nixos.org/download/#nix-install-linux)

## Run
In case you want to run under ssh, do this first:
1. `sudo nano /etc/nixos/configuration.nix`
    - Uncomment `services.openssh.enable = true;`
2. `ip address` (to know the ip to ssh to)
3. `sudo nixos-rebuild switch`

### Steps
1. `sudo nano /etc/nixos/configuration.nix`
    - Add packages: `git, wget, curl, vim, helix`
2. `sudo nixos-rebuild switch`
3. `sudo mv /etc/nixos /etc/nixos.bak`
4. `git clone --branch nixos_v2 --depth 1 https://github.com/iamajoe/setup.git /etc/nixos`
5. `cp /etc/nixos.bak/hardware-configuration.nix /etc/nixos/local-config/hardware-configuration.nix`
6. `sudo chown -R "$USER":users /etc/nixos`
7. `cp /etc/nixos/local-config/flake.nix.dist /etc/nixos/local-config/flake.nix`
8. `sudo vim /etc/nixos/local-config/flake.nix` (modify acccordingly to your data)
9. build: `sudo nixos-rebuild switch --flake /etc/nixos/#<flakeName>`
10. `sudo reboot`
11. for nix rebuild: `nixrebuild`
12. for nix garbage collection: `nixclean`
13. copy ssh key manually to: `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
