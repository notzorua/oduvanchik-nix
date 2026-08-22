{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    binds = {
      scroll_event_delay = 100;
      movefocus_cycles_fullscreen = true;
    };

    bind = [
      # show keybinds list
      "SUPER, F1, exec, show-keybinds"

      # keybindings
      "SUPER, Return, exec, ghostty --gtk-single-instance=true"
      "ALT, Return, exec, [float; size 1111 700] ghostty"
      "SUPER SHIFT, Return, exec, [fullscreen] ghostty"
      "SUPER, B, exec, [workspace 1 silent] zen-beta"
      "SUPER, Q, killactive,"
      "SUPER, F, fullscreen, 0"
      "SUPER SHIFT, F, fullscreenstate, 2"
      "SUPER, Space, exec, toggle-float"
      "SUPER, D, exec, toggle-rofi rofi -show drun"
      "SUPER SHIFT, D, exec, vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland"
      "SUPER SHIFT, S, exec, hyprctl dispatch exec '[workspace 5 silent] SoundWireServer'"
      "ALT, Escape, exec, hyprlock"
      "SUPER SHIFT, Escape, exec, power-menu"
      "SUPER, P, pseudo,"
      "SUPER, X, layoutmsg, togglesplit"
      "SUPER, T, exec, toggle-oppacity"
      "SUPER, E, exec, nemo"
      "ALT, E, exec, hyprctl dispatch exec '[float; size 1111 700] nemo'"
      "SUPER SHIFT, B, exec, toggle-waybar"
      "SUPER, C ,exec, hyprpicker -a"
      "SUPER, W,exec, wallpaper-picker"
      "SUPER SHIFT, W,exec, hyprctl dispatch exec '[float; size 925 615] waypaper'"
      "SUPER, N, exec, swaync-client -t -sw"
      "CTRL SHIFT, Escape, exec, hyprctl dispatch exec '[workspace 9] missioncenter'"
      "SUPER, equal, exec, woomer"
      # "SUPER SHIFT, W, exec, vm-start"

      # screenshot      # OCR
      
      ", F11, exec, grim - | wl-copy"
      # "SUPER SHIFT, F11, exec, screenshot --swappy"
      "CTRL, F11, exec, grim -g \"$(slurp)\" - | satty --filename - --fullscreen --early-exit --copy-command \"wl-copy\" && wl-paste | wl-copy"

      "SUPER CTRL, O, exec, ocr"

      # switch focus
      "SUPER, left,  movefocus, l"
      "SUPER, right, movefocus, r"
      "SUPER, up,    movefocus, u"
      "SUPER, down,  movefocus, d"
      "SUPER, h, movefocus, l"
      "SUPER, j, movefocus, d"
      "SUPER, k, movefocus, u"
      "SUPER, l, movefocus, r"

      "SUPER, left,  alterzorder, top"
      "SUPER, right, alterzorder, top"
      "SUPER, up,    alterzorder, top"
      "SUPER, down,  alterzorder, top"
      "SUPER, h, alterzorder, top"
      "SUPER, j, alterzorder, top"
      "SUPER, k, alterzorder, top"
      "SUPER, l, alterzorder, top"

      "CTRL ALT, up, exec, hyprctl dispatch focuswindow floating"
      "CTRL ALT, down, exec, hyprctl dispatch focuswindow tiled"

      # switch workspace
      "SUPER, 1, workspace, 1"
      "SUPER, 2, workspace, 2"
      "SUPER, 3, workspace, 3"
      "SUPER, 4, workspace, 4"
      "SUPER, 5, workspace, 5"
      "SUPER, 6, workspace, 6"
      "SUPER, 7, workspace, 7"
      "SUPER, 8, workspace, 8"
      "SUPER, 9, workspace, 9"
      "SUPER, 0, workspace, 10"

      # same as above, but switch to the workspace
      "SUPER SHIFT, 1, movetoworkspacesilent, 1" # movetoworkspacesilent
      "SUPER SHIFT, 2, movetoworkspacesilent, 2"
      "SUPER SHIFT, 3, movetoworkspacesilent, 3"
      "SUPER SHIFT, 4, movetoworkspacesilent, 4"
      "SUPER SHIFT, 5, movetoworkspacesilent, 5"
      "SUPER SHIFT, 6, movetoworkspacesilent, 6"
      "SUPER SHIFT, 7, movetoworkspacesilent, 7"
      "SUPER SHIFT, 8, movetoworkspacesilent, 8"
      "SUPER SHIFT, 9, movetoworkspacesilent, 9"
      "SUPER SHIFT, 0, movetoworkspacesilent, 10"
      "SUPER CTRL, c, movetoworkspace, empty"

      # window control
      "SUPER SHIFT, left, movewindow, l"
      "SUPER SHIFT, right, movewindow, r"
      "SUPER SHIFT, up, movewindow, u"
      "SUPER SHIFT, down, movewindow, d"
      "SUPER SHIFT, h, movewindow, l"
      "SUPER SHIFT, j, movewindow, d"
      "SUPER SHIFT, k, movewindow, u"
      "SUPER SHIFT, l, movewindow, r"

      "SUPER CTRL, left, resizeactive, -80 0"
      "SUPER CTRL, right, resizeactive, 80 0"
      "SUPER CTRL, up, resizeactive, 0 -80"
      "SUPER CTRL, down, resizeactive, 0 80"
      "SUPER CTRL, h, resizeactive, -80 0"
      "SUPER CTRL, j, resizeactive, 0 80"
      "SUPER CTRL, k, resizeactive, 0 -80"
      "SUPER CTRL, l, resizeactive, 80 0"

      "SUPER ALT, left, moveactive,  -80 0"
      "SUPER ALT, right, moveactive, 80 0"
      "SUPER ALT, up, moveactive, 0 -80"
      "SUPER ALT, down, moveactive, 0 80"
      "SUPER ALT, h, moveactive,  -80 0"
      "SUPER ALT, j, moveactive, 0 80"
      "SUPER ALT, k, moveactive, 0 -80"
      "SUPER ALT, l, moveactive, 80 0"

      # media and volume controls
      ", XF86AudioPlay,exec, playerctl play-pause"
      ", XF86AudioNext,exec, playerctl next"
      ", XF86AudioPrev,exec, playerctl previous"
      ", XF86AudioStop,exec, playerctl stop"

      "SUPER, mouse_down, workspace, e-1"
      "SUPER, mouse_up, workspace, e+1"

      # clipboard manager
      "SUPER, V, exec, toggle-rofi \"cliphist list | rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' | cliphist decode | wl-copy\""
    ];

    # mouse binding
    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];
  };
}
