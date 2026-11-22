{ roseFrost, lib, ... }:
{
  # Привязки клавиш — на Lua, в binds.lua (рядом). home-manager кладёт файл в
  # ~/.config/hypr/binds.lua и подключает его из hyprland.lua (autoLoad).
  # Действует только при configType = "lua" (переход — в hyprland.nix).
  wayland.windowManager.hyprland.extraLuaFiles.binds.content = ./binds.lua;
  wayland.windowManager.hyprland.extraLuaFiles.rofiLauncher = lib.mkIf (!roseFrost) {
    content = ''
      hl.bind("SUPER + D", hl.dsp.exec_cmd("toggle-rofi rofi -show drun"), {
        description = "Open application launcher",
      })
    '';
  };
}
