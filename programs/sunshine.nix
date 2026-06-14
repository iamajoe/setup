# TODO: this is the old home-manager

# { config, pkgs, buildEnv, lib, ... }:

# let
#   username = buildEnv.username;
#   homeDir = config.home.homeDirectory;

#   sunshineApps = {
#     env = {
#       PATH = "$(PATH):$(HOME)/.local/bin";
#     };

#     apps = [
#       {
#         name = "Desktop";
#         image-path = "desktop.png";
#       }

#       {
#         name = "Steam";
#         image-path = "steam.png";

#         # Keep this empty because Steam relaunches / detaches itself.
#         cmd = "";

#         detached = [
#           "xrandr --output DP-2 --mode 1920x1080 --rate 60"
#           "setsid steam steam://open/bigpicture"
#         ];

#         prep-cmd = [
#           {
#             do = "qtile cmd-obj -o group 6 -f toscreen";
#             undo = "setsid steam steam://close/bigpicture; xrandr --output DP-2 --auto";
#           }
#         ];

#         auto-detach = true;
#         wait-all = true;
#         exit-timeout = 5;
#         exclude-global-prep-cmd = false;
#       }
#     ];
#   };

# in
# {
#   home.packages = with pkgs; [
#     sunshine
#   ];

#   home.file.".config/sunshine/apps.json".text =
#     builtins.toJSON sunshineApps;

#   systemd.user.services.sunshine = {
#     Unit = {
#       Description = "Sunshine Game Streaming Host";
#       After = [ "graphical-session.target" ];
#       PartOf = [ "graphical-session.target" ];
#     };

#     Service = {
#       ExecStart = "${pkgs.sunshine}/bin/sunshine";
#       Restart = "on-failure";
#       RestartSec = 5;

#       Environment = [
#         "DISPLAY=:0"
#         "XAUTHORITY=${homeDir}/.Xauthority"
#         "XDG_RUNTIME_DIR=/run/user/%U"
#         # "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
#         # "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
#         "PATH=${homeDir}/.local/bin:/run/current-system/sw/bin:${config.home.profileDirectory}/bin"
#       ];
#     };

#     Install = {
#       WantedBy = [ "graphical-session.target" ];
#     };
#   };
# }
