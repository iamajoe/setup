"""
Rounded bar configuration - transparent background, rounded corners, centered TaskList
"""
from libqtile import bar, widget
from qtile_extras import widget as widget_extras
from qtile_extras.widget.decorations import RectDecoration
from libqtile.lazy import lazy


def create_bar(colors, terminal, browser):
    """Create and return the rounded bar configuration with transparent background"""
    
    # Make background semi-transparent
    transparent_bg = "#1e1e2eCC"  # 80% opacity
    
    widget_defaults = dict(
        font="NotoSansM Nerd Font",
        fontsize=22,
        padding=12,
        foreground=colors["fg"],
    )
    
    # Decoration for rounded corners
    rounded_decoration = RectDecoration(
        colour=colors["bg"],
        radius=12,
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
            active=colors["white"],
            inactive=colors["gray"],
            highlight_method="line",
            this_current_screen_border=colors["magenta"],
            this_screen_border=colors["magenta"],
            other_current_screen_border=colors["magenta"],
            other_screen_border=colors["magenta"],
            urgent_border=colors["red"],
            background="00000000",
            disable_drag=True,
            use_mouse_wheel=False,
            block_highlight_text_color=colors["white"],
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
             fontsize = 24,
             padding = 8,
             foreground = colors["gray"],
             background="00000000",
             # Tooltip configuration
             tooltip_delay = 0.5,
             tooltip_background = colors["bg"],
             tooltip_foreground = colors["fg"],
             decorations=[rounded_decoration],
        ),
        large_spacer,
        # Flexible spacer to center the TaskList
        flex_spacer,
        # Task list - centered with all open windows
        widget.TaskList(
            highlight_method="block",
            icon_size=18,
            fontsize=18,
            margin_y=0,
            max_title_width=300,
            border=colors["darker_gray"],
            background="00000000",
            foreground=colors["fg"],
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
        # Volume widget
        widget.Volume(
            fmt="{}",
            foreground=colors["yellow"],
            background="00000000",
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
            decorations=[rounded_decoration],
        ),
        medium_spacer,
        # Media player
        widget.Mpris2(
            format="{xesam:artist} - {xesam:title}",
            foreground=colors["yellow"],
            background="00000000",
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
            decorations=[rounded_decoration],
        ),
        large_spacer,
        # System tray
        widget.Systray(
            icon_size=20,
            padding=8,
            background="00000000",
        ),
        widget_extras.StatusNotifier(
            icon_size=22,
            padding=8,
            background="00000000",
            icon_theme="Adwaita",
            menu_font="NotoSansM Nerd Font",
            menu_fontsize=16,
        ),
        medium_spacer,
        # Keyboard layout
        widget.KeyboardLayout(
            configured_keyboards=["us", "pt"],
            foreground=colors["yellow"],
            background="00000000",
            fmt="󰌌 {}",
            fontsize=20,
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
            foreground=colors["gray"],
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
