{ lib, host, ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    # "hash dbus-update-activation-environment 2>/dev/null"
    "dbus-update-activation-environment --all --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

    "hyprlock"

    "nm-applet &"
    "poweralertd &"
    "wl-clip-persist --clipboard regular &"
    "wl-paste --type text --watch cliphist store &"
    "wl-paste --type image --watch cliphist store &"
    #"wl-clip-persist --clipboard both &"
    #"wl-paste --watch cliphist store &"
    "waybar &"

    # screen time
    "niri-screen-time -daemon"

    "swaync &"
    "udiskie --automount --notify --smart-tray &"
    "hyprctl setcursor Bibata-Modern-Ice 24 &"
    "init-wallpaper &"

    #tray icon support
    "xembedsniproxy"

    # only start monitor watching screen on laptop
    "${if (host == "p14s" || host == "laptop") then "monitor-watcher &" else ""}"

    "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false"
    "[workspace 1 silent] zen-beta"
    "[workspace 2 silent] ghostty"
    "[workspace 2 silent] Bluetooth Manager"
    "[workspace 3 silent] AyuGram"
    "[workspace 4 silent] Throne"
  ];
}
