"""
Default bar configuration - solid background, full width
"""
from libqtile import bar, widget
from qtile_extras import widget as widget_extras
from qtile_extras.popup.templates.mpris2 import DEFAULT_LAYOUT
import subprocess
import os


def create_bar(colors, terminal, browser):
    FONT = "NotoSansM Nerd Font, Font Awesome 6 Free Solid, Material Design Icons"
    FONT_SIZE = 22
    ICON_SIZE = 20

    # Visual settings
    BORDER_RADIUS = 0  # No rounded corners for default bar

    # Semantic color mappings from colors dict passed from config.py
    BG_COLOR = colors["bg"]
    FG_COLOR = colors["fg"]
    HIGHLIGHT_COLOR = colors["magenta"]
    NOTIFICATION_COLOR = colors["magenta"]
    INACTIVE_COLOR = colors["gray"]
    ACTIVE_COLOR = colors["white"]
    SUCCESS_COLOR = colors["green"]

    widget_defaults = dict(
        font=FONT,
        fontsize=FONT_SIZE,
        padding=12,
        foreground=FG_COLOR,
    )

    small_spacer = widget.Spacer(
        background=BG_COLOR,
        foreground=FG_COLOR,
        length=8
    )

    medium_spacer = widget.Spacer(
        background=BG_COLOR,
        foreground=FG_COLOR,
        length=12
    )

    large_spacer = widget.Spacer(
        background=BG_COLOR,
        foreground=FG_COLOR,
        length=16
    )

    widgets = [
        # Workspace/group indicator - shows workspaces 1-9 and highlights active one
        widget.GroupBox(
            active=ACTIVE_COLOR,
            inactive=INACTIVE_COLOR,
            highlight_method="line",
            this_current_screen_border=HIGHLIGHT_COLOR,
            this_screen_border=HIGHLIGHT_COLOR,
            other_current_screen_border=HIGHLIGHT_COLOR,
            other_screen_border=HIGHLIGHT_COLOR,
            urgent_border=colors["red"],
            background=BG_COLOR,
            disable_drag=True,
            use_mouse_wheel=False,
            block_highlight_text_color=ACTIVE_COLOR,
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
             fontsize = FONT_SIZE + 2,
             padding = 8,
             foreground = INACTIVE_COLOR,
             # Tooltip configuration
             tooltip_delay = 0.5,
             tooltip_background = BG_COLOR,
             tooltip_foreground = FG_COLOR,
        ),
        # Task list - shows all open windows with icons to help with positioning
        widget.TaskList(
            highlight_method="block",
            icon_size=ICON_SIZE - 2,
            fontsize=FONT_SIZE - 4,
            margin_y=0,
            max_title_width=300,
            border=colors["darker_gray"],
            background=BG_COLOR,
            foreground=FG_COLOR,
            txt_floating=" 󰉈 ",
            txt_maximized=" 󰊓 ",
            txt_minimized=" 󰖰 ",
            urgent_alert_method="border",
            urgent_border=colors["red"],
            rounded=False,
        ),
        # Volume control - OLD IMPLEMENTATION (basic widget without popup)
        # widget.Volume(
        #     fmt="{}",
        #     foreground=colors["yellow"],
        #     mouse_callbacks={
        #         "Button1": lazy.spawn("pamixer --toggle-mute"),
        #         "Button3": lazy.spawn("pavucontrol"),
        #     },
        #     get_volume_command="pamixer --get-volume",
        #     check_mute_command="pamixer --get-mute",
        #     check_mute_string="true",
        #     update_interval=0.2,
        #     unmute_format="󰕾 {}%",
        #     mute_format="󰕾",
        # ),
        # NEW IMPLEMENTATION (qtile-extras with popup slider) - PulseVolumeExtra has built-in left-click popup
        widget_extras.PulseVolumeExtra(
            font=FONT,
            fontsize=FONT_SIZE - 2,
            foreground=colors["yellow"],
            background=BG_COLOR,
            unmute_format="󰕾 {volume}%",
            mute_format="󰖁",
            update_interval=0.2,
            # Right click for full control panel
            mouse_callbacks={
                "Button3": lambda: subprocess.Popen(["pavucontrol"]),
            },
        ),
        # Microphone mute toggle
        widget.GenPollText(
            font=FONT,
            fontsize=ICON_SIZE,
            foreground=SUCCESS_COLOR,
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
        ),
        # Media player - displays currently playing music/video via MPRIS
        # OLD IMPLEMENTATION (basic widget without popup)
        # widget.Mpris2(
        #     format="{xesam:artist} - {xesam:title}",
        #     foreground=colors["yellow"],
        #     max_chars=40,
        #     scroll=True,
        #     scroll_interval=0.5,
        #     scroll_delay=2,
        #     scroll_repeat=True,
        #     paused_text="󰏤 {track}",
        #     playing_text="󰐊 {track}",
        #     stopped_text="󰓛",
        #     mouse_callbacks={
        #         "Button1": lazy.spawn("playerctl play-pause"),
        #         "Button3": lazy.spawn("playerctl next"),
        #         "Button2": lazy.spawn("playerctl previous"),
        #     },
        # ),
        # NEW IMPLEMENTATION (qtile-extras with popup showing cover art + controls)
        widget_extras.Mpris2(
            name="mpris",
            font=FONT,
            fontsize=FONT_SIZE - 2,
            foreground=colors["yellow"],
            background=BG_COLOR,
            format="{xesam:title}",
            paused_text="󰏤 {track}",
            playing_text="󰐊 {track}",
            stopped_text="󰓛",
            max_chars=40,
            scroll=True,
            scroll_interval=0.5,
            scroll_wait_intervals=4,
            # Popup configuration - shows cover art + controls on click
            popup_layout=DEFAULT_LAYOUT,
            popup_show_args="above",
            popup_hide_timeout=0,  # 0 = stays until manually closed (click again or ESC)
            # Mouse callbacks
            mouse_callbacks={
                "Button1": lambda: widget_extras.Mpris2.toggle_player(),  # Click to show/hide popup
                "Button3": lambda: subprocess.Popen(["playerctl", "next"]),  # Right click = next
                "Button2": lambda: subprocess.Popen(["playerctl", "previous"]),  # Middle click = previous
            },
        ),
        large_spacer,
        # System tray - shows system tray icons (network, bluetooth, etc.)
        widget.Systray(
            icon_size=ICON_SIZE,
            padding=8,
        ),
        widget_extras.StatusNotifier(
            icon_size=FONT_SIZE,
            padding=8,
            icon_theme="Papirus-Dark",
            menu_font=FONT,
            menu_fontsize=FONT_SIZE - 6,
        ),
        widget.KeyboardLayout(
            configured_keyboards=["us", "pt"],
            foreground=colors["yellow"],
            fmt="󰌌 {}",
            fontsize=ICON_SIZE,
        ),
        large_spacer,
        # Automatic layout-specific icons:
        widget_extras.CurrentLayoutIcon(
            use_mask=True,
            foreground=colors["yellow"],
            scale=0.4,
            padding=8,
        ),
        widget.Clock(format="%d-%m-%Y %H:%M", foreground=INACTIVE_COLOR),
    ]

    return bar.Bar(
        widgets,
        48,
        background=BG_COLOR,
    )
