{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir syncBackupEncryptionKey;

  syncdriveTemplate = ../templates/syncdrive;

  syncdriveBackupScript = pkgs.replaceVars "${syncdriveTemplate}/syncdrive-backup-docker-data.sh" {
    inherit syncBackupEncryptionKey;
  };
in
{
  environment.systemPackages = [
    pkgs.rclone
    pkgs.openssl
    pkgs.gnutar
    pkgs.gzip
    pkgs.coreutils
    pkgs.findutils
    pkgs.jq
  ];

  system.activationScripts.syncdriveConfig.text = ''
    install -d -m 0755 -o ${username} -g users ${homeDir}/proton_drive
    install -d -m 0755 -o ${username} -g users ${homeDir}/proton_drive/backups
    install -d -m 0755 -o ${username} -g users ${homeDir}/proton_drive/backups/docker-data
    install -d -m 0700 -o ${username} -g users ${homeDir}/.cache/syncdrive/backups
    install -d -m 0755 -o ${username} -g users ${homeDir}/.local/state
    install -d -m 0755 -o ${username} -g users ${homeDir}/.local/bin
    install -d -m 0755 -o ${username} -g users ${homeDir}/.config/systemd/user

    rm -f ${homeDir}/.local/bin/syncdrive-backup-docker-data
    rm -f ${homeDir}/.config/systemd/user/rclone-protondrive-bisync.service
    rm -f ${homeDir}/.config/systemd/user/rclone-protondrive-bisync.timer
    rm -f ${homeDir}/.config/systemd/user/syncdrive-backup-docker-data.service
    rm -f ${homeDir}/.config/systemd/user/syncdrive-backup-docker-data.timer

    install -m 0755 -o ${username} -g users ${syncdriveBackupScript} ${homeDir}/.local/bin/syncdrive-backup-docker-data

    install -m 0644 -o ${username} -g users ${syncdriveTemplate}/rclone-protondrive-bisync.service ${homeDir}/.config/systemd/user/rclone-protondrive-bisync.service
    install -m 0644 -o ${username} -g users ${syncdriveTemplate}/rclone-protondrive-bisync.timer ${homeDir}/.config/systemd/user/rclone-protondrive-bisync.timer
    install -m 0644 -o ${username} -g users ${syncdriveTemplate}/syncdrive-backup-docker-data.service ${homeDir}/.config/systemd/user/syncdrive-backup-docker-data.service
    install -m 0644 -o ${username} -g users ${syncdriveTemplate}/syncdrive-backup-docker-data.timer ${homeDir}/.config/systemd/user/syncdrive-backup-docker-data.timer

    chown -R ${username}:users ${homeDir}/proton_drive
    chown -R ${username}:users ${homeDir}/.cache/syncdrive
    chown -R ${username}:users ${homeDir}/.local/state
    chown -R ${username}:users ${homeDir}/.local/bin
    chown -R ${username}:users ${homeDir}/.config/systemd/user

    systemctl --user -M ${username}@ daemon-reload || true
  '';
}
