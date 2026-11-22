# Resolve the Bluetooth profile suffix at the time of each operation.
snapshot() {
  local sinks
  sinks=$(pactl --format=json list sinks) || return
  jq -c '
    def output(matches):
      [.[] | select(.name | matches) | {
        name, muted: .mute,
        volume: ([.volume[].value_percent | rtrimstr("%") | tonumber] | add / length | round)
      }][0];
    {
      speakers: output(. == "alsa_output.pci-0000_00_1f.3.analog-stereo"),
      headphones: output(startswith("bluez_output.14_0A_29_EB_04_97.")),
      combined: output(. == "combine_speakers_headphones")
    } | with_entries(select(.value != null))
  ' <<< "$sinks"
}

if [[ ${1:-} == watch ]]; then
  subscriber=""
  trap 'if [[ -n $subscriber ]]; then kill "$subscriber" 2>/dev/null || true; fi; exit 0' TERM INT HUP PIPE
  while true; do
    exec 3< <(exec pactl subscribe)
    subscriber=$!
    snapshot || printf '{}\n'
    while IFS= read -r event <&3; do
      case "$event" in
        *" on sink #"* | *" on server "*) snapshot || printf '{}\n' ;;
      esac
    done
    exec 3<&-
    wait "$subscriber" || true
    subscriber=""
    printf '{}\n'
    sleep 1
  done
fi

state=$(snapshot)
case "${1:-}" in
  balance)
    # Matching percentages is a manual adjustment. Preserve the mute of each output.
    read -r name volume < <(jq -er '
      select(.speakers and .headphones)
      | [.speakers, .headphones] | sort_by(.volume)
      | [.[1].name, .[0].volume] | @tsv
    ' <<< "$state")
    pactl set-sink-volume "$name" "$volume%"
    ;;
  up | down | toggle)
    read -r name volume < <(jq -er --arg id "${2:-}" '
      select($id == "speakers" or $id == "headphones")
      | .[$id] // empty | [.name, .volume] | @tsv
    ' <<< "$state")
    case "$1" in
      toggle) pactl set-sink-mute "$name" toggle ;;
      up)
        if (( volume < 100 )); then
          next=$((volume + 5))
          pactl set-sink-volume "$name" "$((next > 100 ? 100 : next))%"
        fi
        ;;
      down) pactl set-sink-volume "$name" "$((volume < 5 ? 0 : volume - 5))%" ;;
    esac
    ;;
  *) exit 2 ;;
esac
