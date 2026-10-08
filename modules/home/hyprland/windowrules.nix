{ ... }:
{
  # Правила окон, слоёв и рабочих столов — на Lua, в rules.lua (рядом): home-manager кладёт
  # его в ~/.config/hypr/rules.lua и подключает из hyprland.lua (autoLoad).
  # Действует только при configType = "lua".
  wayland.windowManager.hyprland.extraLuaFiles.rules.content = ./rules.lua;
}
