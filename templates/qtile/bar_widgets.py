"""
Shared bar widget builders
Each function takes a resolved theme dict (see bar_theme.get_theme) and
returns a single qtile widget, so bar variants can compose the same
building blocks instead of duplicating widget definitions.
"""

from libqtile import qtile, widget
from libqtile.lazy import lazy
from qtile_extras import widget as widget_extras
import subprocess


def make_spacer(theme, length=8):
    return widget.Spacer(length=length, background=theme["BG_COLOR"])


def make_flex_spacer(theme):
    return widget.Spacer(background=theme["BG_COLOR"])


def make_groupbox(theme):
    return widget.GroupBox(
        font=theme["FONT"],
        fontsize=theme["FONT_SIZE"],
        foreground=theme["INACTIVE_COLOR"],
        background=theme["BG_COLOR"],
        active=theme["ACTIVE_COLOR"],
        inactive=theme["INACTIVE_COLOR"],
        highlight_method="block",
        block_highlight_text_color=theme["BG_COLOR"],
        this_current_screen_border=theme["ACTIVE_COLOR"],
        this_screen_border=theme["ACTIVE_COLOR"],
        urgent_alert_method="block",
        urgent_border=theme["colors"]["red"],
        borderwidth=0,
        padding=14,
        margin_x=0,
        margin_y=4,
        rounded=True,
        disable_drag=True,
    )


def make_window_name(theme):
    return widget.WindowName(
        font=theme["FONT"],
        fontsize=theme["FONT_SIZE"],
        foreground=theme["INACTIVE_COLOR"],
        background="000000",
        padding=30,
        max_chars=40,
    )


def make_volume(theme):
    return widget.GenPollText(
        font=theme["FONT"],
        fontsize=theme["ICON_SIZE"],
        foreground=theme["colors"]["yellow"],
        background=theme["BG_COLOR"],
        padding=10,
        func=lambda: "󰖁" if subprocess.run(
            ["pamixer", "--get-mute"],
            capture_output=True,
            text=True
        ).stdout.strip() == "true" else "󰕾",
        update_interval=1,
        mouse_callbacks={
            "Button1": lambda: subprocess.Popen(["pamixer", "--toggle-mute"]),
            "Button3": lambda: subprocess.Popen(["pavucontrol"]),
        },
    )


def make_mic(theme):
    return widget.GenPollText(
        font=theme["FONT"],
        fontsize=theme["ICON_SIZE"],
        foreground=theme["colors"]["yellow"],
        background=theme["BG_COLOR"],
        padding=10,
        func=lambda: "󰍭" if subprocess.run(
            ["pamixer", "--default-source", "--get-mute"],
            capture_output=True,
            text=True
        ).stdout.strip() == "true" else "󰍬",
        update_interval=1,
        mouse_callbacks={
            "Button1": lambda: subprocess.Popen(["pamixer", "--default-source", "--toggle-mute"]),
            "Button3": lambda: subprocess.Popen(["pavucontrol"]),
        },
    )


def make_restart_servers(theme):
    return widget.TextBox(
        font=theme["FONT"],
        fontsize=theme["ICON_SIZE"],
        foreground=theme["colors"]["yellow"],
        background=theme["BG_COLOR"],
        text="",
        padding=10,
        mouse_callbacks={
            "Button1": lambda: (
                subprocess.Popen([
                    "systemctl",
                    "--user",
                    "restart",
                    "pipewire",
                    "pipewire-pulse",
                    "wireplumber",
                ]),
                qtile.cmd_reload_config(),
            ),
        },
    )


def make_status_notifier(theme):
    return widget_extras.StatusNotifier(
        icon_size=theme["ICON_SIZE"],
        padding=10,
        background=theme["BG_COLOR"],
    )


def make_systray(theme):
    return widget.Systray(
        icon_size=theme["ICON_SIZE"],
        padding=10,
        background=theme["BG_COLOR"],
    )


def make_stats_box(theme):
    return widget_extras.WidgetBox(
        font=theme["FONT"],
        fontsize=theme["ICON_SIZE"],
        foreground=theme["FG_COLOR"],
        background=theme["BG_COLOR"],
        text_closed="",
        text_open="",
        close_button_location="right",
        widgets=[
            widget.CPU(
                font=theme["FONT"],
                fontsize=theme["FONT_SIZE"] - 4,
                foreground=theme["FG_COLOR"],
                background=theme["BG_COLOR"],
                format="CPU {load_percent}%",
                padding=8,
            ),
            widget.DF(
                font=theme["FONT"],
                fontsize=theme["FONT_SIZE"] - 4,
                foreground=theme["FG_COLOR"],
                background=theme["BG_COLOR"],
                partition="/",
                format="Disk {r:.0%}",
                visible_on_warn=False,
                padding=8,
            ),
            widget.ThermalSensor(
                font=theme["FONT"],
                fontsize=theme["FONT_SIZE"] - 4,
                foreground=theme["FG_COLOR"],
                background=theme["BG_COLOR"],
                padding=8,
            ),
            widget.Net(
                font=theme["FONT"],
                fontsize=theme["FONT_SIZE"] - 4,
                foreground=theme["FG_COLOR"],
                background=theme["BG_COLOR"],
                padding=8,
            ),
        ],
    )


def make_help(theme):
    return widget.TextBox(
        font=theme["FONT"],
        fontsize=theme["ICON_SIZE"],
        foreground=theme["FG_COLOR"],
        background=theme["BG_COLOR"],
        text="",
        padding=10,
        mouse_callbacks={
            "Button1": lazy.group["scratchpad"].dropdown_toggle("shortcuts"),
            "Button3": lazy.group["scratchpad"].dropdown_toggle("keyboard"),
        },
    )


def make_keyboard_layout(theme):
    return widget.KeyboardLayout(
        font=theme["FONT"],
        fontsize=theme["FONT_SIZE"],
        foreground=theme["FG_COLOR"],
        background=theme["BG_COLOR"],
        configured_keyboards=["us", "pt"],
        mouse_callbacks={
            "Button1": lazy.widget["keyboardlayout"].next_keyboard(),
        },
    )


def make_clock(theme):
    return widget.Clock(
        font=theme["FONT"],
        fontsize=theme["FONT_SIZE"],
        foreground=theme["FG_COLOR"],
        background=theme["BG_COLOR"],
        padding=10,
        format='<span foreground="{inactive}">%a %d %b</span> <span foreground="{fg}">%H:%M</span>'.format(
            fg=theme["FG_COLOR"],
            inactive=theme["INACTIVE_COLOR"],
        ),
        markup=True,
        mouse_callbacks={
            "Button1": lambda: subprocess.Popen(["gsimplecal"]),
        },
    )
