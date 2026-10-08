#!/usr/bin/env bash

# В Lua-режиме Hyprland «hyprctl dispatch X» выполняет Lua: hl.dispatch(X).
# Было: togglefloating / resizeactive exact 1111 700 / centerwindow.
hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })'
hyprctl dispatch 'hl.dsp.window.resize({ x = 1111, y = 700 })' # без relative — точный размер
hyprctl dispatch 'hl.dsp.window.center()'
