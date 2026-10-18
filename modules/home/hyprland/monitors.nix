{ pkgs, lib, host, ... }:
let
  # fluff: экран 15.6" 1920x1080 (~141 PPI). 1.25 → рабочая область 1536x864 (делится нацело —
  # Hyprland требует целый логический размер). XWayland-окна (Steam, игры через nvidia-offload)
  # не мылятся: xwayland.force_zero_scaling = true в settings.nix.
  hostMonitors = lib.optionalString (host == "fluff") ''
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.25 })
  '';
in
{
  # Мониторы — на Lua, в displays.lua (рядом): запасное правило и подключение файлов
  # nwg-displays (~/.config/hypr/monitors.lua и workspaces.lua). Имя displays, а не monitors:
  # monitors.lua в ~/.config/hypr пишет сам nwg-displays. Действует только при configType = "lua".
  wayland.windowManager.hyprland.extraLuaFiles.displays.content =
    builtins.replaceStrings [ "-- @HOST_MONITORS@" ] [ hostMonitors ] (builtins.readFile ./displays.lua);

  home.packages = with pkgs; [ nwg-displays ];
}
