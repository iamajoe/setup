"""
Default bar configuration - solid background, full width
"""
from libqtile import bar, widget
from qtile_extras import widget as widget_extras
from libqtile.lazy import lazy


def create_bar(colors, terminal, browser):
    """Create and return the default bar configuration"""

    widget_defaults = dict(
        font="NotoSansM Nerd Font",
        fontsize=22,
        padding=12,
        foreground=colors["fg"],
    )

    small_spacer = widget.Spacer(
        background=colors["bg"],
        foreground=colors["fg"],
        length=8
    )

    medium_spacer = widget.Spacer(
        background=colors["bg"],
        foreground=colors["fg"],
        length=12
    )

    large_spacer = widget.Spacer(
        background=colors["bg"],
        foreground=colors["fg"],
        length=16
    )

    widgets = [
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
            block_highlight_text_color=colors["white"],
            rounded=False,
        ),
        large_spacer,
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
             foreground = colors["gray"],
             # Tooltip configuration
             tooltip_delay = 0.5,
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
            get_volume_command="pamixer --get-volume",
            check_mute_command="pamixer --get-mute",
            check_mute_string="true",
            update_interval=0.2,
            unmute_format="󰕾 {}%",
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
        large_spacer,
        # System tray - shows system tray icons (network, bluetooth, etc.)
        widget.Systray(
            icon_size=20,
            padding=8,
        ),
        widget_extras.StatusNotifier(
            icon_size=22,
            padding=8,
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
        large_spacer,
        # Automatic layout-specific icons:
        widget_extras.CurrentLayoutIcon(
            use_mask=True,
            foreground=colors["yellow"],
            scale=0.4,
            padding=8,
        ),
        widget.Clock(format="%d-%m-%Y %H:%M", foreground=colors["gray"]),
    ]

    return bar.Bar(
        widgets,
        48,
        background=colors["bg"],
    )
