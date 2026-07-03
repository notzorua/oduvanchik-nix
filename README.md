<div align="center">

# oduvanchik-nix

[![Stars](https://img.shields.io/github/stars/iZ0rua/oduvanchik-nix?color=FABD2F&labelColor=282828&style=for-the-badge&logo=starship&logoColor=FABD2F)](https://github.com/iZ0rua/oduvanchik-nix/stargazers)
[![Repo size](https://img.shields.io/github/repo-size/iZ0rua/oduvanchik-nix?color=FE8019&labelColor=282828&style=for-the-badge&logo=github&logoColor=FE8019)](https://github.com/iZ0rua/oduvanchik-nix)
[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=282828&logo=NixOS&logoColor=458588&color=458588)](https://nixos.org)

</div>

Мой конфиг NixOS + Hyprland. Этот репозиторий вырос из форка [adarkaz/nixos-configuration](https://github.com/adarkaz/nixos-configuration), которым я пользуюсь и постепенно допиливаю под себя.

Конфиг великолепный, крутой и лучший и ещё вооот такой

```
	zoroa @ desktop
	─────────────────
	OS      NixOS (unstable)
	WM      Hyprland
	Shell   zsh
	Theme   Gruvbox Dark Hard
	Bar     Waybar
	Term    Ghostty
```

## Стек

Композитор — Hyprland, панель — Waybar (у меня снизу, не как обычно рисуют в туториалах). Лаунчер — Rofi, терминал — Ghostty, шелл — zsh. Редактор — VSCodium, потому что привык. Блокировка через Hyprlock, уведомления — SwayNC, файлы гоняю через Nemo. Тема — Gruvbox Dark Hard, отсюда и название репозитория, если что.

## Структура

```
.
├── flake.nix                    # точка входа, хосты (desktop/laptop)
├── hosts/
│   └── desktop/
│       ├── default.nix          # настройки конкретно этой машины
│       └── hardware-configuration.nix
└── modules/
    ├── core/                    # steam и прочее системное
    └── home/
        ├── hyprland/
        │   ├── binds.nix        # горячие клавиши
        │   ├── settings.nix
        │   ├── windowrules.nix
        │   └── monitors.nix
        ├── waybar/
        ├── ghostty/
        ├── zsh/
        ├── ssh.nix
        └── vscode.nix
```

## Keybinds

Полный список можно вызвать прямо в системе — `$mod F1`. Но вот то, чем пользуюсь каждый день:

| Клавиши | Что делает |
|---|---|
| `$mod + Return` | терминал |
| `$mod + B` | браузер |
| `$mod + D` | rofi |
| `$mod + E` | файловый менеджер |
| `$mod + Space` | float/tile для активного окна |
| `$mod + F` / `$mod Shift + F` | fullscreen / maximize, разница на самом деле в waybar (в первом случае скрывается) |
| `$mod + [0-9]` | переключиться на воркспейс |
| `$mod Shift + [0-9]` | закинуть окно на воркспейс, не переключаясь самому |
| `$mod + hjkl` | прыгнуть фокусом на соседнее окно, vim-стиль |
| `$mod Shift + hjkl` | поменять окно местами с соседним |
| `$mod Ctrl + hjkl` | ресайз активного окна |
| `Alt + Escape` | экран блокировки |

Остальное — в [binds.nix](modules/home/hyprland/binds.nix), там же кастомные скрипты типа wallpaper-picker и color picker.

## Баги, с которыми уже столкнулся

Не столько фичи репозитория, сколько заметки самому себе, чтобы не наступать на те же грабли второй раз.

Steam кладёт уведомления снизу экрана, а у меня там же waybar — окно уведомления рисуется поверх, будто панели вообще нет. Дело в том, что Steam рисует его как отдельное X11-окно и ничего не знает про зарезервированное waybar место. Чинится не в конфиге, а в самом Steam — в настройках уведомлений сменить позицию на верхний угол.

Ещё одна вещь: если браузер на движке Firefox (у меня Zen Beta), то веб-конфигураторы периферии через WebHID работать не будут — сам протокол в Firefox не реализован. Нужен любой Chromium-based браузер, обычный chromium вполне годится.

С `marktext` из nixpkgs не повезло — пакет пытается собираться из исходников и падает на компиляции нативного модуля (`ced`, не хватает node-gyp в окружении сборки). Проще поставить через flatpak, либо взять obsidian вместо него, он не собирается из сорцов.

И мелочь: если ставил что-то unfree через `nix profile install --impure`, при апгрейде это тоже надо повторить руками — флаг не запоминается автоматом:
```
NIXPKGS_ALLOW_UNFREE=1 nix profile upgrade <пакет> --impure
```

## Установка

```bash
git clone git@github.com:iZ0rua/oduvanchik-nix.git ~/nixos-configuration
cd ~/nixos-configuration
sudo nixos-rebuild switch --flake .#desktop
```

## Спасибо

Основа — [adarkaz/nixos-configuration](https://github.com/adarkaz/nixos-configuration), а его конфиг в свою очередь растёт из [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config). Так и живём — тащим друг у друга удачные решения.

---

Змейка. ЗМЕЙКА:

![snake](https://raw.githubusercontent.com/iZ0rua/oduvanchik-nix/output/github-contribution-grid-snake.svg)








