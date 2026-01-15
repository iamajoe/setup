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

      # Disable opacity for better performance
      # Steam and other GPU-intensive apps are very slow with opacity
      inactive-opacity = 1.0;   # No transparency for better performance
      active-opacity = 1.0;     # No transparency
      frame-opacity = 1.0;      # No transparency for borders

      blur-background = false;

      # Performance optimizations
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      log-level = "warn";
      
      # Additional performance settings
      unredir-if-possible = true;  # Disable compositor for fullscreen windows
      glx-no-stencil = true;
      glx-no-rebind-pixmap = true;
    };
  };
}
