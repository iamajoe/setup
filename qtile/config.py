from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
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
    "darker_gray_cyan": "#2D3D3A",
    "darker_gray": "#2F313B",
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

    # Media controls
    # Volume controls (media keys)
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pamixer -i 5"), desc="Volume up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pamixer -d 5"), desc="Volume down"),
    Key([], "XF86AudioMute", lazy.spawn("pamixer --toggle-mute"), desc="Toggle mute"),
    # Volume controls (alternative keybindings)
    Key([mod, "shift"], "p", lazy.spawn("pamixer -i 5"), desc="Volume up"),
    Key([mod, "shift"], "o", lazy.spawn("pamixer -d 5"), desc="Volume down"),
    Key([mod, "shift"], "0", lazy.spawn("pamixer --toggle-mute"), desc="Toggle mute"),

    # Media player controls (media keys)
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/Pause"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Next track"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Previous track"),
    # Media player controls (alternative keybindings)
    Key([mod, "shift"], "i", lazy.spawn("playerctl play-pause"), desc="Play/Pause"),
    Key([mod, "shift"], "u", lazy.spawn("playerctl next"), desc="Next track"),
    Key([mod, "shift"], "y", lazy.spawn("playerctl previous"), desc="Previous track"),

    # Toggle between different layouts
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),

    # Window controls
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key([mod], "g", lazy.window.toggle_floating(), desc="Toggle floating"),

    # Qtile controls
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
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

# Scratchpad for help overlays
groups.append(
    ScratchPad("scratchpad", [
        # Qtile shortcuts cheatsheet
        DropDown(
            "shortcuts",
            f"{terminal} -e less -R ~/.config/qtile/shortcuts.txt",
            width=0.6,
            height=0.7,
            x=0.2,
            y=0.15,
            opacity=0.95,
        ),
        # Keyboard layout overlay
        DropDown(
            "keyboard",
            f"{terminal} -e less -R ~/.config/qtile/keyboard-layout.txt",
            width=0.8,
            height=0.8,
            x=0.1,
            y=0.1,
            opacity=0.95,
        ),
    ])
)

# Add keybindings for scratchpads
keys.extend([
    Key([mod, "control"], "1", lazy.group["scratchpad"].dropdown_toggle("shortcuts"), desc="Toggle shortcuts overlay"),
    Key([mod, "control"], "2", lazy.group["scratchpad"].dropdown_toggle("keyboard"), desc="Toggle keyboard layout overlay"),
])

########################
# TOP BAR
########################
widget_defaults = dict(
    font="NotoSansM Nerd Font",
    fontsize=22,
    padding=12,
    foreground=colors["fg"],
)

# Initialize and return the widget list for the top bar
def init_top_widget_list():
    return [
        # Workspace/group indicator - shows workspaces 1-9 and highlights active one
        widget.GroupBox(
            active=colors["white"],
            inactive=colors["gray"],
            highlight_method="line",
            this_current_screen_border=colors["magenta"],
            this_screen_border=colors["magenta"],
            other_current_screen_border=colors["magenta"],
            other_screen_border=colors["magenta"],
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
            fontsize=18,
            margin_y=0,
            max_title_width=300,
            border=colors["darker_gray"],
            # borderwidth=2,
            background=colors["bg"],
            foreground=colors["fg"],
            txt_floating=" 󰉈 ",
            txt_maximized=" 󰊓 ",
            txt_minimized=" 󰖰 ",
            urgent_alert_method="border",
            urgent_border=colors["red"],
            rounded=False,
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
            get_volume_command="pamixer --get-volume",
            check_mute_command="pamixer --get-mute",
            check_mute_string="true",
            update_interval=0.2,
            unmute_format="󰕾 {}%",
            # TODO: mute not working out
            # mute_format="󰖁",
            mute_format="󰕾",
        ),
        # Media player - displays currently playing music/video via MPRIS
        widget.Mpris2(
            format="{xesam:artist} - {xesam:title}",
            foreground=colors["yellow"],
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
        widget.Sep(foreground=colors["gray"], padding=10),
        # Bluetooth status - shows bluetooth state and connected devices
        # widget_extras.Bluetooth(
        #     foreground=colors["blue"],
        #     fmt="{}",  # Just show the content without duplicating icons
        #     default_text="󰂲",  # Bluetooth off icon (crossed out)
        #     symbol="󰂯 ",  # Bluetooth on icon (shown before device name)
        #     default_show_battery=True,
        #     battery_format="{battery}%",
        #     adapter_paths=["/org/bluez/hci0"],  # Default bluetooth adapter
        #     mouse_callbacks={"Button1": lazy.spawn("blueman-manager")},
        # ),
        # System tray - shows system tray icons (network, bluetooth, etc.)
        # Old version (standard Systray without filtering):
        widget.Systray(
            icon_size=20,
            padding=8,
        ),
        # New version (qtile-extras StatusNotifier with filtering):
        widget_extras.StatusNotifier(
            icon_size=22,
            padding=8,
            # Filter out blueman-applet since we have dedicated Bluetooth widget
            # Also commonly filter: nm-applet (if using dedicated network widget)
            icon_theme="Adwaita",
            menu_font="NotoSansM Nerd Font",
            menu_fontsize=16,
        ),
        widget.KeyboardLayout(
            configured_keyboards=["us", "pt"],
            foreground=colors["yellow"],
            fmt="󰌌 {}",
            fontsize=20,
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Automatic layout-specific icons:
        widget_extras.CurrentLayoutIcon(
            use_mask=True,  # Allows the icon to be colored
            foreground=colors["yellow"],
            scale=0.4,
            padding=8,
        ),
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
follow_mouse_focus = False
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
