<div align="center">

# 🌼 oduvanchik-nix

<img src="https://readme-typing-svg.demolab.com/?font=Fira+Code&size=20&pause=1200&color=FABD2F&center=true&vCenter=true&width=480&lines=NixOS+%2B+Hyprland;Gruvbox+everything;one+seed%2C+scattered+everywhere" alt="typing banner" />

[![Stars](https://img.shields.io/github/stars/iZ0rua/oduvanchik-nix?color=FABD2F&labelColor=282828&style=for-the-badge&logo=starship&logoColor=FABD2F)](https://github.com/iZ0rua/oduvanchik-nix/stargazers)
[![Repo size](https://img.shields.io/github/repo-size/iZ0rua/oduvanchik-nix?color=FE8019&labelColor=282828&style=for-the-badge&logo=github&logoColor=FE8019)](https://github.com/iZ0rua/oduvanchik-nix)
[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=282828&logo=NixOS&logoColor=458588&color=458588)](https://nixos.org)
[![Last commit](https://img.shields.io/github/last-commit/iZ0rua/oduvanchik-nix?color=98971A&labelColor=282828&style=for-the-badge&logo=git&logoColor=98971A)](https://github.com/iZ0rua/oduvanchik-nix/commits/main)

</div>

<br>
.  *   .    *  .
             *    \  |  /    *
          .   `  . \|/ .  '   .
        -- -- -- -( ● )-- -- --      zoroa @ desktop
          '   .  '/|\`  .   '        ─────────────────
             *    /  |  \    *        OS      NixOS (unstable)
                '   *   `  '          WM      Hyprland
                    |                 Shell   zsh
                   /|\                Theme   Gruvbox Dark Hard
                  ' | '               Bar     Waybar
                    |                 Term    Ghostty
> [!IMPORTANT]
> Это мой **личный** конфиг — форк [adarkaz/nixos-configuration](https://github.com/adarkaz/nixos-configuration), пересаженный на свою систему и постепенно обрастающий собственными правилами, фиксами и шишками.
>
> Ничего не гарантирую, кроме того, что вчера это точно работало.

<br>

## 🛠️ Стек

| Компонент | Софт |
|---|:---:|
| **Композитор** | [Hyprland](https://github.com/hyprwm/Hyprland) |
| **Панель** | [Waybar](https://github.com/Alexays/Waybar) *(снизу — не как у всех)* |
| **Лаунчер** | [Rofi](https://github.com/davatorium/rofi) |
| **Терминал** | [Ghostty](https://ghostty.org/) |
| **Оболочка** | zsh + autosuggestions |
| **Редактор** | [VSCodium](https://vscodium.com/) |
| **Блокировка** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| **Уведомления** | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
| **Файловый менеджер** | [Nemo](https://github.com/linuxmint/nemo/) |
| **Цветовая схема** | Gruvbox Dark Hard 🌼 |

<br>

## 📚 Структура
.
├── flake.nix                    # точка входа, хосты (desktop/laptop)
├── hosts/
│   └── desktop/
│       ├── default.nix          # системные настройки хоста
│       └── hardware-configuration.nix
└── modules/
├── core/                    # steam, системные программы
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
<br>

## ⌨️ Keybinds

Полный список — `$mod F1` прямо в системе, или [`binds.nix`](modules/home/hyprland/binds.nix). Основное:

| Клавиши | Действие |
|---|---|
| `$mod + Return` | Терминал (Ghostty) |
| `$mod + B` | Браузер |
| `$mod + D` | Rofi |
| `$mod + E` | Файловый менеджер |
| `$mod + Space` | Toggle floating |
| `$mod + X` | Toggle split direction |
| `$mod + F` / `$mod Shift + F` | Fullscreen / Maximize |
| `$mod + [0-9]` | Переключить воркспейс |
| `$mod Shift + [0-9]` | Перенести окно на воркспейс (без переключения) |
| `$mod + h/j/k/l` | Фокус на соседнее окно (vim-style) |
| `$mod Shift + h/j/k/l` | Поменять окно местами с соседним |
| `$mod Ctrl + h/j/k/l` | Resize активного окна |
| `$mod Alt + h/j/k/l` | Move активного (floating) окна |
| `$mod + C` | Color picker (hyprpicker) |
| `$mod + W` | Wallpaper picker |
| `Alt + Escape` | Lock screen |
| `$mod Shift + Escape` | Power menu |

<br>

## 🐛 Известные баги и фиксы

Реальные проблемы, с которыми столкнулся, и как их решил — на всякий случай, если у кого-то то же самое:

- **Steam-уведомления перекрываются Waybar снизу** — Steam рисует их как override-redirect окно и не знает про exclusive zone панели. Фикс: сменить позицию уведомлений в самом Steam на верхний угол (`Settings → Notifications`).
- **WebHID-конфигураторы периферии не работают в Zen Beta** — Zen построен на Firefox, а Firefox не поддерживает WebHID API. Нужен Chromium-based браузер.
- **`marktext` не собирается из nixpkgs** (падает на нативном модуле `ced`, не хватает `node-gyp`) — ставится через Flatpak или замена на `obsidian`.
- **`nix profile upgrade` для unfree-пакетов** (например `osu-lazer-bin`) требует `NIXPKGS_ALLOW_UNFREE=1 ... --impure`, флаг из исходной установки не переносится на апгрейд.

<br>

## 🐍 Bonus: contribution snake

Этот репозиторий кормит змейку своими зелёными квадратиками — она обновляется раз в сутки через GitHub Action ([`Platane/snk`](https://github.com/Platane/snk)):

![snake](https://raw.githubusercontent.com/iZ0rua/oduvanchik-nix/output/github-contribution-grid-snake.svg)

Файл воркфлоу — [`.github/workflows/snake.yml`](.github/workflows/snake.yml).

<br>

## 🚀 Установка

```bash
git clone git@github.com:iZ0rua/oduvanchik-nix.git ~/nixos-configuration
cd ~/nixos-configuration
sudo nixos-rebuild switch --flake .#desktop
```

<br>

## 🙏 Credits

Начал с чужого конфига и постепенно пересадил под себя:

- [adarkaz/nixos-configuration](https://github.com/adarkaz/nixos-configuration) — прямой источник, отсюда форк
- [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config) — структура и часть модулей восходят сюда

<br>

## 📜 Лицензия

Лицензия ещё не выбрана — конфиг основан на чужом репозитории, так что перед публичным использованием стоит свериться с лицензией [adarkaz/nixos-configuration](https://github.com/adarkaz/nixos-configuration) и [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config).

<br>

<div align="right">
  <a href="#readme">🌼 наверх</a>
</div>
