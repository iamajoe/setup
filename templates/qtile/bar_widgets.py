"""
Shared bar widget builders
Each function takes a resolved theme dict (see bar_theme.get_theme) and
returns a single qtile widget, so bar variants can compose the same
building blocks instead of duplicating widget definitions.
"""

from libqtile import qtile, widget
from libqtile.lazy import lazy
# from qtile_extras import widget as widget_extras
# from stats_popup_widget import make_stats_popup
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
        text="",
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
    # TODO: qtile_extras is failing with qtile 0.37.0
    #     return widget_extras.StatusNotifier(
    #         font=theme["FONT"],
    #         fontsize=theme["ICON_SIZE"],
    #         background=theme["BG_COLOR"],
    #         padding=10,
    return widget.StatusNotifier(
        font=theme["FONT"],
        fontsize=theme["ICON_SIZE"],
        background=theme["BG_COLOR"],
        padding=10,
    )
)

# def make_stats_box(theme):
#     return make_stats_popup(theme)


def make_help(theme):
    return widget.TextBox(
        font=theme["FONT"],
        fontsize=theme["ICON_SIZE"],
        foreground=theme["INACTIVE_COLOR"],
        background=theme["BG_COLOR"],
        text="",
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
