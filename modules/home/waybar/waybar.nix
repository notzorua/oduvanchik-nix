{ inputs, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    # Waybar из nixpkgs шлёт старый синтаксис dispatch — кнопки рабочих столов не работают с Lua-конфигом.
    # cava выключен: модуль cava в нашем Waybar не используется, а upstream перевёл
    # subprojects/libcava.wrap на wrap-git (каталог libcava), тогда как их nix/default.nix
    # по-прежнему кладёт исходники в subprojects/cava-1.0.0 → meson не находит libcava и
    # пытается скачать subproject (в песочнице сети нет). Убрать, когда upstream поправит nix/.
    package = inputs.waybar.packages.${pkgs.stdenv.hostPlatform.system}.waybar.overrideAttrs (old: {
      mesonFlags = map (f: if f == "-Dcava=enabled" then "-Dcava=disabled" else f) old.mesonFlags;
    });
  };
}
