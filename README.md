# Setup (nix-darwin)

macOS setup machine.

## Requirements

- macOS
- [Lix](https://lix.systems/install/)
- Git

## Run
### Steps

1. Install Lix:

   ```sh
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

2. Restart shell or source Nix:

   ```sh
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   ```

3. Clone config:

   ```sh
   sudo mkdir -p /etc/nix-darwin
   sudo chown -R "$USER":staff /etc/nix-darwin
   git clone --branch nixos_mac --depth 1 https://github.com/iamajoe/setup.git /etc/nix-darwin
   ```

4. Create local env file:

   ```sh
   cp /etc/nix-darwin/local.nix.mac.dist /etc/nix-darwin/local.nix
   vim /etc/nix-darwin/local.nix
   ```

5. Build:

   ```sh
   sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake /etc/nix-darwin#dev_machine
   ```

6. Reboot:

   ```sh
   sudo reboot
   ```

7. Rebuild later:

   ```sh
   nixrebuild
   ```

8. Garbage collect:

   ```sh
   nixclean
   ```

## Notes

If `darwin-rebuild` is not available yet, use:

```sh
sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake /etc/nix-darwin#dev_machine
```

After the first successful build, use:

```sh
nixrebuild
```

