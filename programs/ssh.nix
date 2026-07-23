{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  sshConfigText = ''
    Host *
      AddKeysToAgent yes
  '';
in
{
  programs.ssh.startAgent = true;

  system.activationScripts.sshConfig.text = ''
    install -d -m 0700 -o ${username} -g users ${homeDir}/.ssh

    rm -f ${homeDir}/.ssh/config
    cat > ${homeDir}/.ssh/config <<'EOF'
${sshConfigText}
EOF

    chown ${username}:users ${homeDir}/.ssh/config
    chmod 0600 ${homeDir}/.ssh/config
  '';
}
