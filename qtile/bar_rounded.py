"""
Rounded bar configuration - transparent background, rounded corners, centered TaskList
"""
from libqtile import bar, widget
from qtile_extras import widget as widget_extras
from qtile_extras.widget.decorations import RectDecoration
from qtile_extras.popup.templates.mpris2 import DEFAULT_LAYOUT
import subprocess
import os


########################
# THEME CONSTANTS
########################
FONT = "NotoSansM Nerd Font, Font Awesome 6 Free Solid, Material Design Icons"
FONT_SIZE = 22
ICON_SIZE = 20

# Visual settings
BORDER_RADIUS = 12  # Rounded corners for widgets


def create_bar(colors, terminal, browser):
    # Semantic color mappings from colors dict passed from config.py
    BG_COLOR = colors["bg"]
    FG_COLOR = colors["fg"]
    HIGHLIGHT_COLOR = colors["magenta"]
    NOTIFICATION_COLOR = colors["magenta"]
    INACTIVE_COLOR = colors["gray"]
    ACTIVE_COLOR = colors["white"]
    SUCCESS_COLOR = colors["green"]

    # Make background semi-transparent
    transparent_bg = "#1e1e2eCC"  # 80% opacity

    widget_defaults = dict(
        font=FONT,
        fontsize=FONT_SIZE,
        padding=12,
        foreground=FG_COLOR,
    )

    # Decoration for rounded corners
    rounded_decoration = RectDecoration(
        colour=BG_COLOR,
        radius=BORDER_RADIUS,
        filled=True,
        padding_y=4,
        padding_x=8,
    )

    small_spacer = widget.Spacer(
        background="00000000",  # Fully transparent
        length=8
    )

    medium_spacer = widget.Spacer(
        background="00000000",
        length=12
    )

    large_spacer = widget.Spacer(
        background="00000000",
        length=16
    )

    # Flexible spacer for centering
    flex_spacer = widget.Spacer(
        background="00000000",
    )

    widgets = [
        large_spacer,
        # Workspace/group indicator
        widget.GroupBox(
            active=ACTIVE_COLOR,
            inactive=INACTIVE_COLOR,
            highlight_method="line",
            this_current_screen_border=HIGHLIGHT_COLOR,
            this_screen_border=HIGHLIGHT_COLOR,
            other_current_screen_border=HIGHLIGHT_COLOR,
            other_screen_border=HIGHLIGHT_COLOR,
            urgent_border=colors["red"],
            background="00000000",
            disable_drag=True,
            use_mouse_wheel=False,
            block_highlight_text_color=ACTIVE_COLOR,
            rounded=False,
            decorations=[rounded_decoration],
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
             background="00000000",
             # Tooltip configuration
             tooltip_delay = 0.5,
             tooltip_background = BG_COLOR,
             tooltip_foreground = FG_COLOR,
             decorations=[rounded_decoration],
        ),
        large_spacer,
        # Flexible spacer to center the TaskList
        flex_spacer,
        # Task list - centered with all open windows
        widget.TaskList(
            highlight_method="block",
            icon_size=ICON_SIZE - 2,
            fontsize=FONT_SIZE - 4,
            margin_y=0,
            max_title_width=300,
            border=colors["darker_gray"],
            background="00000000",
            foreground=FG_COLOR,
            txt_floating=" 󰉈 ",
            txt_maximized=" 󰊓 ",
            txt_minimized=" 󰖰 ",
            urgent_alert_method="border",
            urgent_border=colors["red"],
            rounded=False,
            decorations=[rounded_decoration],
        ),
        # Flexible spacer to center the TaskList
        flex_spacer,
        large_spacer,
        # Volume widget - OLD IMPLEMENTATION (basic widget without popup)
        # widget.Volume(
        #     fmt="{}",
        #     foreground=colors["yellow"],
        #     background="00000000",
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
        #     decorations=[rounded_decoration],
        # ),
        # NEW IMPLEMENTATION (qtile-extras with popup slider) - PulseVolumeExtra has built-in left-click popup
        widget_extras.PulseVolumeExtra(
            font=FONT,
            fontsize=FONT_SIZE - 2,
            foreground=colors["yellow"],
            background="00000000",
            unmute_format="󰕾 {volume}%",
            mute_format="󰖁",
            update_interval=0.2,
            # Right click for full control panel
            mouse_callbacks={
                "Button3": lambda: subprocess.Popen(["pavucontrol"]),
            },
            decorations=[rounded_decoration],
        ),
        medium_spacer,
        # Microphone mute toggle
        widget.GenPollText(
            font=FONT,
            fontsize=ICON_SIZE,
            foreground=SUCCESS_COLOR,
            background="00000000",
            func=lambda: " 󰍭" if subprocess.run(
                ["pamixer", "--default-source", "--get-mute"],
                capture_output=True,
                text=True
            ).stdout.strip() == "true" else " 󰍮",
            update_interval=1,
            mouse_callbacks={
                "Button1": lambda: subprocess.Popen(["pamixer", "--default-source", "--toggle-mute"]),
                "Button3": lambda: subprocess.Popen(["pavucontrol"]),
            },
            decorations=[rounded_decoration],
        ),
        medium_spacer,
        # Media player - displays currently playing music/video via MPRIS
        # OLD IMPLEMENTATION (basic widget without popup)
        # widget.Mpris2(
        #     format="{xesam:artist} - {xesam:title}",
        #     foreground=colors["yellow"],
        #     background="00000000",
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
        #     decorations=[rounded_decoration],
        # ),
        # NEW IMPLEMENTATION (qtile-extras with popup showing cover art + controls)
        widget_extras.Mpris2(
            name="mpris",
            font=FONT,
            fontsize=FONT_SIZE - 2,
            foreground=colors["yellow"],
            background="00000000",
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
            decorations=[rounded_decoration],
        ),
        large_spacer,
        # System tray
        widget.Systray(
            icon_size=ICON_SIZE,
            padding=8,
            background="00000000",
        ),
        widget_extras.StatusNotifier(
            icon_size=FONT_SIZE,
            padding=8,
            background="00000000",
            icon_theme="Papirus-Dark",
            menu_font=FONT,
            menu_fontsize=FONT_SIZE - 6,
        ),
        medium_spacer,
        # Keyboard layout
        widget.KeyboardLayout(
            configured_keyboards=["us", "pt"],
            foreground=colors["yellow"],
            background="00000000",
            fmt="󰌌 {}",
            fontsize=ICON_SIZE,
            decorations=[rounded_decoration],
        ),
        medium_spacer,
        # Layout icon
        widget_extras.CurrentLayoutIcon(
            use_mask=True,
            foreground=colors["yellow"],
            background="00000000",
            scale=0.4,
            padding=8,
            decorations=[rounded_decoration],
        ),
        medium_spacer,
        # Clock
        widget.Clock(
            format="%d-%m-%Y %H:%M",
            foreground=INACTIVE_COLOR,
            background="00000000",
            decorations=[rounded_decoration],
        ),
        large_spacer,
    ]

    return bar.Bar(
        widgets,
        56,  # Slightly taller for better aesthetics
        background=transparent_bg,
        margin=[8, 16, 0, 16],  # top, right, bottom, left - creates floating effect
    )
