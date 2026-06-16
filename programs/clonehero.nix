{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  cloneHero = pkgs.stdenv.mkDerivation {
    pname = "clone-hero";
    version = "1.1.0.6142";

    src = pkgs.fetchurl {
      url = "https://github.com/clonehero-game/releases/releases/download/v1.1.0.6142-final/Linux.x86_64-Standalone.tar";

      # First rebuild will fail with the real hash.
      # Replace this with the `got:` hash.
      hash = lib.fakeHash;
    };

    nativeBuildInputs = [
      pkgs.makeWrapper
    ];

    unpackPhase = ''
      runHook preUnpack

      mkdir source
      tar -xf "$src" -C source

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt/clone-hero"
      cp -r source/* "$out/opt/clone-hero/"

      mkdir -p "$out/bin"

      if [ -f "$out/opt/clone-hero/clonehero" ]; then
        chmod +x "$out/opt/clone-hero/clonehero"

        makeWrapper ${pkgs.steam-run}/bin/steam-run "$out/bin/clone-hero" \
          --add-flags "$out/opt/clone-hero/clonehero"

      elif [ -f "$out/opt/clone-hero/Clone Hero" ]; then
        chmod +x "$out/opt/clone-hero/Clone Hero"

        makeWrapper ${pkgs.steam-run}/bin/steam-run "$out/bin/clone-hero" \
          --add-flags "$out/opt/clone-hero/Clone Hero"

      else
        echo "Could not find Clone Hero executable."
        echo "Files found:"
        find "$out/opt/clone-hero" -maxdepth 3 -type f
        exit 1
      fi

      runHook postInstall
    '';
  };
in
{
  environment.systemPackages = [
    pkgs.steam-run
    cloneHero
  ];

  system.activationScripts.cloneHeroSteamShortcut = ''
    mkdir -p ${homeDir}/SteamShortcuts

    cat > ${homeDir}/SteamShortcuts/clone-hero.sh <<'EOF'
#!/bin/bash
LOG=${homeDir}/SteamShortcuts/clone-hero.log

echo "Launching Clone Hero" > "$LOG"
exec /run/current-system/sw/bin/clone-hero >> "$LOG" 2>&1
EOF

    chmod +x ${homeDir}/SteamShortcuts/clone-hero.sh
    chown -R ${username}:users ${homeDir}/SteamShortcuts
  '';
}
