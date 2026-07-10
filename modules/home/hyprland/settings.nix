{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    input = {
      kb_layout = "us,ru";
      kb_options = "grp:alt_caps_toggle";

      repeat_delay = 300;
      numlock_by_default = true;

      follow_mouse = 0;
      mouse_refocus = 0;
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

      "col.active_border" = "rgb(504945) rgb(7C6F64) rgb(A89984) rgb(7C6F64) 45deg";
      "col.inactive_border" = "rgb(282828)";    };

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
      rounding = 8;  # ← было 0, теперь скругление

      blur = {
        enabled = true;
        size = 3;
        noise = 0.05;
        passes = 2;
        contrast = 1.2;
        brightness = 0.9;
        xray = false;  # ← выключи xray для красивого блюра
      };

      shadow = {
        enabled = true;
        range = 30;
        render_power = 4;
        offset = "0 4";
        color = "rgba(00000088)";  # ← потемнее тень
      };
    };
    animations = {
      enabled = false;

      bezier = [
        "fluent_decel, 0, 0.2, 0.4, 1"
        "easeOutCirc, 0, 0.55, 0.45, 1"
        "easeOutCubic, 0.33, 1, 0.68, 1"
        "fade_curve, 0, 0.55, 0.45, 1"
        "easeInOutBack, 0.68, -0.6, 0.32, 1.6"
        "bounce, 0.175, 0.885, 0.32, 1.275"
      ];

      animation = [
    # Окна открываются снизу с пружиной
        "windowsIn,   1, 4, bounce, popin 60%"
    # Окна закрываются с затуханием
        "windowsOut,  1, 3, easeOutCubic, popin 80%"
    # Перемещение окон
        "windowsMove, 1, 3, easeInOutBack, slide"

    # Fade
        "fadeIn,      1, 3, fade_curve"
        "fadeOut,     1, 3, fade_curve"
        "fadeSwitch,  1, 2, easeOutCirc"
        "fadeShadow,  1, 6, easeOutCirc"
        "fadeDim,     1, 4, fluent_decel"

        # Анимация бордера
        "border,      1, 3, easeOutCirc"
        "borderangle, 1, 60, fluent_decel, loop"

        # Переключение воркспейсов со слайдом
        "workspaces,  1, 4, easeOutCubic, slidefade 30%"
      ];
    };
    xwayland = {
      force_zero_scaling = true;
    };
  };
}
	 
