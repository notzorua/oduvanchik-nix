{ pkgs, lib, ... }:
let
  # Скриншот как в ShareX (клавиша Print, binds.lua): grim снимает весь экран, satty открывает
  # снимок на весь экран с инструментом обрезки. Enter/кнопка копирования — wl-copy в буфер;
  # сохранение — в ~/Pictures/Screenshots. --early-exit — закрыть satty сразу после
  # копирования/сохранения. Флаги сверены с satty 0.22.0 --help.
  # --early-exit стоит последним: он принимает необязательные значения (all/copy/save…)
  # и «съел» бы следующий аргумент. Пути к программам — из Nix, скрипт не зависит от PATH.
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    ${lib.getExe pkgs.grim} - | ${lib.getExe pkgs.satty} \
      --filename - \
      --fullscreen \
      --initial-tool crop \
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
