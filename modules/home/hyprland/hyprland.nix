{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # tray icon support (like battle.net)
    swww
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
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    xwayland = {
      enable = true;
      # hidpi = true;
    };

    extraConfig = ''
    # Hide XWayland helper windows that have an empty title (common for Wine tray/menu helpers)
    windowrule = match:xwayland true, match:title ^$, match:class ^$, match:initial_class ^$, match:initial_title ^$, opacity 0.0, float true, no_blur on
    '';
    
    # enableNvidiaPatches = false;
    systemd.enable = true;
  };
}
