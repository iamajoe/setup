from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
import os
import subprocess

# Mod key (Mod4 = Super/Windows key)
mod = "mod4"
terminal = "alacritty"

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
    Key([mod], "t", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Launch Rofi"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Run command"),
    Key([mod], "b", lazy.spawn("firefox"), desc="Launch browser"),
    
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
groups = [Group(i) for i in "123456789"]

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
    fontsize=12,
    padding=4,
    foreground=colors["fg"],
)

# Initialize and return the widget list for the top bar
def init_top_widget_list():
    return [
        # Workspace/group indicator - shows workspaces 1-9 and highlights active one
        widget.GroupBox(
            active=colors["blue"],
            inactive=colors["gray"],
            highlight_method="block",
            this_current_screen_border=colors["blue"],
            this_screen_border=colors["blue"],
            urgent_border=colors["red"],
            background=colors["bg"],
        ),
        # Command prompt - for running commands directly from the bar
        # widget.Prompt(),
        # Current window title - displays name of the focused window
        widget.WindowName(foreground=colors["blue"]),
        # Chord widget - shows active key chord mode
        # widget.Chord(
        #     chords_colors={
        #         "launch": (colors["red"], colors["fg"]),
        #     },
        #     name_transform=lambda name: name.upper(),
        # ),
        # Current layout name - shows which layout is active (Columns, Max, etc.)
        widget.CurrentLayout(foreground=colors["magenta"]),
        widget.Sep(foreground=colors["gray"], padding=10),
        # System tray - shows system tray icons (network, bluetooth, etc.)
        widget.Systray(),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Media player - displays currently playing music/video via MPRIS
        widget.Mpris2(
            format=" {xesam:title} - {xesam:artist}",
            foreground=colors["magenta"],
            max_chars=30,
            scroll_chars=None,
            stop_pause_text="",
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # CPU usage - shows current CPU load percentage
        # widget.CPU(format="  {load_percent}%", foreground=colors["green"]),
        # widget.Sep(foreground=colors["gray"], padding=10),
        # Temperature sensor - displays CPU/system temperature
        # widget.ThermalSensor(
        #     format=" {temp:.0f}°C",
        #     foreground=colors["red"],
        # ),
        # widget.Sep(foreground=colors["gray"], padding=10),
        # Memory usage - shows RAM usage in MB
        # widget.Memory(format="  {MemUsed:.0f}M", foreground=colors["yellow"]),
        # widget.Sep(foreground=colors["gray"], padding=10),
        # Disk free space - shows available space on root partition
        # widget.DF(
        #     format=" {f}GB",
        #     visible_on_warn=False,
        #     foreground=colors["yellow"],
        #     partition="/",
        # ),
        # widget.Sep(foreground=colors["gray"], padding=10),
        # Network speed - displays download/upload speeds
        # widget.Net(
        #     format=" {down:.0f}{down_suffix} ↓↑ {up:.0f}{up_suffix}",
        #     foreground=colors["cyan"],
        # ),
        # widget.Sep(foreground=colors["gray"], padding=10),
        # Bluetooth status - shows bluetooth info, click to open manager
        widget.Bluetooth(
            fmt="  {}",
            foreground=colors["blue"],
            mouse_callbacks={"Button1": lazy.spawn("blueman-manager")},
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Screen brightness - displays current backlight level (laptops)
        widget.Backlight(
            format=" {percent:2.0%}",
            foreground=colors["yellow"],
            backlight_name="intel_backlight",
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Battery level - shows battery percentage and charging status (laptops)
        widget.Battery(
            format="{char} {percent:2.0%}",
            charge_char="",
            discharge_char="",
            full_char="",
            foreground=colors["green"],
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Keyboard layout - displays current keyboard layout (us, pt, etc.)
        widget.KeyboardLayout(
            configured_keyboards=["us", "pt"],
            foreground=colors["cyan"],
            fmt=" {}",
        ),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Volume - shows current audio volume level
        widget.Volume(fmt="  {}", foreground=colors["magenta"]),
        widget.Sep(foreground=colors["gray"], padding=10),
        # Clock - displays date and time
        widget.Clock(format="  %Y-%m-%d %H:%M", foreground=colors["cyan"]),
        # widget.Sep(foreground=colors["gray"], padding=10),
        # Quick exit button - click to logout/shutdown
        # widget.QuickExit(default_text="⏻", foreground=colors["red"]),
    ]

# Top bar
screens = [
    Screen(
        top=bar.Bar(
            init_top_widget_list(),
            24,
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
auto_minimize = True
wl_input_rules = None
wmname = "LG3D"

# Autostart
@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.Popen([home])
