{ pkgs, lib, ... }:
let
  # Скриншот (клавиша Ctrl+Print, binds.lua): hyprpicker замораживает экран, slurp — выбор
  # области, grim снимает её, снимок сразу в буфер, затем satty для правки. Запуск satty
  # (~0.7 с, в основном инициализация GTK) прячется за выбором области.
  # - hyprpicker -r — заморозить и неактивные мониторы, -z/-d — без лупы и превью цвета.
  #   Его слой остаётся на экране во время grim: снимок — замороженная картинка (момент
  #   нажатия) без лишнего. trap — на случай Esc в slurp (slurp выходит с ошибкой).
  # - Перед slurp ждём слой hyprpicker (по pid в hyprctl layers, обычно ~10 мс): появись он
  #   позже — окажется поверх slurp и заберёт клик себе. hyprctl — из PATH (Hyprland
  #   ставится системно, package = null).
  # - Для satty — PPM во временный файл: PNG satty разбирал ~0.55 с, PPM ~0.015 с (замер
  #   18.10.2026). Не конвейером: satty стартовал бы вместе с grim.
  # - В буфер — второй grim той же области в PNG, в фоне, пока экран ещё заморожен; после
  #   него снимается заморозка. satty его не ждёт: PNG готов раньше, чем окно satty.
  #   -l 1: скорость сжатия зависит от содержимого — весь экран при -l 6 бывал 0.1–0.7 с,
  #   при -l 1 ~0.17 с, размер почти тот же. PNG, а не PPM: image/png понимают все.
  # - satty с GSK_RENDERER=gl (бывший ngl, в этой GTK переименован) и GTK_THEME=Adwaita:
  #   быстрее Vulkan и темы Colloid примерно на 0.1 с каждый; тёмная схема остаётся.
  # - Enter/кнопка копирования в satty — wl-copy; сохранение — в ~/Pictures/Screenshots.
  #   --early-exit — закрыть satty после копирования/сохранения; стоит последним: он
  #   принимает необязательные значения (all/copy/save…) и «съел» бы следующий аргумент.
  # Флаги сверены с --help: satty 0.22.0, hyprpicker 0.4.7, slurp 1.5.0, grim 1.5.0.
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"

    ${lib.getExe pkgs.hyprpicker} -r -z -d -q >/dev/null &
    picker=$!
    shot=$(mktemp -p "''${XDG_RUNTIME_DIR:-/tmp}" screenshot.XXXXXX.ppm)
    trap 'kill "$picker" 2>/dev/null; rm -f "$shot"' EXIT
    for _ in $(seq 50); do
      hyprctl layers | grep -q "namespace: hyprpicker, pid: $picker" && break
    done

    region=$(${lib.getExe pkgs.slurp}) || exit 0
    ${lib.getExe pkgs.grim} -t ppm -g "$region" "$shot" || exit 1
    {
      ${lib.getExe pkgs.grim} -l 1 -g "$region" - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
      kill "$picker" 2>/dev/null
    } &

    GSK_RENDERER=gl GTK_THEME=Adwaita ${lib.getExe pkgs.satty} \
      --filename "$shot" \
      --copy-command ${pkgs.wl-clipboard}/bin/wl-copy \
      --output-filename "$dir/screenshot-%Y%m%d-%H%M%S.png" \
      --early-exit
  '';
in
{
  home.packages = with pkgs; [
    screenshot
    satty
    awww
    grimblast
    hyprpicker
    grim
    slurp
    wl-clip-persist
    cliphist
    wf-recorder
    glib
    wayland
    direnv
    tesseract
    hyprshade
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    # Конфиг на Lua: ~/.config/hypr/hyprland.lua + подключаемые файлы (binds, rules, startup…).
    # В Hyprland 0.57 поддержку hyprland.conf убирают.
    configType = "lua";
    package = null;
    portalPackage = null;

    xwayland = {
      enable = true;
      # hidpi = true;
    };

    # Правило для пустых окон XWayland (было здесь, в extraConfig) — теперь в rules.lua:
    # в Lua-режиме extraConfig вставляется как Lua, а не как строки hyprland.conf.

    # enableNvidiaPatches = false;
    systemd.enable = true;
    # При входе home-manager передаёт окружение в systemd и D-Bus. «--all» — всё окружение
    # (GTK_THEME, QT_*, no_proxy из variables.nix), как делала строка
    # «dbus-update-activation-environment --all --systemd …» в старом exec-once.
    systemd.variables = [ "--all" ];
  };
}
