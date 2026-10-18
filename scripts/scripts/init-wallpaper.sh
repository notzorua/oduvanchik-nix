#!/usr/bin/env bash

# init-wallpaper           — поставить текущие обои (~/Pictures/wallpapers/wallpaper)
# init-wallpaper --random  — сначала выбрать случайную картинку из wallpapers/ репозитория (без подпапок)

wallpaper_path="$HOME/Pictures/wallpapers"
repo_folder="$wallpaper_path/repo" # home.file в modules/home/waypaper.nix

transition=(-t none)
if [[ "$1" == "--random" ]]; then
    # -L: repo — ссылка в /nix/store; путь остаётся через ~/…/repo, чтобы ссылку не сломала сборка мусора.
    # -maxdepth 1: только корень wallpapers/, подпапки не трогаем (lock/ — фон hyprlock).
    new_wallpaper=$(find -L "$repo_folder" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
    if [[ -n "$new_wallpaper" ]]; then
        ln -sfn "$new_wallpaper" "$wallpaper_path/wallpaper"
        transition=(--transition-type fade --transition-duration 1)
    fi
fi

# Start awww daemon if not running
if ! pgrep -x awww-daemon > /dev/null; then
    awww-daemon --no-cache &

    # Wait until the daemon is ready
    while ! awww query > /dev/null 2>&1; do
        sleep 0.1
    done
fi

# Set wallpaper
awww img "${transition[@]}" "$wallpaper_path/wallpaper" &
