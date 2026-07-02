{ host, ... }:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
        fractional_scaling = 0;
      };

      background = [
        {
          path = "${../../../wallpapers/otherWallpaper/gruvbox/forest_road.jpg}";
          color = "rgba(29, 32, 33, 255)";
          blur_passes = 0;
          vibrancy_darkness = 0.0;
        }
      ];

      label = [
        {
          text = ''cmd[update:1000] echo "$(date +'%H:%M')"'';
          font_size = 120;
          font_family = "Maple Mono Bold";
          shadow_passes = 0;
          shadow_boost = 2.0;
          shadow_color = "rgba(0, 0, 0, 0.8)";
          color = "rgba(0, 0, 0, 1.0)";
          position = "0, -120";
          halign = "center";
          valign = "top";
        }
        {
          text = ''cmd[update:1000] echo "$(date +'%A, %d %B')"'';
          font_size = 20;
          font_family = "Maple Mono";
          shadow_passes = 0;
          shadow_boost = 2.0;
          shadow_color = "rgba(0, 0, 0, 0.8)";
          color = "rgba(0, 0, 0, 0.7)";
          position = "0, -320";
          halign = "center";
          valign = "top";
        }
      ];

      input-field = [
        {
          size = "280, 46";
          rounding = 8;
          outline_thickness = 1;
          dots_spacing = 0.35;
          dots_size = 0.25;
          font_color = "rgba(235, 219, 178, 0.9)";
          font_family = "Maple Mono";
          outer_color = "rgba(80, 73, 69, 0.8)";
          inner_color = "rgba(29, 32, 33, 0.85)";
          check_color = "rgba(152, 151, 26, 0.9)";
          fail_color = "rgba(204, 36, 29, 0.9)";
          capslock_color = "rgba(215, 153, 33, 0.9)";
          hide_input = false;
          fade_on_empty = true;
          placeholder_text = ''<span foreground="##928374">password...</span>'';
          position = "0, 210";
          halign = "center";
          valign = "bottom";
        }
      ];

      animation = [ "inputFieldColors, 0" ];
    };
  };
}
