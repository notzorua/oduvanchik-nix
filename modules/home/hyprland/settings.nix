{ ... }:
{
  # Настройки Hyprland. В Lua-режиме home-manager превращает каждый ключ settings в вызов
  # hl.<ключ>(…): settings.config = { … } → hl.config({ … }). Вложенность та же, что была,
  # но ключи с точкой («col.active_border») стали вложенными таблицами (col = { active_border }).
  # Кривые и анимации — вызовы функций, они в animations.lua.
  wayland.windowManager.hyprland = {
    extraLuaFiles.animations.content = ./animations.lua;

    settings.config = {
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_caps_toggle";

        repeat_delay = 300;
        numlock_by_default = true;

        follow_mouse = 0;
        mouse_refocus = false; # было 0: в Lua этот параметр логический
        float_switch_override_focus = 0;

        touchpad = {
          disable_while_typing = false;
          natural_scroll = true;
        };
      };

      general = {
        layout = "dwindle";

        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;

        col = {
          # было "rgb(504945) rgb(7C6F64) rgb(A89984) rgb(7C6F64) 45deg"
          active_border = {
            colors = [
              "rgb(504945)"
              "rgb(7C6F64)"
              "rgb(A89984)"
              "rgb(7C6F64)"
            ];
            angle = 45;
          };
          inactive_border = "rgb(282828)";
        };
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = false;

        focus_on_activate = false;
        middle_click_paste = false;

        disable_autoreload = false;
      };

      dwindle = {
        force_split = 2;
        preserve_split = true;
        use_active_for_splits = true;
      };

      master = {
        new_status = "master";
      };

      decoration = {
        rounding = 8;

        blur = {
          enabled = true;
          size = 3;
          noise = 0.05;
          passes = 2;
          contrast = 1.2;
          brightness = 0.9;
          xray = false;
        };

        shadow = {
          enabled = true;
          range = 30;
          render_power = 4;
          offset = "0 4";
          color = "rgba(00000088)";
        };
      };

      # Анимации выключены; сами кривые и анимации описаны в animations.lua.
      animations.enabled = false;

      xwayland.force_zero_scaling = true;
    };
  };
}
