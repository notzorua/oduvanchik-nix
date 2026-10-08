#!/usr/bin/env bash

# В Lua-режиме «hyprctl keyword» не работает, а getoption отвечает «bool: true», а не «int: 1».
# Поэтому переключаем прямо в Lua: прочитать значение и записать обратное.
hyprctl eval 'hl.config({ decoration = { blur = { enabled = not hl.get_config("decoration.blur.enabled") } } })' > /dev/null
