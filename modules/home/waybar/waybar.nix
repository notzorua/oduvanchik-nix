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
      # Тесты выключены: тест utils «SleeperThread stress test» зависит от таймингов и
      # падает под нагрузкой (-1 == 0), когда Waybar собирается параллельно с другими
      # пакетами. Кэша у Waybar нет — собирается при каждом обновлении, и такой сбой
      # роняет весь nixup. Одного doCheck = false мало: без него пропадает catch2
      # (checkInputs), а их -Dtests=enabled требует его на этапе meson. Вернуть оба,
      # если upstream сделает тест устойчивым.
      mesonFlags = map (
        f:
        {
          "-Dcava=enabled" = "-Dcava=disabled";
          "-Dtests=enabled" = "-Dtests=disabled";
        }
        .${f} or f
      ) old.mesonFlags;
      doCheck = false;
    });
  };
}
