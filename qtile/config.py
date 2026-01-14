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

########################
# THEME / COLORS
########################
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

    "white": "#ffffff",
}

########################
# KEYBOARD SHORTCUTS / MOUSE
########################
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

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

########################
# WORKSPACES/GROUPS
########################
# groups = [Group(i) for i in "123456789"]
groups = [Group(i) for i in "12345"]

for i in groups:
    keys.extend([
        # Switch to workspace
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
        # Move window to workspace
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True), desc=f"Move focused window to group {i.name}"),
    ])

########################
# TOP BAR
########################
widget_defaults = dict(
    font="NotoSansM Nerd Font",
    fontsize=20,
    padding=12,
    foreground=colors["fg"],
)

# Initialize and return the widget list for the top bar
def init_top_widget_list():
    return [
        # Workspace/group indicator - shows workspaces 1-9 and highlights active one
        widget.GroupBox(
            active=colors["cyan"],
            inactive=colors["gray"],
            highlight_method="line",
            this_current_screen_border=colors["yellow"],
            this_screen_border=colors["yellow"],
            other_current_screen_border=colors["yellow"],
            other_screen_border=colors["yellow"],
            urgent_border=colors["red"],
            background=colors["bg"],
            disable_drag=True,
            use_mouse_wheel=False,
            block_highlight_text_color=colors["white"],  # Dark text on yellow background
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
             foreground = colors["gray"],  # Gray icons by default
             # Tooltip configuration
             tooltip_delay = 0.5,  # Show tooltip after 0.5 seconds
             tooltip_background = colors["bg"],
             tooltip_foreground = colors["fg"],
        ),
        # Task list - shows all open windows with icons to help with positioning
        widget.TaskList(
            highlight_method="block",
            icon_size=18,
            font_size=10,
            max_title_width=200,
            border=colors["gray"],
            borderwidth=2,
            background=colors["bg"],
            foreground=colors["fg"],
            txt_floating=" 󰉈 ",
            txt_maximized=" 󰊓 ",
            txt_minimized=" 󰖰 ",
            urgent_alert_method="border",
            urgent_border=colors["red"],
            rounded=False,
        ),
        # Automatic layout-specific icons:
        widget_extras.CurrentLayoutIcon(
            use_mask=True,  # Allows the icon to be colored
            foreground=colors["cyan"],
            scale=0.5,
            padding=8,
        ),
        # Bluetooth status - shows bluetooth state and connected devices
        widget_extras.Bluetooth(
            foreground=colors["blue"],
            fmt="{}",  # Just show the content without duplicating icons
            default_text="󰂲",  # Bluetooth off icon (crossed out)
            symbol="󰂯 ",  # Bluetooth on icon (shown before device name)
            default_show_battery=True,
            battery_format="{battery}%",
            adapter_paths=["/org/bluez/hci0"],  # Default bluetooth adapter
            mouse_callbacks={"Button1": lazy.spawn("blueman-manager")},
        ),
        # System tray - shows system tray icons (network, bluetooth, etc.)
        # Old version (standard Systray without filtering):
        # widget.Systray(
        #     icon_size=24,
        #     padding=8,
        # ),
        # New version (qtile-extras StatusNotifier with filtering):
        widget_extras.StatusNotifier(
            icon_size=28,
            padding=8,
            # Filter out blueman-applet since we have dedicated Bluetooth widget
            # Also commonly filter: nm-applet (if using dedicated network widget)
            icon_theme="Adwaita",
            menu_font="NotoSansM Nerd Font",
            menu_fontsize=16,
        ),
        # Media player - displays currently playing music/video via MPRIS
        widget.Mpris2(
            format="{xesam:title} - {xesam:artist}",
            foreground=colors["magenta"],
            max_chars=40,
            scroll=True,
            scroll_interval=0.5,
            scroll_delay=2,
            scroll_repeat=True,
            paused_text="󰏤 {track}",
            playing_text="󰐊 {track}",
            stopped_text="󰓛",
            mouse_callbacks={
                "Button1": lazy.spawn("playerctl play-pause"),
                "Button3": lazy.spawn("playerctl next"),
                "Button2": lazy.spawn("playerctl previous"),
            },
        ),
        widget.Volume(
            fmt="{}",
            foreground=colors["yellow"],
            mouse_callbacks={
                "Button1": lazy.spawn("pavucontrol"),
                "Button3": lazy.spawn("pamixer --toggle-mute"),
            },
            # mute_command="pamixer --toggle-mute",
            # volume_up_command="pamixer -i 5",
            # volume_down_command="pamixer -d 5",
            # get_volume_command="pamixer --get-volume-human",
            # update_interval=0.2,
            unmute_format="󰕾 {}%",
            mute_format="󰖁",
        ),
        widget.KeyboardLayout(
            configured_keyboards=["us", "pt"],
            foreground=colors["cyan"],
            fmt="󰌌 {}",
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        widget.Clock(format="%d-%m-%Y %H:%M", foreground=colors["gray"]),
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

########################
# LAYOUTS
########################
layouts = [
    layout.Columns(
        border_focus=colors["yellow"],
        border_normal=colors["gray"],
        border_width=2,
        margin=4,
    ),
    layout.Max(),
    # layout.Floating(
    #     border_focus=colors["yellow"],
    #     border_normal=colors["gray"],
    #     border_width=2,
    # ),
]

floating_layout = layout.Floating(
    border_focus=colors["yellow"],
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

########################
# GENERAL
########################

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

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
