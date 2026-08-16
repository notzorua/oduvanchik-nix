{ ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "dbus-update-activation-environment --all --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

    "hyprlock"
    "nm-applet &"
    "poweralertd &"
    "wl-clip-persist --clipboard regular &"
    "wl-paste --type text --watch cliphist store &"
    "wl-paste --type image --watch cliphist store &"
    "waybar &"
    "hyprtime watch"
    "udiskie --automount --notify --smart-tray &"
    "xrdb -merge ~/.Xresources &"
    "hyprctl setcursor Qogir-Light 48 &"
    "init-wallpaper &"
    "xembedsniproxy"
    "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false"
    "[workspace 1 silent] zen-beta"
    "[workspace 2 silent] ghostty"
    "[workspace 2 silent] Bluetooth Manager"
    "[workspace 3 silent] AyuGram"
    "[workspace 4 silent] Throne"
  ];
}
