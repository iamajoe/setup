"""
Stats popup widget for the qtile bar.
Shows CPU, disk, temp and net stats in a floating popup on click.
Requires psutil (python3Packages.psutil in nixos extraPackages).
"""

# TODO: qtile extras fails with qtile 0.37.0
from libqtile import widget
# from qtile_extras.widget.mixins import ExtendedPopupMixin
# from qtile_extras.popup.toolkit import PopupRelativeLayout, PopupText


# class StatsPopupWidget(widget.TextBox, ExtendedPopupMixin):
#     defaults = [
#         ("popup_layout", None, "Popup layout for stats"),
#         ("popup_hide_timeout", 10, "Auto-hide timeout in seconds"),
#         ("update_interval", 2.0, "Stats refresh interval"),
#     ]

#     def __init__(self, **config):
#         widget.TextBox.__init__(self, text="", **config)
#         ExtendedPopupMixin.__init__(self, **config)
#         self.add_defaults(StatsPopupWidget.defaults)
#         self.add_callbacks({"Button1": self.show_popup})

#     def _configure(self, qtile, bar):
#         widget.TextBox._configure(self, qtile, bar)
#         if hasattr(ExtendedPopupMixin, "_configure"):
#             ExtendedPopupMixin._configure(self, qtile, bar)

#     def _update_popup(self):
#         import psutil
#         cpu = psutil.cpu_percent(interval=None)
#         disk = psutil.disk_usage("/").percent
#         try:
#             temps = psutil.sensors_temperatures()
#             core = next(iter(temps.values()), [])
#             temp_str = f"{core[0].current:.0f}°C" if core else "N/A"
#         except Exception:
#             temp_str = "N/A"
#         net = psutil.net_io_counters()
#         self.extended_popup.update_controls(
#             cpu=f"CPU   {cpu:.0f}%",
#             disk=f"Disk   {disk:.0f}%",
#             temp=f"Temp   {temp_str}",
#             net=f"Net   ↑{net.bytes_sent // 1024}K  ↓{net.bytes_recv // 1024}K",
#         )


# def make_stats_popup(theme):
#     bg = theme["BG_COLOR"]
#     fg = theme["FG_COLOR"]
#     font = theme["FONT"]
#     font_size = theme["FONT_SIZE"] - 2

#     popup_layout = PopupRelativeLayout(
#         width=280,
#         height=140,
#         background=bg,
#         controls=[
#             PopupText(
#                 name="cpu", text="CPU   ...",
#                 font=font, fontsize=font_size,
#                 foreground=fg, background=bg,
#                 pos_x=0.04, pos_y=0.04, width=0.92, height=0.22,
#             ),
#             PopupText(
#                 name="disk", text="Disk   ...",
#                 font=font, fontsize=font_size,
#                 foreground=fg, background=bg,
#                 pos_x=0.04, pos_y=0.28, width=0.92, height=0.22,
#             ),
#             PopupText(
#                 name="temp", text="Temp   ...",
#                 font=font, fontsize=font_size,
#                 foreground=fg, background=bg,
#                 pos_x=0.04, pos_y=0.52, width=0.92, height=0.22,
#             ),
#             PopupText(
#                 name="net", text="Net   ...",
#                 font=font, fontsize=font_size,
#                 foreground=fg, background=bg,
#                 pos_x=0.04, pos_y=0.76, width=0.92, height=0.22,
#             ),
#         ],
#         hide_on_mouse_leave=True,
#         close_on_click=False,
#     )

#     return StatsPopupWidget(
#         font=font,
#         fontsize=theme["ICON_SIZE"],
#         foreground=theme["colors"]["yellow"],
#         background=bg,
#         padding=10,
#         popup_layout=popup_layout,
#         popup_hide_timeout=10,
#         update_interval=2,
#     )
