"""
Minimal Centered Bar for Qtile
A sleek, centered bar with only essential widgets
"""

from libqtile import bar, widget
from qtile_extras import widget as widget_extras
from qtile_extras.widget.decorations import RectDecoration
import subprocess
import os


def create_bar(colors, terminal=None, browser=None):
    # Semantic color mappings
    BG_COLOR = "00000000"  # Fully transparent
    FG_COLOR = colors["fg"]
    ACTIVE_COLOR = colors["magenta"]  # Active workspace
    INACTIVE_COLOR = colors["gray"]   # Inactive workspaces
    HIGHLIGHT_COLOR = colors["magenta"]
    SUCCESS_COLOR = colors["green"]
    WARNING_COLOR = colors["yellow"]

    # Typography
    FONT = "NotoSansM Nerd Font, Font Awesome 6 Free Solid, sans-serif"
    FONT_SIZE = 20
    ICON_SIZE = 22

    # Layout
    BORDER_RADIUS = 16  # Rounded corners
    BAR_SIZE = 42
    PADDING = 8

    # Widget decorations
    rounded_decoration = RectDecoration(
        radius=BORDER_RADIUS,
        filled=True,
        colour=colors["bg"],  # Solid background for the bar section
        padding_y=4,
        padding_x=12,
    )

    def spacer(length=8):
        return widget.Spacer(length=length, background=BG_COLOR)

    def flex_spacer():
        return widget.Spacer(background=BG_COLOR)

    widgets = [
        # Left flexible spacer - pushes everything to center
        flex_spacer(),

        # ========== CENTERED BAR CONTENT ==========

        # Workspace indicators (numbers only)
        widget.GroupBox(
            font=FONT,
            fontsize=FONT_SIZE + 2,
            foreground=INACTIVE_COLOR,
            background=colors["bg"],
            active=ACTIVE_COLOR,  # Active workspace
            inactive=INACTIVE_COLOR,  # Inactive workspaces
            highlight_method="block",
            block_highlight_text_color=colors["bg"],  # Text color when selected
            this_current_screen_border=ACTIVE_COLOR,  # Selected workspace background
            this_screen_border=ACTIVE_COLOR,
            urgent_alert_method="block",
            urgent_border=colors["red"],
            borderwidth=0,
            padding=12,
            margin_x=0,
            margin_y=4,
            rounded=True,
            disable_drag=True,
            decorations=[rounded_decoration],
        ),
        spacer(12),

        # Volume mute toggle
        widget.GenPollText(
            font=FONT,
            fontsize=ICON_SIZE,
            foreground=SUCCESS_COLOR,
            background=colors["bg"],
            padding=2
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
            decorations=[rounded_decoration],
        ),

        # Microphone mute toggle
        widget.GenPollText(
            font=FONT,
            fontsize=ICON_SIZE,
            foreground=SUCCESS_COLOR,
            background=colors["bg"],
            padding=2
            func=lambda: "󰍭" if subprocess.run(
                ["pamixer", "--default-source", "--get-mute"],
                capture_output=True,
                text=True
            ).stdout.strip() == "true" else "󰍮",
            update_interval=1,
            mouse_callbacks={
                "Button1": lambda: subprocess.Popen(["pamixer", "--default-source", "--toggle-mute"]),
                "Button3": lambda: subprocess.Popen(["pavucontrol"]),
            },
            decorations=[rounded_decoration],
        ),
        spacer(12),

        # Status Notifier (icons like Bluetooth, etc.)
        widget_extras.StatusNotifier(
            icon_size=ICON_SIZE,
            icon_theme="Papirus-Dark",
            padding=8,
            background=colors["bg"],
            decorations=[rounded_decoration],
        ),
        spacer(12),

        # System Tray
        widget.Systray(
            icon_size=ICON_SIZE,
            padding=8,
            background=colors["bg"],
            decorations=[rounded_decoration],
        ),

        spacer(12),

        # Clock + Date
        widget.Clock(
            font=FONT,
            fontsize=FONT_SIZE,
            foreground=FG_COLOR,
            background=colors["bg"],
            format="%H:%M",
            decorations=[rounded_decoration],
        ),

        # Date
        widget.Clock(
            font=FONT,
            fontsize=FONT_SIZE, 
            foreground=INACTIVE_COLOR,
            background=colors["bg"],
            format="%a %b %d",
            mouse_callbacks={
                "Button1": lambda: subprocess.Popen(["gsimplecal"]),
            },
            decorations=[rounded_decoration],
        ),

        # ========== END CENTERED CONTENT ==========

        # Right flexible spacer - balances the left spacer
        flex_spacer(),
    ]

    return bar.Bar(
        widgets,
        BAR_SIZE,
        background=BG_COLOR,  # Transparent bar background
        margin=[8, 100, 0, 100],  # top, right, bottom, left margins (centered with side margins)
        border_width=0,
        border_color=BG_COLOR,
    )
