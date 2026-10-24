{ pkgs, lib, ... }:
let
  # Запасной фон — вшитая копия (в /nix/store), если в рабочей папке картинок нет.
  fallback = ../../../wallpapers/lock/lock.png;

  # lock — случайный фон из wallpapers/lock рабочей копии репозитория (без git и пересборки)
  # → ссылка ~/.cache/lock-bg (её читает hyprlock) → hyprlock.
  lock = pkgs.writeShellApplication {
    name = "lock";
    runtimeInputs = with pkgs; [
      hyprlock
      coreutils
      findutils
      procps
    ];
    text = ''
      # уже заблокировано (например, suspend из power-menu на заблокированном экране)
      if pidof hyprlock > /dev/null; then
        exit 0
      fi

      dir="$HOME/nixos-configuration/wallpapers/lock"
      bg=""
      if [[ -d "$dir" ]]; then
        bg=$(find -L "$dir" -maxdepth 1 -type f \
          \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | shuf -n 1)
      fi

      mkdir -p "$HOME/.cache"
      ln -sfn "''${bg:-${fallback}}" "$HOME/.cache/lock-bg"

      exec hyprlock
    '';
  };
in
{
  home.packages = [ lock ];

  # Только блокировка перед сном и по loginctl lock-session — без таймеров простоя.
  services.hypridle = {
    enable = true;
    settings.general = {
      lock_cmd = lib.getExe lock;
      before_sleep_cmd = lib.getExe lock;
    };
  };

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
          path = "~/.cache/lock-bg"; # ставит скрипт lock (выше); ~ hyprlock раскрывает сам
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
