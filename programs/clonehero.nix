{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  cloneHero = pkgs.stdenv.mkDerivation {
    pname = "clone-hero";
    version = "1.1.0.6142";

    src = pkgs.fetchurl {
      url = "https://github.com/clonehero-game/releases/releases/download/v1.1.0.6142-final/Linux.x86_64-Standalone.tar";
      hash = "sha256-Vylx2TCSKDxdDVIAaia1Krjo+xKNz7QqNJbeJsiqIx0=";
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

      CLONE_HERO_BIN="$out/opt/clone-hero/Linux - Standalone/clonehero"

      if [ ! -f "$CLONE_HERO_BIN" ]; then
        echo "Could not find Clone Hero executable at expected path:"
        echo "$CLONE_HERO_BIN"
        echo
        echo "Files found:"
        find "$out/opt/clone-hero" -maxdepth 4 -type f
        exit 1
      fi

      chmod +x "$CLONE_HERO_BIN"

      cat > "$out/bin/clone-hero" <<EOF
#!${pkgs.bash}/bin/bash
unset LD_PRELOAD
exec ${pkgs.steam-run}/bin/steam-run "$CLONE_HERO_BIN" "\$@"
EOF

      chmod +x "$out/bin/clone-hero"

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
