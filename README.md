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
   cp /etc/nix-darwin/.env.json.mac.dist /etc/nix-darwin/.env.json
   vim /etc/nix-darwin/.env.json
   ```

5. Build:

   ```sh
   sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake /etc/nix-darwin#dev_mac
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

## Env file

Use:

```sh
.env.json
```

Do not commit it.
Use the dist file as a template:

```sh
.env.json.mac.dist
```

Example:

```json
{
  "system": "aarch64-darwin",
  "platform": "darwin",
  "username": "your-macos-username",
  "homeDir": "/Users/your-macos-username",
  "flakePath": "/etc/nix-darwin",
  "flakeName": "dev_mac",
  "userFullname": "Your Name",
  "userEmail": "you@example.com"
}
```

## Notes

If `darwin-rebuild` is not available yet, use:

```sh
sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake /etc/nix-darwin#dev_mac
```

After the first successful build, use:

```sh
nixrebuild
```

