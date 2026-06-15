#!/usr/bin/env bash

set -euo pipefail

home_dir="$HOME"

proton_local="$home_dir/proton_drive"
docker_data_dir="$home_dir/services/docker-data"
docker_backup_dir="$proton_local/backups/docker-data"
temp_backup_dir="$home_dir/.cache/syncdrive/backups"

timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
hostname="$(hostname)"
name="docker-data-$hostname-$timestamp.tar.gz.enc"

src="$docker_data_dir"
tmp="$temp_backup_dir/$name.tmp"
final="$docker_backup_dir/$name"
key_file="$temp_backup_dir/encryption-key"

mkdir -p "$temp_backup_dir" "$docker_backup_dir"
chmod 700 "$temp_backup_dir"

cat > "$key_file" <<'EOF'
@syncBackupEncryptionKey@
EOF
chmod 600 "$key_file"

if [ ! -s "$key_file" ]; then
  echo "Missing syncdrive encryption key" >&2
  rm -f "$key_file"
  exit 1
fi

if [ ! -d "$src" ]; then
  echo "Source directory does not exist: $src" >&2
  rm -f "$key_file"
  exit 1
fi

echo "Creating encrypted backup: $final"

tar \
  --xattrs \
  --acls \
  --one-file-system \
  -C "$home_dir/services" \
  -czf - \
  docker-data \
  | openssl enc \
      -aes-256-cbc \
      -pbkdf2 \
      -salt \
      -pass file:"$key_file" \
      -out "$tmp"

chmod 600 "$tmp"
mv "$tmp" "$final"

rm -f "$key_file"

# Keep only the newest 14 local encrypted backups.
ls -1t "$docker_backup_dir"/docker-data-*.tar.gz.enc 2>/dev/null \
  | tail -n +15 \
  | xargs -r rm -f

echo "Backup complete: $final"
