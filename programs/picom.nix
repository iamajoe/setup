{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;

    fade = true;
    fadeSteps = [ 0.03 0.03 ];
    fadeDelta = 10;

    shadow = true;
    shadowOpacity = 0.75;
    shadowOffsets = [ (-15) (-15) ];
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
    ];

    settings = {
      # Rounded corners
      corner-radius = 10;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      # Opacity rules
      inactive-opacity = 0.95;
      active-opacity = 1.0;
      frame-opacity = 0.9;

      # Blur
      blur-method = "dual_kawase";
      blur-strength = 5;
      blur-background = true;
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      # Performance
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      log-level = "warn";
    };
  };
}
