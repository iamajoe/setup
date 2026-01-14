{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;  # Prevent screen tearing

    # Disable all animations and effects
    fade = false;
    shadow = false;

    settings = {
      corner-radius = 5;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      # Opacity: inactive windows slightly transparent
      inactive-opacity = 0.8;   # 80% opacity for inactive windows
      active-opacity = 1.0;     # 100% opacity for active window
      frame-opacity = 0.75;     # 75% opacity for window borders/decorations

      blur-background = false;

      # Performance optimizations
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
