from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from qtile_extras import widget as widget_extras
from qtile_extras.widget.decorations import RectDecoration
import os
import subprocess

# It can be a good reference:
# - https://gitlab.com/dwt1/dotfiles/-/blob/master/.config/qtile/config.py

# Mod key (Mod4 = Super/Windows key)
mod = "mod4"
terminal = "alacritty"
browser = "firefox"

keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),

    # Applications
    Key([mod], "e", lazy.spawn("thunar"), desc="Launch file manager"),
    Key([mod], "t", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "b", lazy.spawn(browser), desc="Launch browser"),
    
    # Rofi
    Key([mod], "d", lazy.spawn("rofi -show drun -show-icons"), desc="Launch Rofi"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Run command"),
    Key([mod], "v", lazy.spawn("clipmenu"), desc="Clipboard history"),
    Key([mod], "p", lazy.spawn("rofi -show window"), desc="Window switcher"),
    Key([mod, "shift"], "s", lazy.spawn("rofi-web-search"), desc="Web search"),
    Key([mod, "shift"], "n", lazy.spawn("rofi-quick-notes"), desc="Quick notes"),

    # Screenshots
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Screenshot with selection"),
    Key([mod], "s", lazy.spawn("flameshot gui"), desc="Screenshot with selection"),

    # Toggle between different layouts
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),

    # Window controls
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key([mod], "g", lazy.window.toggle_floating(), desc="Toggle floating"),

    # Qtile controls
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    # Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
]

# Workspaces/Groups
# groups = [Group(i) for i in "123456789"]
groups = [Group(i) for i in "12345"]

for i in groups:
    keys.extend([
        # Switch to workspace
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
        # Move window to workspace
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True), desc=f"Move focused window to group {i.name}"),
    ])

# Catppuccin Mocha colors
colors = {
    "bg": "#1e1e2e",
    "fg": "#cdd6f4",
    "blue": "#89b4fa",
    "red": "#f38ba8",
    "green": "#a6e3a1",
    "yellow": "#f9e2af",
    "magenta": "#f5c2e7",
    "cyan": "#94e2d5",
    "gray": "#6c7086",
}

# Layouts
layouts = [
    layout.Columns(
        border_focus=colors["blue"],
        border_normal=colors["gray"],
        border_width=2,
        margin=8,
    ),
    layout.Max(),
    layout.Floating(
        border_focus=colors["blue"],
        border_normal=colors["gray"],
        border_width=2,
    ),
]

widget_defaults = dict(
    font="NotoSansM Nerd Font",
    fontsize=24,  # Increased for HiDPI
    padding=8,    # Increased for HiDPI
    foreground=colors["fg"],
)

# Initialize and return the widget list for the top bar
def init_top_widget_list():
    return [
        # Workspace/group indicator - shows workspaces 1-9 and highlights active one
        widget.GroupBox(
            active=colors["blue"],
            inactive=colors["gray"],
            highlight_method="line",
            this_current_screen_border=colors["blue"],
            this_screen_border=colors["blue"],
            urgent_border=colors["red"],
            background=colors["bg"],
            disable_drag=True,
            use_mouse_wheel=False,
            # Show window count indicators
            block_highlight_text_color=colors["fg"],
            rounded=False,
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Setup a launch bar
        widget.LaunchBar(
             progs = [("󰈹", browser, "Web browser"),
                      ("󰊯", "google-chrome-stable", "Google Chrome"),
                      ("󰆍", terminal, "Terminal"),
                      ("󰉋", "thunar", "File manager"),
                      ("󰝚", "tidal-hifi", "Media player"),
                      ("󰙯", "discord", "Discord"),
                      ("󰒱", "slack", "Slack"),
                      ("󰆼", "mongodb-compass", "MongoDB Compass"),
                      ("󰓓", "steam", "Steam")
                     ], 
             fontsize = 24,
             padding = 8,
             foreground = colors["blue"],
             # Tooltip configuration
             tooltip_delay = 0.5,  # Show tooltip after 0.5 seconds
             tooltip_background = colors["bg"],
             tooltip_foreground = colors["fg"],
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Task list - shows all open windows with icons to help with positioning
        widget.TaskList(
            highlight_method="block",
            icon_size=22,
            max_title_width=200,
            border=colors["blue"],
            borderwidth=2,
            background=colors["bg"],
            foreground=colors["fg"],
            txt_floating="󰉈 ",
            txt_maximized="󰊓 ",
            txt_minimized="󰖰 ",
            urgent_alert_method="border",
            urgent_border=colors["red"],
        ),
        # Chord widget - shows active key chord mode
        # widget.Chord(
        #     chords_colors={
        #         "launch": (colors["red"], colors["fg"]),
        #     },
        #     name_transform=lambda name: name.upper(),
        # ),
        # Current layout name - shows which layout is active (Columns, Max, etc.)
        # Old version with static icon:
        # widget.CurrentLayout(
        #     foreground=colors["magenta"],
        #     fmt="󱕍 {}",  # Layout icon
        # ),
        # New version with automatic layout-specific icons:
        widget_extras.CurrentLayoutIcon(
            foreground=colors["magenta"],
            scale=0.9,
            padding=8,
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Bluetooth status - shows bluetooth state and connected devices
        widget_extras.Bluetooth(
            foreground=colors["blue"],
            fmt="󰂯 {}",
            default_text="Off",
            default_show_battery=True,
            battery_format="{battery}%",
            adapter_paths=["/org/bluez/hci0"],  # Default bluetooth adapter
            mouse_callbacks={"Button1": lazy.spawn("blueman-manager")},
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Syncthing status - shows sync status and progress
        widget_extras.Syncthing(
            foreground=colors["green"],
            path="http://localhost:8384",
            label="",
            update_interval=5,
            error_colour=colors["red"],
            active_colour=colors["blue"],
            inactive_colour=colors["green"],
            mouse_callbacks={"Button1": lazy.spawn("firefox http://localhost:8384")},
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # System tray - shows system tray icons (network, bluetooth, etc.)
        # Old version (standard Systray without filtering):
        # widget.Systray(
        #     icon_size=24,  # Larger icons for HiDPI
        #     padding=8,
        # ),
        # New version (qtile-extras StatusNotifier with filtering):
        widget_extras.StatusNotifier(
            icon_size=28,  # Larger icons for HiDPI
            padding=8,
            # Filter out blueman-applet since we have dedicated Bluetooth widget
            # Also commonly filter: nm-applet (if using dedicated network widget)
            icon_theme="Adwaita",
            menu_font="NotoSansM Nerd Font",
            menu_fontsize=16,
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Media player - displays currently playing music/video via MPRIS
        # Old version (standard Mpris2):
        # widget.Mpris2(
        #     format="{xesam:title} - {xesam:artist}",
        #     foreground=colors["magenta"],
        #     max_chars=40,
        #     scroll=True,
        #     scroll_interval=0.5,
        #     scroll_delay=2,
        #     scroll_repeat=True,
        #     paused_text="󰏤 {track}",
        #     playing_text="󰐊 {track}",
        #     stopped_text="󰓛",
        #     mouse_callbacks={
        #         "Button1": lazy.spawn("playerctl play-pause"),
        #         "Button3": lazy.spawn("playerctl next"),
        #         "Button2": lazy.spawn("playerctl previous"),
        #     },
        # ),
        # New version (qtile-extras Mpris2 with progress bar and decorations):
        widget_extras.Mpris2(
            foreground=colors["magenta"],
            playing_text="󰐊 {track} - {length}",
            paused_text="󰏤 {track} - {length}",
            stopped_text="󰓛 No media playing",
            max_chars=50,
            scroll=True,
            scroll_interval=0.5,
            scroll_repeat=True,
            scroll_delay=2,
            name="mpris2",
            objname="org.mpris.MediaPlayer2.playerctld",
            display_metadata=["xesam:title", "xesam:artist"],
            mouse_callbacks={
                "Button1": lazy.spawn("playerctl play-pause"),
                "Button3": lazy.spawn("playerctl next"),
                "Button2": lazy.spawn("playerctl previous"),
            },
            decorations=[
                RectDecoration(
                    colour=colors["bg"],
                    radius=6,
                    filled=True,
                    padding_y=4,
                    padding_x=6,
                )
            ],
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Screen brightness - displays current backlight level (laptops)
        # widget.Backlight(
        #     format=" {percent:2.0%}",
        #     foreground=colors["yellow"],
        #     backlight_name="intel_backlight",
        # ),
        # Battery level - shows battery percentage and charging status (laptops)
        # widget.Battery(
        #     format="{char} {percent:2.0%}",
        #     charge_char="",
        #     discharge_char="",
        #     full_char="",
        #     foreground=colors["green"],
        # ),
        widget.KeyboardLayout(
            configured_keyboards=["us", "pt"],
            foreground=colors["cyan"],
            fmt="󰌌 {}",  # Nerd Font keyboard icon
        ),
        # Old volume widget (text-based):
        # widget.Volume(
        #     fmt="󰕾 {}",  # Nerd Font speaker icon
        #     foreground=colors["magenta"],
        #     mouse_callbacks={"Button1": lazy.spawn("pavucontrol")},
        #     mute_command="pamixer --toggle-mute",
        #     volume_up_command="pamixer -i 5",
        #     volume_down_command="pamixer -d 5",
        #     get_volume_command="pamixer --get-volume-human",
        #     update_interval=0.2,
        #     unmute_format="{}%",
        #     mute_format="󰖁 M",
        # ),
        # New volume widget with visual bar:
        widget_extras.PulseVolumeExtra(
            foreground=colors["magenta"],
            limit_max_volume=True,
            mouse_callbacks={"Button1": lazy.spawn("pavucontrol")},
            emoji=True,
            emoji_list=["󰖁", "󰕿", "󰖀", "󰕾"],
            volume_app="pavucontrol",
            update_interval=0.2,
            bar_colour=colors["magenta"],
            bar_width=60,
        ),
        widget.Clock(format="  %Y-%m-%d %H:%M", foreground=colors["cyan"]),
    ]

# Top bar
screens = [
    Screen(
        top=bar.Bar(
            init_top_widget_list(),
            48,
            background=colors["bg"],
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

floating_layout = layout.Floating(
    border_focus=colors["blue"],
    border_normal=colors["gray"],
    border_width=2,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ],
)

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

# Autostart
@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.Popen([home])
