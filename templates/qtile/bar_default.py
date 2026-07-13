"""
Minimal Centered Bar for Qtile
A sleek, centered bar with only essential widgets
"""

from libqtile import bar
from bar_theme import get_theme
from bar_widgets import (
    make_spacer,
    make_flex_spacer,
    make_groupbox,
    make_window_name,
    make_volume,
    make_mic,
    make_restart_servers,
    make_status_notifier,
    make_systray,
    make_stats_box,
    make_help,
    make_keyboard_layout,
    make_clock,
)


def create_bar(colors):
    theme = get_theme(colors)

    widgets = [
        # Left flexible spacer - pushes everything to center
        make_flex_spacer(theme),

        # ========== CENTERED BAR CONTENT ==========
        make_groupbox(theme),
        make_spacer(theme, 12),

        make_window_name(theme),
        make_spacer(theme, 12),

        make_volume(theme),
        make_mic(theme),
        make_restart_servers(theme),
        make_status_notifier(theme),
        make_systray(theme),
        make_spacer(theme, 12),

        make_stats_box(theme),
        make_spacer(theme, 12),

        make_help(theme),
        make_spacer(theme, 12),

        make_keyboard_layout(theme),
        make_clock(theme),
        # ========== END CENTERED CONTENT ==========

        # Right flexible spacer - balances the left spacer
        make_flex_spacer(theme),
    ]

    return bar.Bar(
        widgets,
        theme["BAR_SIZE"],
        background="00000000",  # Transparent bar background
        margin=[8, 100, 0, 100],  # top, right, bottom, left margins (centered with side margins)
        border_width=0,
        border_color="00000000",
    )
