{
  config,
  roseFrost,
  pkgs,
  lib,
  ...
}:
let
  # Запасной фон — вшитая копия (в /nix/store), если в рабочей папке картинок нет.
  fallback = ../../../wallpapers/lock/lock.png;

  lockState = "${config.xdg.stateHome}/hyprlock";
  lockImage = "${lockState}/background";
  lockCollection = "${config.home.homeDirectory}/nixos-configuration/wallpapers/lock";
  lockWallpaper = pkgs.writeShellApplication {
    name = "lock-wallpaper";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      fixed=${lib.escapeShellArg "${lockState}/fixed-background"}
      case "$#" in
        0)
          random=TRUE
          pinned=FALSE
          if [[ -f "$fixed" && -r "$fixed" ]]; then
            random=FALSE
            pinned=TRUE
          fi
          mode=$(LC_ALL=C ${lib.getExe pkgs.zenity} --list --radiolist \
            --title="Lock screen wallpaper" \
            --text="Choose the wallpaper mode for the next lock." \
            --column="Selected" --column="Mode" --print-column=2 --hide-header \
            "$random" "Random" "$pinned" "Fixed image") || exit 0
          case "$mode" in
            Random)
              rm -f -- "$fixed"
              exit 0
              ;;
            "Fixed image") ;;
            *) exit 0 ;;
          esac
          image=$(LC_ALL=C ${lib.getExe pkgs.zenity} --file-selection \
            --title="Lock screen wallpaper" \
            --filename=${lib.escapeShellArg "${lockCollection}/"} \
            --file-filter='Images | *.png *.jpg *.jpeg *.webp *.PNG *.JPG *.JPEG *.WEBP') || exit 0
          ;;
        1)
          if [[ "$1" == --random ]]; then
            rm -f -- "$fixed"
            exit 0
          fi
          image=$1
          ;;
        *) echo "Usage: lock-wallpaper [--random | image]" >&2; exit 2 ;;
      esac
      if [[ ! -f "$image" || ! -r "$image" ]]; then
        echo "Cannot read the image: $image" >&2
        exit 1
      fi
      image=$(realpath -e -- "$image")
      mkdir -p -- "$(dirname -- "$fixed")"
      ln -sfnT -- "$image" "$fixed"
    '';
  };

  lock = pkgs.writeShellApplication {
    name = "lock";
    runtimeInputs =
      with pkgs;
      [
        hyprlock
        coreutils
        findutils
        procps
      ]
      ++ lib.optional roseFrost pkgs.util-linuxMinimal;
    text = ''
      # уже заблокировано (например, suspend из power-menu на заблокированном экране)
      if pidof hyprlock > /dev/null; then
        exit 0
      fi

      ${
        if roseFrost then
          ''
            state=${lib.escapeShellArg lockState}
            target=${lib.escapeShellArg lockImage}
            collection=${lib.escapeShellArg lockCollection}

            # Serialize Hypridle's lock and before-sleep callbacks until Hyprlock exits.
            if ! mkdir -p -- "$state" || ! { exec 9>"$state/session.lock"; }; then
              exec hyprlock
            fi
            flock --nonblocking --conflict-exit-code 75 9 || {
              if [[ $? -eq 75 ]]; then
                exit 0
              fi
              exec hyprlock
            }

            if ! image=$(realpath -e -- "$state/fixed-background" 2>/dev/null) ||
              [[ ! -f "$image" || ! -r "$image" ]]; then
              images=()
              if [[ -d "$collection" ]]; then
                mapfile -d "" -t images < <(find -L "$collection" -maxdepth 1 -type f -readable \
                  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)
              fi
              choices=()
              for candidate in "''${images[@]}"; do
                if [[ ! "$candidate" -ef "$target" ]]; then
                  choices+=("$candidate")
                fi
              done
              if (( ''${#choices[@]} > 0 )); then
                IFS= read -r -d "" image < <(printf '%s\0' "''${choices[@]}" | shuf -z -n 1) || image=${fallback}
              else
                image="''${images[0]:-${fallback}}"
              fi
            fi
            # The picker only sets a preference. Only a new lock can update the current image.
            ln -sfnT -- "$image" "$target" || true
          ''
        else
          ''
            dir="$HOME/nixos-configuration/wallpapers/lock"
            bg=""
            if [[ -d "$dir" ]]; then
              bg=$(find -L "$dir" -maxdepth 1 -type f \
                \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | shuf -n 1)
            fi

            mkdir -p "$HOME/.cache"
            ln -sfn "''${bg:-${fallback}}" "$HOME/.cache/lock-bg"

          ''
      }
      exec hyprlock
    '';
  };
in
{
  home.packages = [ lock ] ++ lib.optional roseFrost lockWallpaper;

  wayland.windowManager.hyprland.extraLuaFiles.lockWallpaper = lib.mkIf roseFrost {
    content = ''
      hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("${lib.getExe lockWallpaper}"), {
        description = "Choose random or fixed lock screen wallpaper",
      })
    '';
  };

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

    }
    // (
      if roseFrost then
        {
          background = [
            {
              path = lockImage;
              color = "rgb(201D27)";
              blur_passes = 0;
              brightness = 1.0;
              contrast = 1.0;
            }
          ];

          label = [
            {
              text = "cmd[update:1000] ${pkgs.coreutils}/bin/date '+%H:%M' ";
              font_family = "DejaVu Sans";
              font_size = 120;
              color = "rgb(FFF1F7)";
              shadow_passes = 2;
              shadow_size = 5;
              shadow_color = "rgba(160E1AF5)";
              halign = "left";
              valign = "center";
              position = "8%, 8%";
            }
            {
              text = "cmd[update:60000] LC_ALL=C ${pkgs.coreutils}/bin/date '+%A, %-d %B' ";
              font_family = "DejaVu Sans";
              font_size = 19;
              color = "rgb(D4C5E9)";
              shadow_passes = 2;
              shadow_size = 4;
              shadow_color = "rgba(160E1AF5)";
              halign = "left";
              valign = "center";
              position = "8%, -5%";
            }
          ];

          input-field = [
            {
              size = "272, 46";
              halign = "left";
              valign = "bottom";
              position = "8%, 10%";
              rounding = 12;
              outline_thickness = 1;
              inner_color = "rgba(241A2ADB)";
              outer_color = "rgb(F2A9C3) rgb(D4C5E9) 30deg";
              font_family = "DejaVu Sans";
              font_color = "rgb(FFF1F7)";
              check_color = "rgb(D4C5E9)";
              fail_color = "rgb(F1A2B0)";
              capslock_color = "rgb(E2BD97)";
              dots_size = 0.22;
              dots_spacing = 0.35;
              fade_on_empty = false;
              placeholder_text = "Password";
              fail_text = "Try again";
            }
          ];

          animations = {
            enabled = true;
            bezier = [ "frostEase, 0.22, 1, 0.36, 1" ];
            animation = [
              "fadeIn, 1, 3, frostEase"
              "fadeOut, 1, 2, frostEase"
              "inputFieldColors, 1, 2, frostEase"
            ];
          };
        }
      else
        {
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
        }
    );
  };
}
