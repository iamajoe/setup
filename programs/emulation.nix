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
    savesDir = savesDir;
    statesDir = statesDir;
    biosDir = biosDir;
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
    # AppImage support (for example for ES-DE)
    appimage-run
    fuse
    fuse3
    curl
    cacert
    python3

    # RetroArch with selected cores only.
    # Avoid retroarch-full because it currently pulls broken libretro-fbalpha2012.
    (retroarch.withCores (cores: with cores; [
      # Nintendo
      fceumm
      snes9x
      gambatte
      mgba
      mupen64plus
      melonds

      # Sega
      genesis-plus-gx
      flycast

      # Sony
      beetle-psx
      beetle-psx-hw
      swanstation
      ppsspp

      # Arcade / Neo Geo
      fbneo
      mame

      # PC Engine / TurboGrafx-16
      beetle-pce-fast

      pcsx2
    ]))

    # Standalone emulators
    dosbox-staging
    # duckstation removed from nixpkgs upstream (use the AppImage if needed);
    # PS1 is still covered via the beetle-psx-hw RetroArch core above.
    pcsx2
    ppsspp
    dolphin-emu
    flycast
    melonds
    mgba

    # Useful tools
    unzip
    p7zip
    xdg-utils
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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

    # PS2 is a special case for the bios
    mkdir -p ${homeDir}/.config/PCSX2/bios

    ${mkdirRomFolders}

    # ES-DE commonly looks for ~/ROMs. Keep your real folder at ~/emulation/roms.
    if [ ! -e "${homeDir}/ROMs" ]; then
      ln -s "${romsDir}" "${homeDir}/ROMs"
    fi

    chown -R ${username}:users "${emulationDir}"
    chown -h ${username}:users "${homeDir}/ROMs" || true
    chown -R ${username}:users "${steamShortcutsDir}"
    chown -R ${username}:users "${homeDir}/.config/retroarch"
  '';
}
