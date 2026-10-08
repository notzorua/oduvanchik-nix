{ ... }:
{
  # Автозапуск — на Lua, в startup.lua (рядом). Файл кладётся в ~/.config/hypr/startup.lua,
  # но подключается не автоматически, а из extraConfig: home-manager вставляет extraConfig
  # в конец hyprland.lua, после своего импорта окружения — так программы стартуют после него,
  # как раньше. Действует только при configType = "lua".
  wayland.windowManager.hyprland = {
    extraLuaFiles.startup = {
      content = ./startup.lua;
      autoLoad = false;
    };
    extraConfig = ''
      require("startup")
    '';
  };
}
