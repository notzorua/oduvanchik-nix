# Громкость колонок и наушников отдельными модулями — только stem (выбор модулей по хосту —
# в settings.nix, на fluff остаётся обычный pulseaudio).
#
# Встроенного способа нет: модули wireplumber и pulseaudio Waybar 0.15 следят только за выходом
# по умолчанию (man waybar-wireplumber: node-type/only-physical, выбора узла по имени нет).
# wpctl 0.5.18 тоже не годится: ID — только номер или @DEFAULT_AUDIO_SINK@, а номера меняются
# при переподключении. pamixer --sink принимает имя выхода; для несуществующего — код 3.
#
# waybar-volume watch <speakers|headphones> — JSON для Waybar при каждом событии
# `pactl subscribe` (изменился выход или сервер), без опроса по таймеру. Наушники отключены —
# пустой text, Waybar скрывает модуль. В подсказке — и громкость «Speakers + Headphones»
# (у объединённого выхода своя громкость; удобнее держать её 100% и крутить устройства).
# pactl — из pkgs.pulseaudio по пути (в PATH не добавляем), работает через pipewire-pulse.
{
  pkgs,
  lib,
  host,
  ...
}:
let
  blue = "#458588"; # custom.blue в settings.nix

  waybar-volume = pkgs.writeShellScriptBin "waybar-volume" ''
    pactl=${pkgs.pulseaudio}/bin/pactl
    pamixer=${lib.getExe pkgs.pamixer}
    jq=${lib.getExe pkgs.jq}
    combine=combine_speakers_headphones

    # Имя выхода: колонки — точное, наушники — по MAC (суффикс .1 — номер профиля, меняется).
    sink() {
      case "$1" in
        speakers) echo alsa_output.pci-0000_00_1f.3.analog-stereo ;;
        headphones)
          "$pactl" list sinks short |
            ${lib.getExe pkgs.gawk} 'index($2, "bluez_output.14_0A_29_EB_04_97.") == 1 { print $2; exit }'
          ;;
      esac
    }

    show() {
      local kind=$1 name vol mute icon label class="" combine_vol
      name=$(sink "$kind")
      if [ -z "$name" ] || ! vol=$("$pamixer" --sink "$name" --get-volume 2>/dev/null); then
        echo '{"text":""}'
        return
      fi
      mute=$("$pamixer" --sink "$name" --get-mute 2>/dev/null)
      case "$kind" in
        speakers) label="Колонки"; icon=󰓃; [ "$mute" = true ] && icon=󰓄 ;;
        headphones) label="Наушники"; icon=󰋋; [ "$mute" = true ] && icon=󰟎 ;;
      esac
      [ "$mute" = true ] && class=muted
      tooltip="$label: $vol%$([ "$mute" = true ] && echo ' (без звука)')"
      if combine_vol=$("$pamixer" --sink "$combine" --get-volume-human 2>/dev/null); then
        tooltip="$tooltip"$'\n'"Speakers + Headphones: $combine_vol"
      fi
      "$jq" -cn --arg text "<span foreground='${blue}'>$icon </span>$vol%" \
        --arg tooltip "$tooltip" --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}'
    }

    cmd=$1 kind=$2
    case "$cmd" in
      watch)
        # Не конвейером `pactl subscribe | while …`: когда Waybar убивают (toggle-waybar.sh —
        # pkill -9), сигнал получает только этот процесс, а pactl и подоболочка цикла
        # оставались сиротами. Здесь цикл — в самом скрипте, pactl — подстановкой процесса,
        # и trap его убивает (read прерывается сигналом, на который стоит trap).
        sub=""
        trap '[ -n "$sub" ] && kill "$sub" 2>/dev/null; exit 0' TERM INT HUP PIPE
        # pactl subscribe завершится, если перезапустят pipewire-pulse, — тогда заново.
        while true; do
          show "$kind"
          exec 3< <(exec "$pactl" subscribe)
          sub=$!
          while read -r line <&3; do
            case "$line" in
              *" on sink #"* | *" on server "*) show "$kind" ;;
            esac
          done
          exec 3<&-
          sleep 1
        done
        ;;
      mixer)
        # pavucontrol — один экземпляр (GtkApplication): повторный запуск только «активирует»
        # уже открытое окно, а Hyprland на это фокус не переводит — ПКМ «ничего не делал»,
        # если окно было на другом рабочем столе. Поэтому: окно есть — фокус на него, нет —
        # запуск. hyprctl — из PATH (Hyprland системный); на ненайденное окно он отвечает
        # кодом 0, поэтому наличие проверяем заранее.
        if hyprctl clients -j | "$jq" -e 'any(.[]; .class == "org.pulseaudio.pavucontrol")' >/dev/null; then
          hyprctl dispatch 'hl.dsp.focus({ window = "class:^(org.pulseaudio.pavucontrol)$" })' >/dev/null
        else
          exec ${lib.getExe pkgs.pavucontrol}
        fi
        ;;
      up | down | toggle)
        name=$(sink "$kind")
        [ -n "$name" ] || exit 0
        case "$cmd" in
          up) "$pamixer" --sink "$name" -i 1 ;;
          down) "$pamixer" --sink "$name" -d 1 ;;
          toggle) "$pamixer" --sink "$name" -t ;;
        esac
        ;;
      *)
        echo "usage: waybar-volume watch|up|down|toggle speakers|headphones | mixer" >&2
        exit 1
        ;;
    esac
  '';

  module = kind: {
    exec = "${lib.getExe waybar-volume} watch ${kind}";
    return-type = "json";
    on-scroll-up = "${lib.getExe waybar-volume} up ${kind}";
    on-scroll-down = "${lib.getExe waybar-volume} down ${kind}";
    on-click = "${lib.getExe waybar-volume} toggle ${kind}";
    on-click-right = "${lib.getExe waybar-volume} mixer";
  };
in
lib.mkIf (host == "stem") {
  programs.waybar.settings.mainBar = {
    "custom/volume-speakers" = module "speakers";
    "custom/volume-headphones" = module "headphones";
  };
}
