"""
Shared bar theme
Resolves the raw color palette (config.py) into the semantic values and
typography/layout constants used by every bar variant, so all bars render
with identical styling.
"""


def get_theme(colors):
    return {
        "colors": colors,
        # Semantic color mappings
        "BG_COLOR": colors["bg"],
        "FG_COLOR": colors["fg"],
        "ACTIVE_COLOR": colors["cyan"],
        "INACTIVE_COLOR": colors["gray"],
        "HIGHLIGHT_COLOR": colors["magenta"],
        "SUCCESS_COLOR": colors["green"],
        "WARNING_COLOR": colors["yellow"],
        # Typography
        "FONT": "NotoSansM Nerd Font, Font Awesome 6 Free Solid, sans-serif",
        "FONT_SIZE": 20,
        "ICON_SIZE": 22,
        # Layout
        "BORDER_RADIUS": 16,
        "BAR_SIZE": 42,
        "PADDING": 8,
    }
