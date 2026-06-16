# Setup (NixOS Steam TV)

This machine is intended to behave like a simple living-room console.

## Install NixOS

Official download page:

- NixOS downloads: <https://nixos.org/download/>

Recommended image for this machine:

- **Graphical, 64-bit Intel/AMD (x86_64)** ISO

You can also use the minimal ISO, but the graphical ISO is more convenient for a TV-connected install because it includes the graphical installer and desktop environments in the live system.

Useful references:

- NixOS manual: <https://nixos.org/manual/nixos/stable/>
- NixOS installation guide: <https://wiki.nixos.org/wiki/NixOS_Installation_Guide/en>

### Create the boot USB

Write the ISO to a USB stick using your preferred imaging tool.
NOTE: Replace `sdX` with your USB device.

On Linux:

```bash
lsblk
sudo umount /dev/sdX*
sudo dd if=/path/to/nixos-graphical-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

On Mac:

```bash
diskutil list
diskutil unmountDisk /dev/sdX
sudo dd if=/path/to/nixos-graphical-*.iso of=/dev/rsdX bs=4M status=progress oflag=sync
diskutil eject /dev/sdX
```

### Boot from USB

1. Plug the USB stick into the computer
2. Power it on
3. Open the boot menu or BIOS
4. Choose the USB device
5. Boot the NixOS live environment

The exact boot-menu key varies by hardware vendor and model. Common keys include `F12`, `F10`, `Esc`, `Del`, and others.

## Setup
1. `sudo nano /etc/nixos/configuration.nix`
    - Add packages: `git, wget, curl, vim, helix`
    - Uncomment `services.openssh.enable = true;`
2. `sudo nixos-rebuild switch`
3. `sudo mkdir /etc/nixos`
4. `sudo chown -R "$USER":users /etc/nixos`
5. `git clone --branch nixos_steam_tv --depth 1 https://github.com/iamajoe/setup.git /etc/nixos`
6. `cp /etc/nixos.bak/hardware-configuration.nix /etc/nixos/local-config/hardware-configuration.nix`
7. `cp /etc/nixos/local-config/flake.nix.dist /etc/nixos/local-config/flake.nix`
8. `sudo vim /etc/nixos/local-config/flake.nix` (modify acccordingly to your data)
9. build: `sudo nixos-rebuild switch --flake /etc/nixos/#<flakeName>`
10. `sudo reboot`

### Find the correct network

Find your ip: `ip address`

Before rebuilding, confirm the NIC name because Wake-on-LAN depends on it.

```bash
ip link
```

Look for the wired interface name, such as:

- `enp1s0`
- `enp2s0`
- `eth0`

Then update `networkInterface` on your `local-config/flake.nix`.

## Connecting to sunshine
First create the pairing
```
moonlight pair <IP>
moonlight list <IP>
```
Then create the steam shortcut by exiting big picture mode, adding a non-steam game and browsing to:
```
~/SteamShortcuts/moonlight-steam-big-picture.sh
```
