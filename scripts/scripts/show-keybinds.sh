#!/usr/bin/env bash

# Список привязок в rofi (SUPER + F1).
# Раньше читали строки bind= из hyprland.conf. С Lua-конфигом этого файла нет, а у Lua-привязок
# hyprctl binds вместо команды показывает «__lua» — поэтому берём описания (description),
# которые задаются в binds.lua и swayosd.nix. Привязки без описания не показываем.

if pgrep -x rofi > /dev/null; then
    pkill rofi
    exit 0
fi

# modmask — число, где каждый модификатор — свой бит: SHIFT = 1, CAPS = 2, CTRL = 4, ALT = 8,
# SUPER = 64. Собираем из него «SUPER + SHIFT + …».
keybinds=$(hyprctl binds -j | jq -r '
    def bit($n): (. / $n | floor) % 2 == 1;
    .[]
    | select(.has_description)
    | . as $b
    | $b.modmask
    | [ (if bit(64) then "SUPER" else empty end),
        (if bit(4)  then "CTRL"  else empty end),
        (if bit(8)  then "ALT"   else empty end),
        (if bit(1)  then "SHIFT" else empty end),
        (if bit(2)  then "CAPS"  else empty end),
        $b.key ]
    | "\(join(" + ")) — \($b.description)"')

rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' -p "Keybinds" <<< "$keybinds"
