{ config, pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username homeDir;

  emulationDir = "${homeDir}/emulation";
  romsDir = "${emulationDir}/roms";
  biosDir = "${emulationDir}/bios";
  savesDir = "${emulationDir}/saves";
  statesDir = "${emulationDir}/states";
  steamShortcutsDir = "${homeDir}/SteamShortcuts";

  retroarchCfg = pkgs.replaceVars ../templates/emulation/retroarch.cfg {
    emulationDir = emulationDir;
    savesDir = savesDir;
    statesDir = statesDir;
    biosDir = biosDir;
  };
  esDeSh = pkgs.replaceVars ../templates/emulation/es-de.sh {
    steamShortcutsDir = steamShortcutsDir;
    biosDir = biosDir;
    romsDir = romsDir;
  };

  # ES-DE uses specific system folder names. These are safe/common names.
  romFolders = [
    # Nintendo
    "nes"
    "snes"
    "gb"
    "gbc"
    "gba"
    "n64"
    "nds"
    "gamecube"
    "wii"

    # Sega
    "mastersystem"
    "megadrive"
    "genesis"
    "segacd"
    "dreamcast"

    # Sony
    "psx"
    "ps2"
    "psp"

    # Other common systems
    "dos"
    "arcade"
    "mame"
    "neogeo"
    "pcengine"
    "tg16"
  ];

  mkdirRomFolders = lib.concatMapStringsSep "\n" (folder: ''
    mkdir -p "${romsDir}/${folder}"
  '') romFolders;
in
{
  environment.systemPackages = with pkgs; [
    # Frontend
    emulationstation-de

    # Multi-system emulator backend.
    # Good for NES, SNES, GB, GBC, GBA, Mega Drive, arcade, etc.
    retroarch-full

    # Standalone emulators for systems where standalone is usually nicer.
    dosbox-staging
    duckstation
    pcsx2
    ppsspp
    dolphin-emu
    flycast
    melonDS
    mgba

    # Useful tools
    unzip
    p7zip
    xdg-utils
  ];

  # Helpful for many gamepads.
  hardware.xpadneo.enable = true;

  system.activationScripts.emulationSetup = ''
    set -e

    mkdir -p "${emulationDir}"
    mkdir -p "${romsDir}"
    mkdir -p "${biosDir}"
    mkdir -p "${savesDir}"
    mkdir -p "${statesDir}"
    mkdir -p "${steamShortcutsDir}"
    mkdir -p "${homeDir}/.config/retroarch"

    install -m 0644 -o ${username} -g users ${retroarchCfg} ${homeDir}/.config/retroarch/retroarch.cfg
    install -m 0644 -o ${username} -g users ${esDeSh} ${steamShortcutsDir}/es-de.sh
    chmod +x "${steamShortcutsDir}/es-de.sh"

    ${mkdirRomFolders}

    # ES-DE commonly looks for ~/ROMs. Keep your real folder at ~/emulation/roms.
    if [ ! -e "${homeDir}/ROMs" ]; then
      ln -s "${romsDir}" "${homeDir}/ROMs"
    fi

    # Small helper to launch RetroArch directly if you ever need to debug it.
    cat > "${steamShortcutsDir}/retroarch.sh" <<'EOF'
#!/usr/bin/env bash
set -e

LOG="${steamShortcutsDir}/retroarch.log"

echo "Launching RetroArch" > "$LOG"
echo "Date: $(date)" >> "$LOG"

unset LD_PRELOAD
exec retroarch >> "$LOG" 2>&1
EOF

    chmod +x "${steamShortcutsDir}/retroarch.sh"

    chown -R ${username}:users "${emulationDir}"
    chown -h ${username}:users "${homeDir}/ROMs" || true
    chown -R ${username}:users "${steamShortcutsDir}"
    chown -R ${username}:users "${homeDir}/.config/retroarch"
  '';
}
