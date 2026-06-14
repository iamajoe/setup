{ config, pkgs, lib, userConfig, ... }:

let
  isX86_64 = userConfig.system == "x86_64-linux";
in
{
  # ─── AUDIO ───────────────────────────────────────────────────────────
  # PipeWire (modern audio, replaces PulseAudio + JACK)
  security.rtkit.enable = true; # realtime scheduling for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = isX86_64; # Only on x86_64
    pulse.enable = true; # PulseAudio compatibility
    jack.enable = true; # JACK compatibility
  };
}

