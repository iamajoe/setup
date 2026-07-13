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

  # Force audio output to the HDMI card if audio doesn't default there on
  # its own (TV setups). Find the right card name with `pactl list cards short`
  # and swap it into the grep below, then uncomment.
  systemd.user.services.force-hdmi-audio = {
    description = "Force HDMI audio profile";
    wantedBy = [ "default.target" ];
    after = [ "pipewire.service" "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellScript "force-hdmi-audio" ''
          CARD="$( ${pkgs.pulseaudio}/bin/pactl list cards short | ${pkgs.gnugrep}/bin/grep 'alsa_card.pci-XXXX_XX_XX.X' | ${pkgs.coreutils}/bin/cut -f1 )"
          [ -n "$CARD" ] && exec ${pkgs.pulseaudio}/bin/pactl set-card-profile "$CARD" output:hdmi-stereo
        '';
      in "${script}";
    };
  };
}

