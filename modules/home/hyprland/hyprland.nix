{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #screenshot
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
    configType = "hyprlang";
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
  };
}
