# oduvanchik-nix — NixOS-конфигурация

Отвечай по-русски. Пользователь (zoroa / GitHub: notzorua) хорошо знает NixOS на практике, но английский у него ниже A2 — англоязычные термины и ошибки коротко поясняй.

## Что это за репозиторий
Личный NixOS flake (форк adarkaz ← Frost-Phoenix). NixOS unstable (26.11), Hyprland, home-manager, тема Gruvbox Dark Hard.

Хосты в `flake.nix` → `nixosConfigurations`:
- **stem** (бывший desktop) — MSI PRO B760-P WIFI, i5-12400F, 32 ГБ, RTX 4060 (`nvidia-open`), NVMe 954 ГБ. Dual-boot с Windows 11 (GRUB, `useOSProber = true`, `time.hardwareClockInLocalTime = true`).
- **fluff** — ноутбук ASUS, AMD, btrfs (~477 ГБ, без subvolume), отдельный swap 15.5 ГБ. Установлен и загружается, донастройка продолжается (`services.asusd` для подсветки клавиатуры уже добавлен).

Важные места:
- `modules/core/` — системные модули (`steam.nix`, `nixpkgs.nix`, `services.nix`, `davinchi.nix`, `bootloader.nix`, …)
- `modules/home/` — home-manager (`default.nix`, `zsh/zsh.nix`, `zsh_alias.nix`, `hyprland/` — конфиг Hyprland на Lua, см. ниже, `gtk.nix`, `vscodium.nix`, `packages/`, `spicetify.nix`)
- `hosts/<host>/` — настройки хостов и `hardware-configuration.nix`
- `pkgs/` — собственные пакеты (например `pkgs/maple-mono/`)
- Собственные проекты подключены как flake inputs (`bootcheck`, `flakeguard`, `hyprtime`), модуль `own-tools.nix`

## Команды
- **Все команды nix/nh/git — только из `~/nixos-configuration`**, не из `~`.
- `nixup` — коммит + `nh os switch .` без обновления версий.
- `nixupd()` (в `zsh.nix`) — `nix flake update` → проверка `flake.lock` через **flakeguard** (при подозрении на repojacking откатывает lock) → коммит → `nh os switch`.
- `nh os switch . --keep-going` — продолжать сборку, несмотря на отдельные упавшие пакеты.
- `sudo bootcheck` — проверка, что система загрузится (GRUB, ядра, UEFI, ESP). Запускать перед перезагрузкой.

## Правила и выученные уроки
- **После обновления ядра или nvidia — обязательна перезагрузка.** Иначе `nvidia-smi` даёт `Driver/library version mismatch`, FPS падает. Всегда напоминай об этом, если в выводе `nh` обновились `linux` или `nvidia-*`.
- **Hash mismatch у сторонних пакетов** (апстрим подменил файл без смены версии): сначала повторить / `--keep-going`; при повторах — временно закомментировать пакет и ждать фикса в nixpkgs. `millennium-typescript-bun-deps` бывает невоспроизводимым (иногда проходит при повторе).
- Ничего не ставить через `nix profile install` — всё постоянное переносить в конфиг (`environment.systemPackages` / `home.packages`).
- Waybar запускается из автозапуска Hyprland (`startup.lua`), а не systemd — после пересборки может пропасть; перезапуск: `waybar & disown` или `scripts/toggle-waybar.sh`.
- `allowUnfree = true` уже включён.
- `git config --global core.fsync all` — включён после повреждения репозитория при жёстких выключениях.
- Не выполнять `sudo`, `nh os switch`, `git push` без явного подтверждения пользователя.
- **На stem `hyprctl dispatch exit` замораживает экран** (вероятно, NVIDIA) — выйти из Hyprland «на лету» нельзя. Рискованные изменения (Hyprland, видеодрайвер, сеанс) применять через `nh os boot .` + `systemctl reboot`, а не `nh os switch`: при проблеме в меню загрузки остаётся прежнее поколение.

## Hyprland (Lua-конфиг)
С 08.10.2026 конфиг Hyprland — на Lua (`wayland.windowManager.hyprland.configType = "lua"` в `modules/home/hyprland/hyprland.nix`): home-manager создаёт `~/.config/hypr/hyprland.lua` вместо `hyprland.conf` (в Hyprland 0.57 поддержку `.conf` убирают). Hyprland выбирает формат один раз при запуске — смена формата вступает в силу только после нового входа.

Где что лежит (`modules/home/hyprland/`):
- `settings.nix` — простые настройки: `settings.config = { … }` → `hl.config({ … })`. Ключи с точкой («`col.active_border`») — вложенными таблицами, градиент — `{ colors = [ … ]; angle = 45; }`.
- `binds.lua` — привязки (`hl.bind`, команды из `hl.dsp.*`); подключён из `binds.nix`. Привязки громкости, яркости и Caps/Num Lock — в `modules/home/swayosd.nix` (Lua-строкой, файл `swayosd.lua`).
- `rules.lua` — правила окон, слоёв и рабочих столов (`hl.window_rule`, `hl.layer_rule`, `hl.workspace_rule`); из `windowrules.nix`.
- `startup.lua` — автозапуск (`hl.on("hyprland.start", …)` + `hl.exec_cmd`); подключён из `exec-once.nix` через `extraConfig` с `autoLoad = false` — так он выполняется после импорта окружения home-manager (`systemd.variables = [ "--all" ]` в `hyprland.nix`).
- `animations.lua` — кривые и анимации (`hl.curve`, `hl.animation`); сами анимации выключены в `settings.nix`.
- `displays.lua` — запасное правило мониторов и подключение файлов nwg-displays; из `monitors.nix`.
- Новый `.lua`-файл — `git add`, иначе flake его не увидит.

Правила:
- **Мониторы настраивает nwg-displays**: он пишет `~/.config/hypr/monitors.lua` (и `workspaces.lua`) — не руками и не через home-manager. Поэтому файл в home-manager называется `displays.lua`, а не `monitors.lua`: имена совпали бы.
- **У каждой привязки — описание** (функция `bind(клавиши, "описание", действие)` в `binds.lua` и `swayosd.nix`): `show-keybinds` (`SUPER+F1`) строит список из `hyprctl binds -j`, а у Lua-привязок там вместо команды «`__lua`». Без описания привязки в списке не будет.
- **`hyprctl` в Lua-режиме:** `hyprctl dispatch X` выполняет Lua `hl.dispatch(X)` — например `hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'`; старый синтаксис (`dispatch exec '[float] …'`, `dispatch workspace 3`) не работает. `hyprctl keyword` не работает совсем — вместо него `hyprctl eval '…'` (например `hl.config({ … })`, `hl.monitor({ … })`). `getoption` отвечает в новых типах («`bool: true`», а не «`int: 1`») — в скриптах значения читать в Lua через `hl.get_config`, а не разбирать вывод.
- **Проверка конфига:** `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` — синтаксис, имена настроек, условия и эффекты правил, неизвестные диспетчеры. Не ловит: значения `hl.monitor` (опечатку в `"auto"` пропустит), имена правил в `hl.dsp.exec_cmd(cmd, { … })` и неизвестные опции `hl.bind` — они проверяются только при нажатии. Новую конфигурацию до переключения: собрать и прогнать `--verify-config` по файлам из `nix eval` (`xdg.configFile."hypr/…"`), положив их во временную папку и указав её в `XDG_CONFIG_HOME`.
- Описание API — в пакете Hyprland: `share/hypr/stubs/hl.meta.lua` и пример `share/hypr/hyprland.lua`. Аргументы диспетчеров сверять с исходником нужной версии (`src/config/lua/bindings/LuaBindingsDispatchers.cpp`): неизвестные ключи в таблицах аргументов молча игнорируются.
- hyprlock переход не затрагивает: у него свой `hyprlock.conf` (hyprlang).

## Сеть
- Часть доменов заблокирована. Прокси-клиент **Throne** (sing-box), локальный прокси `127.0.0.1:2080` (mixed).
- Через прокси `cache.nixos.org` бывает очень медленным — такие домены в `no_proxy`.
- **AmneziaWG/WARP** (`amneziawg-awg0`) режет доступ к Claude и `cache.nixos.org`.
- Частая ловушка: старые `http_proxy`/`https_proxy` в окружении запущенной оболочки перебивают маршрут → `unset http_proxy https_proxy` или перезаход в сессию.
- Если после падения Throne не работает DNS — остались его `ip rule` (fwmark 0x2023/0x2024, таблица 51820): `ip rule list`, удалить лишние, или перезагрузиться.

## Открытые задачи
1. **fluff**: установлен и загружается (хост переименован desktop→stem, fluff добавлен, `services.asusd` для подсветки клавиатуры настроен). Осталось: раскомментировать `./spicetify.nix` (`modules/home/default.nix`), настроить Throne постоянно (`programs.throne`), докачать `discord-canary` и C#-расширение VSCodium, донастроить ноут (батарея/tlp, Wi-Fi, тачпад, разрешение в Hyprland).
2. **fluff: переход Hyprland на Lua ещё не сделан.** Модули общие, поэтому первая пересборка fluff из `main` сразу переведёт его на Lua. До неё: открыть nwg-displays и сохранить (создаст `monitors.lua` для `eDP-1`), пересобрать через `nh os boot` + перезагрузку и проверить `monitor-watcher.sh` — он реагирует на событие `configreloaded`, а `hyprctl eval 'hl.monitor(…)'` не должен вызывать его снова (иначе зациклится).
3. **DaVinci Resolve** закомментирован в `modules/core/davinchi.nix` — ждёт PR nixpkgs #562336 (фикс хеша).
4. ~~`gemini-cli` / `gemini-cli-bin` убраны из конфига~~ (сделано).
5. Перегенерировать приватный ключ WARP (засвечен ранее).
6. Waybar: перевести на systemd user service или добавить перезапуск в `nixup`.
7. BIOS не обновлён (прошивка 10.2023), память на 2133 МГц без XMP.
