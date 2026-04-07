from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown, Rule
from libqtile.lazy import lazy
from qtile_extras import widget as widget_extras
from qtile_extras.widget.decorations import RectDecoration
import os
import subprocess

# Import bar configuration
from bar_minimal import create_bar  # Minimal bar - centered, rounded, essential widgets only

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
    Key([mod, "shift"], "m", lazy.group.unminimize_all(),
        desc="Restore all minimized windows in current group"),

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
groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend([
        # Switch to workspace
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
        # Move window to workspace
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True), desc=f"Move focused window to group {i.name}"),
    ])

dgroups_app_rules = [
    Rule(Match(wm_class=terminal), group="1"),
    Rule(Match(wm_class=browser), group="2"),
    Rule(Match(wm_class="google-chrome"), group="3"),
    Rule(Match(wm_class="spotify"), group="8"),
    Rule(Match(wm_class="discord"), group="8"),
    Rule(Match(wm_class="slack"), group="8"),
    Rule(Match(wm_class="steam"), group="9"),
]

########################
# SCRATCHPAD
########################
groups.append(
    ScratchPad("scratchpad", [
        DropDown('mixer', 'pavucontrol', width=0.4, height=0.6, x=0.3, y=0.2, opacity=1),
        DropDown('term', terminal, width=0.4, height=0.6, x=0.3, y=0.2, opacity=1),
        # Qtile shortcuts cheatsheet
        DropDown(
            "shortcuts",
            f"{terminal} -e less -R {os.path.expanduser('~/.config/qtile/shortcuts.txt')}",
            width=0.6,
            height=0.7,
            x=0.2,
            y=0.15,
            opacity=0.95,
            on_focus_lost_hide=True
        ),
        # Keyboard layout overlay
        DropDown(
            "keyboard",
            f"{terminal} -e less -R {os.path.expanduser('~/.config/qtile/keyboard-layout.txt')}",
            width=0.8,
            height=0.8,
            x=0.1,
            y=0.1,
            opacity=0.95,
            on_focus_lost_hide=True
        ),
    ])
)

# Add keybindings for scratchpads
keys.extend([
    Key([mod, "control"], "s", lazy.group["scratchpad"].dropdown_toggle("mixer"), desc="Sound board overlay"),
    Key([mod, "control"], "t", lazy.group["scratchpad"].dropdown_toggle("term"), desc="Terminal overlay"),
    Key([mod, "control"], "1", lazy.group["scratchpad"].dropdown_toggle("shortcuts"), desc="Toggle shortcuts overlay"),
    Key([mod, "control"], "2", lazy.group["scratchpad"].dropdown_toggle("keyboard"), desc="Toggle keyboard layout overlay"),
])

########################
# SCREENS
########################
screens = [
    Screen(
        top=create_bar(colors, terminal, browser),
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
