{ config, pkgs, lib, ... }:

let
  env = builtins.fromJSON (builtins.readFile /etc/nixos/env.json);

  syncdriveEnv = env.syncdrive or { };

  rcloneRemote = syncdriveEnv.rcloneRemote or "proton";
  encryptionKey = syncdriveEnv.encryptionKey;

  homeDir = config.home.homeDirectory;

  protonLocal = "${homeDir}/proton_drive";
  rcloneConfig = "${homeDir}/.config/rclone/rclone.conf";

  dockerDataDir = "${homeDir}/services/docker-data";
  dockerBackupDir = "${protonLocal}/backups/docker-data";
  tempBackupDir = "${homeDir}/.cache/syncdrive/backups";

  bisyncLog = "${homeDir}/.local/state/rclone-protondrive-bisync.log";
  backupLog = "${homeDir}/.local/state/syncdrive-docker-data-backup.log";
in
{
  # Automatically start/restart user systemd units managed by Home Manager.
  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    rclone
    openssl
    gnutar
    gzip
    coreutils
    findutils
  ];

  home.activation.createSyncDriveFolders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${protonLocal}"
    mkdir -p "${dockerBackupDir}"
    mkdir -p "${tempBackupDir}"
    mkdir -p "${homeDir}/.local/state"

    chmod 755 "${protonLocal}"
    chmod 755 "${dockerBackupDir}"
    chmod 700 "${tempBackupDir}"
  '';

  # ─── Proton Drive bidirectional sync ─────────────────────────────────────

  systemd.user.services.rclone-protondrive-bisync = {
    Unit = {
      Description = "Bidirectional sync Proton Drive with local folder";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";

      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${protonLocal}";

      ExecStart = ''
        ${pkgs.rclone}/bin/rclone bisync ${protonLocal} ${rcloneRemote}: \
          --config=${rcloneConfig} \
          --create-empty-src-dirs \
          --compare size,modtime \
          --conflict-resolve newer \
          --conflict-loser pathname \
          --backup-dir1 ${homeDir}/.local/share/rclone/protondrive-conflicts/local \
          --backup-dir2 ${rcloneRemote}:rclone-conflicts \
          --log-file ${bisyncLog} \
          --log-level INFO
      '';
    };
  };

  systemd.user.timers.rclone-protondrive-bisync = {
    Unit = {
      Description = "Run Proton Drive bidirectional sync periodically";
    };

    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "5m";
      Persistent = true;
      Unit = "rclone-protondrive-bisync.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # ─── Encrypted docker-data backup into ProtonDrive ───────────────────────

  systemd.user.services.syncdrive-backup-docker-data = {
    Unit = {
      Description = "Create encrypted docker-data backup in Proton Drive";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";

      ExecStart = pkgs.writeShellScript "syncdrive-backup-docker-data" ''
        set -euo pipefail

        timestamp="$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S)"
        hostname="$(${pkgs.coreutils}/bin/hostname)"
        name="docker-data-$hostname-$timestamp.tar.gz.enc"

        src="${dockerDataDir}"
        tmp="${tempBackupDir}/$name.tmp"
        final="${dockerBackupDir}/$name"

        if [ ! -d "$src" ]; then
          echo "Source directory does not exist: $src" >&2
          exit 1
        fi

        ${pkgs.coreutils}/bin/mkdir -p "${tempBackupDir}" "${dockerBackupDir}"

        echo "Creating encrypted backup: $final"

        ${pkgs.gnutar}/bin/tar \
          --xattrs \
          --acls \
          --one-file-system \
          -C "${homeDir}/services" \
          -czf - \
          docker-data \
          | ${pkgs.openssl}/bin/openssl enc \
              -aes-256-cbc \
              -pbkdf2 \
              -salt \
              -pass pass:'${encryptionKey}' \
              -out "$tmp"

        ${pkgs.coreutils}/bin/chmod 600 "$tmp"
        ${pkgs.coreutils}/bin/mv "$tmp" "$final"

        # Keep only the newest 14 local encrypted docker-data backups.
        ${pkgs.coreutils}/bin/ls -1t "${dockerBackupDir}"/docker-data-*.tar.gz.enc 2>/dev/null \
          | ${pkgs.coreutils}/bin/tail -n +15 \
          | ${pkgs.findutils}/bin/xargs -r ${pkgs.coreutils}/bin/rm -f

        echo "Backup complete: $final"
      '';

      ExecStartPost = "${pkgs.systemd}/bin/systemctl --user start rclone-protondrive-bisync.service";

      StandardOutput = "append:${backupLog}";
      StandardError = "append:${backupLog}";
    };
  };

  systemd.user.timers.syncdrive-backup-docker-data = {
    Unit = {
      Description = "Run encrypted docker-data backup daily";
    };

    Timer = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "30m";
      Unit = "syncdrive-backup-docker-data.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
