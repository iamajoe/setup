# ~/.config/qtile/config.py
from __future__ import annotations

import os
import subprocess
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod4"  # Super key


def pick_terminal() -> str:
    preferred = os.environ.get("TERMINAL")
    for t in (preferred, "alacritty", "kitty", "wezterm", "foot", "xterm"):
        if not t:
            continue
        if subprocess.call(["sh", "-lc", f"command -v {t} >/dev/null 2>&1"]) == 0:
            return t
    return "xterm"


terminal = pick_terminal()

keys = [
    # Apps / qtile
    Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "r", lazy.spawn("rofi -show drun"), desc="Launcher (rofi)"),
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Quit qtile"),

    # Focus (vim keys)
    Key([mod], "h", lazy.layout.left(), desc="Focus left"),
    Key([mod], "j", lazy.layout.down(), desc="Focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Focus up"),
    Key([mod], "l", lazy.layout.right(), desc="Focus right"),
    Key([mod], "space", lazy.layout.next(), desc="Focus next window"),

    # Move windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move left"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move up"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move right"),

    # Resize (MonadTall)
    Key([mod], "equal", lazy.layout.grow(), desc="Grow"),
    Key([mod], "minus", lazy.layout.shrink(), desc="Shrink"),

    # Layout / window states
    Key([mod], "Tab", lazy.next_layout(), desc="Next layout"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Fullscreen"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating"),
]

# Workspaces
group_names = [str(i) for i in range(1, 10)]
groups = [Group(name) for name in group_names]

for g in groups:
    keys.extend([
        Key([mod], g.name, lazy.group[g.name].toscreen(), desc=f"Go to {g.name}"),
        Key([mod, "shift"], g.name, lazy.window.togroup(g.name), desc=f"Move to {g.name}"),
    ])

# Layouts
layouts = [
    layout.MonadTall(margin=8, border_width=2, border_focus="#88c0d0", border_normal="#3b4252"),
    layout.Max(),
    layout.Floating(border_width=2, border_focus="#88c0d0", border_normal="#3b4252"),
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="pinentry"),
        Match(wm_class="ssh-askpass"),
    ]
)

# Bar
widget_defaults = dict(font="sans", fontsize=12, padding=6)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(disable_drag=True, highlight_method="block"),
                widget.Spacer(),
                widget.WindowName(max_chars=80),
                widget.Spacer(),
                widget.Clock(format="%Y-%m-%d %H:%M"),
            ],
            28,
        ),
    ),
]

# Mouse for floating windows
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# Required / common settings
dgroups_key_binder = None
dgroups_app_rules = []  # type: ignore
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
wl_input_rules = None

# Java apps sometimes need this
wmname = "LG3D"
