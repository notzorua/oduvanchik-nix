#!/usr/bin/env bash

# В Lua-режиме «hyprctl keyword» не работает — переключаем прямо в Lua.
# Как было: если прозрачность 1 — поставить 0.90 обоим окнам, иначе вернуть 1.
hyprctl eval '
local o = hl.get_config("decoration.active_opacity") == 1 and 0.9 or 1
hl.config({ decoration = { active_opacity = o, inactive_opacity = o } })
' > /dev/null
