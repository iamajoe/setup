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
4. `git clone --branch nixos --depth 1 https://github.com/iamajoe/setup.git /etc/nixos`
5. `cp /etc/nixos.bak/hardware-configuration.nix /etc/nixos/local-config/hardware-configuration.nix`
6. `sudo chown -R "$USER":users /etc/nixos`
7. `cp /etc/nixos/local-config/flake.nix.dist /etc/nixos/local-config/flake.nix`
8. `sudo vim /etc/nixos/local-config/flake.nix` (modify acccordingly to your data)
9. build: `sudo nixos-rebuild switch --flake /etc/nixos/#<flakeName>`
10. `sudo reboot`
11. for nix rebuild: `nixrebuild`
12. for nix garbage collection: `nixclean`
13. copy ssh key manually to: `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
14. if `addDesktop = true`, run `sudo sensors-detect` once so the bar's CPU temp widget has sensors to read
15. find your xrandr output name for `displayOutput` (no X session needed):
    `for c in /sys/class/drm/card*-*/; do echo "$(basename "$c"): $(cat "$c/status")"; done`

### Backup syncing
Enabled via `userConfig.addSyncBackup`. Proton Drive is supported.
1. Create a new remote with `rclone config` (name the remote `proton`)
2. Test with `rclone tree proton: --max-depth 1`

### `local-config/flake.nix` reference
Copied from `local-config/flake.nix.dist` per-machine, gitignored (never committed — safe to keep secrets/passwords in it).

| Field | Purpose |
|---|---|
| `hardwareModule`, `system`, `platform` | standard nixos-generate-config output + target arch |
| `flakePath`, `flakeName`, `hostname` | flake output name, `nixos-rebuild --flake .#<flakeName>` |
| `username`, `homeDir`, `userFullname`, `userEmail` | account + git identity |
| `syncBackupEncryptionKey` | key for the `addSyncBackup` docker-data backup |
| `addSyncBackup` | rclone Proton Drive sync + encrypted docker-data backups |
| `addDesktop` | qtile desktop stack: X server, theming, Steam, Firefox, etc. |
| `gpu` | `"nvidia"` \| `"intel"` \| `"none"` — picks the driver/VAAPI config |
| `displayOutput` | xrandr output to lock resolution on, e.g. `"HDMI-1"`, `"DP-2"` |
| `maxResolution` | width in px; height derived assuming 16:9 |
| `autoRunSteamBigPicture` | launch `steam -gamepadui` on qtile start (TV) |
| `dpi`, `cursorSize` | X/Xresources/GTK scaling — bump for a HiDPI workstation monitor |
| `neverSleep` | disable screen blanking/DPMS/suspend/hibernate (TV); `false` for a workstation that should sleep/lock |
| `autoPoweroffNightly` | power off at 01:00 daily (TV) |
| `addNasMounts`, `nasHost`, `nasUser`, `nasPassword` | CIFS mounts at `/mnt/{music,video,roms}` |
| `addEmulation` | RetroArch + ES-DE + Clone Hero, as Steam Big Picture shortcuts |

**TV / game station** profile: `addDesktop = true`, `gpu = "nvidia"`, `autoRunSteamBigPicture = true`, `neverSleep = true`, `addNasMounts = true`, `addEmulation = true`.
**Workstation** profile: `addDesktop = true`, `gpu = "intel"`, `autoRunSteamBigPicture = false`, `neverSleep = false`, `dpi`/`cursorSize` bumped for HiDPI, `addNasMounts`/`addEmulation = false`.

### Migrating an existing `~/services/docker-data`
The docker-compose module only ever writes `~/services/docker-compose.yml` and its systemd unit — it never touches `~/services/docker-data` or `~/services/docker-config`. If you're moving from an older setup, copy those two folders into place under `~/services/` before the first `nixos-rebuild switch` and they'll be picked up as-is.
