{ pkgs, ... }:
{
  # Мониторы — на Lua, в displays.lua (рядом): запасное правило и подключение файлов
  # nwg-displays (~/.config/hypr/monitors.lua и workspaces.lua). Имя displays, а не monitors:
  # monitors.lua в ~/.config/hypr пишет сам nwg-displays. Действует только при configType = "lua".
  wayland.windowManager.hyprland.extraLuaFiles.displays.content = ./displays.lua;

  home.packages = with pkgs; [ nwg-displays ];
}
