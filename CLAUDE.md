# oduvanchik-nix — NixOS-конфигурация

Отвечай по-русски. Пользователь (zoroa / GitHub: notzorua) хорошо знает NixOS на практике, но английский у него ниже A2 — англоязычные термины и ошибки коротко поясняй.

## Что это за репозиторий
Личный NixOS flake (форк adarkaz ← Frost-Phoenix). NixOS unstable (26.11), Hyprland, home-manager, тема Gruvbox Dark Hard.

Хосты в `flake.nix` → `nixosConfigurations`:
- **stem** (бывший desktop) — MSI PRO B760-P WIFI, i5-12400F, 32 ГБ, RTX 4060 (`nvidia-open`), NVMe 954 ГБ. Dual-boot с Windows 11 (GRUB, `useOSProber = true`, `time.hardwareClockInLocalTime = true`).
- **fluff** — ноутбук ASUS TUF A15 FA506NCG: Ryzen + iGPU Radeon 780M, RTX 3050 Laptop (гибридная графика, см. раздел «fluff: гибридная графика»), btrfs (~477 ГБ, без subvolume), отдельный swap 15.5 ГБ. Установлен и загружается, донастройка продолжается (`services.asusd` для подсветки клавиатуры уже добавлен).

Важные места:
- `modules/core/` — системные модули (`steam.nix`, `nixpkgs.nix`, `services.nix`, `davinchi.nix`, `bootloader.nix`, …)
- `modules/home/` — home-manager (`default.nix`, `zsh/zsh.nix`, `zsh_alias.nix`, `hyprland/` — конфиг Hyprland на Lua, см. ниже, `gtk.nix`, `vscodium.nix`, `packages/`, `spicetify.nix`)
- `hosts/<host>/` — настройки хостов и `hardware-configuration.nix`
- `pkgs/` — собственные пакеты (например `pkgs/maple-mono/`)
- Собственные проекты подключены как flake inputs (`bootcheck`, `flakeguard`, `hyprtime`), модуль `own-tools.nix`

## Куда ставить программы
Home-конфиг (`modules/home/`) общий для обоих хостов; системный (`modules/core/`) — тоже, кроме того, что в `hosts/<host>/`.
- **Программа без своей настройки** → `modules/home/packages/`: `cli.nix` (терминал), `gui.nix` (графические), `dev.nix` / `dev_dotnet.nix` (языки, LSP, отладчики), `nix.nix` (инструменты Nix).
- **Программа с настройкой** → свой файл `modules/home/<имя>.nix` (`programs.<имя>` или пакет + конфиг рядом); в `packages/*.nix` её не повторять.
- **Системное** → `modules/core/`: то, что нужно root/службам или идёт вместе с модулем (`virtualization.nix`, `qmk.nix`, `amneziawg.nix`). Базовые утилиты для root (`git`, `wget`) — в `system.nix`, в home их не повторять (исключение — `programs.git` в home ради настроек).
- **Только один хост** → `hosts/<host>/default.nix` или модуль, импортируемый оттуда (`ollama.nix` у stem).
- Если включён `programs.X` / `hardware.X` / `services.X`, пакет X в список не добавлять: модуль ставит его сам.
- **Flatpak** → `modules/core/flatpak.nix`, только то, чего нет в nixpkgs или там не работает.
- **Overlays** → только `modules/core/nixpkgs.nix` (не в хостах: иначе overlay применится дважды).
- Перед добавлением: `grep -rn '<имя>' modules hosts`.

## Команды
- **Все команды nix/nh/git — только из `~/nixos-configuration`**, не из `~`.
- `nixup` (алиас в `zsh_alias.nix`) — `git add -A` → `nh os switch .` → `sudo bootcheck`, без обновления версий. **Коммит не создаёт** (и никогда не создавал): `git add -A` только индексирует, чтобы flake видел новые файлы; коммитить вручную.
- `nixupd()` (в `zsh.nix`) — `nix flake update` → проверка `flake.lock` через **flakeguard** (при подозрении на repojacking откатывает lock) → `git add -A` → `nh os switch` → `sudo bootcheck` (только после успешного switch). **Коммит не создаёт** — коммитить вручную.
- `nh os switch . --keep-going` — продолжать сборку, несмотря на отдельные упавшие пакеты.
- `sudo bootcheck` — проверка, что система загрузится (GRUB, ядра, UEFI, ESP). Запускать перед перезагрузкой.

## Правила и выученные уроки
- **После обновления ядра или nvidia — обязательна перезагрузка.** Иначе `nvidia-smi` даёт `Driver/library version mismatch`, FPS падает. Всегда напоминай об этом, если в выводе `nh` обновились `linux` или `nvidia-*`.
- **Hash mismatch у сторонних пакетов** (апстрим подменил файл без смены версии): сначала повторить / `--keep-going`; при повторах — временно закомментировать пакет и ждать фикса в nixpkgs. `millennium-typescript-bun-deps` бывает невоспроизводимым (иногда проходит при повторе).
- Ничего не ставить через `nix profile install` — всё постоянное переносить в конфиг (`environment.systemPackages` / `home.packages`).
- Waybar берётся из upstream (вход `waybar` во `flake.nix`, `programs.waybar.package` в `modules/home/waybar/waybar.nix`): Waybar из nixpkgs шлёт старый синтаксис `hyprctl dispatch`, и кнопки рабочих столов с Lua-конфигом не работают. Когда Lua-dispatch появится в nixpkgs — вход можно убрать. `inputs.nixpkgs.follows` стоит намеренно: бинарного кэша у Waybar нет (собирается локально в любом случае), а без follows подтянулся бы его старый nixpkgs со второй копией GTK/glibc.
- **AyuGram** — из flake `github:ndfined-crp/ayugram-desktop` (именно **ndfined-crp**, есть фальшивые копии), вход `ayugram-desktop` **без follows — намеренно**, пакет в `modules/home/packages/gui.nix`. Кэши `ayugram-desktop.cachix.org` / `tg-owt.cachix.org` (ключи из `nixConfig` его `flake.nix`) — в `modules/core/system.nix`. Почему без follows (проверено 11.10.2026): CI кладёт в кэш сборку под *свой* nixpkgs из своего `flake.lock`; с `follows = "nixpkgs"` хеш другой → `ayugram-desktop-unwrapped` компилировался локально (тяжёлый C++) после каждого обновления nixpkgs. Без follows — ~91 МБ из кэша; цена — Qt/GTK/glib из его nixpkgs (на 11.10 совпали с нашими, лишнего не было; со временем может появиться вторая копия, всё с `cache.nixos.org`).
  - Попадание в кэш: `nix eval` outPath пакета → `curl -sI https://ayugram-desktop.cachix.org/<хеш>.narinfo` (200 = есть). `nix path-info --store https://…` врёт («нет» для существующего пути) — не верить.
  - Substituters из конфига работают только после switch. Если кэш ещё не в `/etc/nix/nix.conf` — скачать вручную: `nix build --no-link --option extra-substituters "https://ayugram-desktop.cachix.org" --option extra-trusted-public-keys "<ключ>" <outPath>` (zoroa в `trusted-users`), затем `nh os build .`.
  - Если после `nixupd` AyuGram всё же компилируется — их CI ещё не собрал новую ревизию: подождать или откатить вход (`nix flake update ayugram-desktop` позже).
  - Профиль — `~/.local/share/AyuGramDesktop` (выбирает программа, не Nix): тот же, что у пакета из nixpkgs. Откатывать на более старую версию AyuGram нежелательно — `tdata` мигрирует вперёд.
- Waybar запускается из автозапуска Hyprland (`startup.lua`), а не systemd — после пересборки может пропасть; перезапуск: `waybar & disown` или `scripts/toggle-waybar.sh`.
- **Hyprland теряет TZDIR (и подобные переменные).** `programs.hyprland` из nixpkgs запускает его через обёртку `/run/wrappers/bin/Hyprland` с `cap_sys_nice+ep` (ради SCHED_RR) → процесс получает AT_SECURE → glibc при старте вычищает «небезопасные» переменные (`TZDIR`, `TMPDIR`, `LOCPATH`, `LD_*` и др., список — `unsecvars.h`). PAM (lightdm) их даёт: у `start-hyprland` они есть, пропадают в самом Hyprland и у всего, что он запускает. Без TZDIR `timedatectl` показывал Europe/Moscow как `+0000`. Возвращаем в `modules/home/hyprland/env.nix`: переменные из этого списка, которые есть в `environment.sessionVariables`, задаются заново через `hl.env` (новые подхватятся сами). Действует после нового входа; `/proc/<pid Hyprland>/environ` даёт `Permission denied` — это тоже AT_SECURE, проверять по дочернему процессу. Касается обоих хостов.
- `allowUnfree = true` уже включён.
- `git config --global core.fsync all` — включён после повреждения репозитория при жёстких выключениях.
- Не выполнять `sudo`, `nh os switch`, `git push` без явного подтверждения пользователя.
- **На stem `hyprctl dispatch exit` замораживает экран** (вероятно, NVIDIA) — выйти из Hyprland «на лету» нельзя. Рискованные изменения (Hyprland, видеодрайвер, сеанс) применять через `nh os boot .` + `systemctl reboot`, а не `nh os switch`: при проблеме в меню загрузки остаётся прежнее поколение.
- **VirtualBox** (`modules/core/virtualbox.nix`, импорт в `modules/core/default.nix` — на обоих хостах): Extension Pack (USB 2.0/3.0 в гостевой, FPGA USB-Blaster), группа `vboxusers`. С Extension Pack VirtualBox не берётся из кэша — собирается локально после каждого обновления nixpkgs/ядра (долго). Рядом стоит libvirt/KVM (`virtualization.nix`): модули `kvm_intel` (stem) / `kvm_amd` (fluff) грузятся всегда. Виртуалки VirtualBox и libvirt одновременно не запускать — аппаратная виртуализация (VT-x/AMD-V) одна. Модуль nixpkgs добавляет `kvm.enable_virt_at_load=0` только для ядер 6.12–6.15; на 7.x — нет. Если VirtualBox не стартует с `VERR_VMX_IN_VMX_ROOT_MODE` / `VERR_SVM_IN_USE` при выключенных виртуалках libvirt — добавить `boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]` в `virtualbox.nix` (KVM будет включать VT-x только при запуске своей виртуалки).
- **Ollama — только на stem** (`modules/core/ollama.nix`, импорт в `hosts/stem/default.nix`; на fluff не нужна). Пакет — обычный `pkgs.ollama-cuda` **без `cudaArches`, намеренно**: готовый лежит в `cache.nixos-cuda.org` (архитектуры 7.5…12.1, в т.ч. 8.9 — RTX 4060); своё `cudaArches = [ "89" ]` меняет derivation → кэш мимо и локальная компиляция CUDA-кода после каждого обновления nixpkgs. Цена — ~300 МиБ на диске (пакет 1.2 ГБ вместо 941 МиБ). В `cache.nixos.org` CUDA-сборок нет (несвободное ПО). Кэш `cache.nixos-cuda.org` с ключом прописан в самом `ollama.nix` (`nix.settings`). Закомментирован был 30.09 из-за `cuda_nvrtc`; 12.10.2026 собирается.
  - **Первый switch после включения модуля** (или на новой машине) идёт со старым `/etc/nix/nix.conf`, где этого кэша нет, — ollama-cuda компилировалась бы под все архитектуры. Сначала скачать вручную: `nix build --no-link <outPath> --option extra-substituters https://cache.nixos-cuda.org --option extra-trusted-public-keys "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="` (outPath — `nix eval --raw .#nixosConfigurations.stem.config.services.ollama.package.outPath`), потом `nh os build .`/switch. Дальше кэш работает сам.
  - После switch служба `ollama-model-loader` качает `qwen3:8b` (~5 ГБ). Проверка, что на GPU: `ollama ps` во время ответа → `100% GPU`.
  - **`OLLAMA_FLASH_ATTENTION=1` и `OLLAMA_KV_CACHE_TYPE=q8_0`** (`services.ollama.environmentVariables` — отдельных опций в модуле nixpkgs нет; переменные видит только служба, не `ollama run`). Зачем: сайт prava шлёт `num_ctx` 7168 (иначе промпт молча обрезается), и с KV-кэшем в f16 qwen3:8b помещалась в 8 ГБ впритык — при открытом браузере ~8 % слоёв уходило на CPU (6.4 ГБ, ответ в ~1.5 раза медленнее). q8_0 вдвое уменьшает KV-кэш (по оценке ~0.5 ГБ на 7168 токенах); работает только вместе с flash attention. Проверка после switch: `ollama ps` при открытом браузере → `100% GPU`; если нет — смотреть `nvidia-smi` (кто ещё занял память).

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

## fluff: гибридная графика (AMD 780M + RTX 3050)
Цель: всё рисует AMD, RTX спит (D3cold) и включается только для игр через `nvidia-offload`. Всё — в `hosts/fluff/default.nix`, общие модули не тронуты (у stem iGPU нет: i5-12400F).

Разводка: экран ноутбука `eDP-1` — на AMD (`0000:05:00.0`); HDMI и USB-C DP (`DP-7`) — на NVIDIA (`0000:01:00.0`).

Цепочка (каждое звено держало RTX включённой — убрать любое, и она перестанет засыпать):
1. **PRIME offload** — `hardware.nvidia.prime.offload` + `powerManagement.finegrained = lib.mkForce true` (в общем `hardware.nix` — `false`), busId `PCI:5@0:0:0` / `PCI:1@0:0:0`.
2. **`AQ_DRM_DEVICES = "/dev/dri/amd-igpu"`** — Hyprland открывает только AMD. Путь — udev-ссылка (`/dev/dri/amd-igpu`, `/dev/dri/nvidia-dgpu`): номера `cardN` меняются между загрузками, а в `/dev/dri/by-path` есть «:» — это разделитель списка. Задаётся в `environment.sessionVariables` (PAM): Aquamarine читает её до `hyprland.lua`.
3. **`__EGL_VENDOR_LIBRARY_FILENAMES` (только Mesa) и `VK_DRIVER_FILES` (только radeon)** на весь сеанс — иначе любое GL/Vulkan-приложение (Hyprland, swaync, GTK4) грузит библиотеки NVIDIA и держит `/dev/nvidia0`. Пути через `/run/opengl-driver{,-32}`, оба: в `50_mesa.json` полный путь к 64-битной библиотеке.
4. **`nvidia-drm modeset=0 fbdev=0`** (`hardware.nvidia.moduleParams.nvidia-drm`, `mkForce`: NixOS ставит 1 при offload). С `modeset=1` NVKMS создаёт дисплейный канал и блокирует сон (GC6 blocker, `nvkms-evo.c`) → `runtime_usage=1` без единого открытого файла. Отключение одного `fbdev` не помогло.
5. **Свой `nvidia-offload`** (`enableOffloadCmd = false`): штатный из nixpkgs только ставит 4 переменные `__NV_PRIME…`/`__GLX…`/`__VK_LAYER_NV_optimus`; свой сначала делает `unset __EGL_VENDOR_LIBRARY_FILENAMES VK_DRIVER_FILES` и ставит `SDL_VIDEODRIVER=x11 SDL_VIDEO_DRIVER=x11` (SDL2/SDL3).

**Offload — только через X11 (Xwayland).** С `modeset=0` NVIDIA не выводит в окна Wayland: Vulkan — «Could not find both graphics and present queues» (vkcube молча берёт AMD), EGL — «failed to create surface». GLX и Vulkan через xcb работают. Проверено 10.10.2026: `glxgears`, `vkcube --wsi xcb`, osu!lazer (`nvidia-offload osu!` → SDL3 x11, GL Renderer RTX 3050) — на RTX, после выхода карта засыпает за 1–2 с.
- Steam: в параметрах запуска игры `nvidia-offload %command%`; Proton/Wine по умолчанию идёт через X11. Нативной игре на Wayland — тоже X11 (SDL уже в скрипте; для прочих — смотреть, чем она выбирает Wayland).
- **Sober (Roblox, Flatpak — на будущее):** Vulkan, а в `flatpak.nix` глобально `!x11` → через offload не заработает. Нужно: для `org.vinegarhq.Sober` разрешить сокет `x11` и запускать его на X11, задать в Flatpak-переопределении переменные offload (`__NV_PRIME_RENDER_OFFLOAD=1`, `__NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0`, `__VK_LAYER_NV_optimus=NVIDIA_only`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`) и проверить, не попадают ли в песочницу `VK_DRIVER_FILES`/`__EGL_VENDOR_LIBRARY_FILENAMES` (там нет `/run/opengl-driver` — снять через `unset-environment`). Плюс расширение `org.freedesktop.Platform.GL.nvidia-<версия драйвера>` — после обновления драйвера `flatpak update`.

Проверки:
- сон: `cat /sys/bus/pci/devices/0000:01:00.0/power/{runtime_usage,runtime_status}` → `0` / `suspended`; **`nvidia-smi` будит карту** — не запускать перед проверкой;
- кто держит: `sudo fuser -v /dev/nvidia* /dev/dri/renderD128`; если пусто, а `runtime_usage=1` — держит ядро (модуль);
- игра на RTX: `nvidia-smi` во время игры или `/proc/<pid>/maps` содержит `libGLX_nvidia`.

**Вернуть HDMI** (RTX тогда перестанет засыпать): убрать `moduleParams.nvidia-drm` (без KMS у NVIDIA нет выходов) и задать `AQ_DRM_DEVICES = "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu"` (AMD первой) или убрать её; `nh os boot .` + перезагрузка — Hyprland выбирает карты только при запуске. С `modeset=1` offload снова работает и на Wayland.

**Откат** — по шагам, коммитами (новые сверху): «fluff: nvidia-offload — SDL через X11…» — переменные SDL; `798955f` — `modeset=0` (если откатывать его, SDL в скрипте можно оставить или убрать: с `modeset=1` offload работает и на Wayland); `19a6203` — переменные EGL/Vulkan и свой `nvidia-offload`; `092dfdb` — `AQ_DRM_DEVICES`/udev; `fd5e9aa` — prime offload. `git revert <коммит>` → `nh os boot .` → перезагрузка; в GRUB остаётся прежнее поколение.

## Баг Aquamarine #383 (stem)
При выходе из Hyprland на stem Aquamarine падает (SIGSEGV в `flushAsyncCommitEvents()`), KMS остаётся в плохом состоянии, и LightDM-greeter (X11, NVIDIA) зависает — экран замирает. Исправлено upstream коммитом `fc77bd5`, в релизе ещё нет (у нас Aquamarine 0.15.1, ждём 0.15.2).
- **Не выходить из Hyprland в greeter.** Если случилось: `Ctrl+Alt+F3` → `sudo systemctl restart display-manager`; нет консоли — кнопка питания.
- **Проверить ~07.11.2026:** после `nixupd` и перезагрузки — `nix-store -qR /run/current-system | grep aquamarine`. Если ≥ 0.15.2 — осторожно проверить выход; если нет — включить запасной вариант.

### Запасной вариант: greetd + tuigreet
greetd — легковесный менеджер входа (display manager), tuigreet — его текстовый greeter (экран входа) в консоли: X11 и NVIDIA в нём не участвуют, зависать после падения Aquamarine нечему. Диагностика 24.10.2026: пробная сборка через `extendModules` (конфиг stem + блок ниже, без изменения репозитория) прошла.

Только stem — блок в `hosts/stem/default.nix` (в аргументы модуля добавить `config` и `lib`):
```nix
services.greetd =
  let
    startHyprland = lib.getExe' config.programs.hyprland.package "start-hyprland";
  in
  {
    enable = true;
    useTextGreeter = true;
    settings = {
      # автологин при загрузке — как раньше у LightDM
      initial_session = {
        user = "zoroa";
        command = startHyprland;
      };
      # после выхода из сеанса — tuigreet
      default_session.command = lib.concatStringsSep " " [
        (lib.getExe pkgs.tuigreet)
        "--time"
        "--remember"
        "--remember-session"
        "--asterisks"
        "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        "--cmd ${startHyprland}"
      ];
    };
  };
```
- **Пакеты:** `pkgs.tuigreet` 0.11.1 (старого `greetd.tuigreet` больше нет), greetd 0.10.3. Пользователя `greeter` (от него идёт `default_session`) и `/var/cache/tuigreet` (для `--remember`) модуль создаёт сам.
- **Команда — `start-hyprland`** из `config.programs.hyprland.package`, как в `hyprland.desktop`.
- **LightDM выключится сам:** он включается от `services.xserver.enable`, только если не выбран другой DM.
- **Обёртка с `cap_sys_nice` сохранится:** `start-hyprland` делает `execvp("Hyprland")` по `PATH`, а `/run/wrappers/bin` первым в `PATH` ставит pam_env (а не LightDM) — значит, и под greetd запустится `/run/wrappers/bin/Hyprland`. Проверено на процессе: `CapEff` = `cap_sys_nice`, политика `SCHED_RR`, приоритет 1.
- `services.displayManager.autoLogin` в `modules/core/xserver.nix` на stem станет неиспользуемым — **не убирать**, он нужен fluff.
- **Применять только `nh os boot .` → `sudo bootcheck` → перезагрузка.** Не `switch`: у greetd `restartIfChanged = false`, а при switch он конфликтует с ещё работающим LightDM.
- **Откат:**
  - не загрузилось → в GRUB выбрать прошлое поколение;
  - загрузилось, но tty1 пустой → `Ctrl+Alt+F2` (там есть getty — обычный вход в консоль), затем `sudo /nix/var/nix/profiles/system-<N-1>-link/bin/switch-to-configuration boot` и перезагрузка;
  - насовсем — убрать блок `services.greetd`.
- **Сообщения ядра поверх tuigreet** (по желанию): при `loglevel=4` в консоль попадают только ошибки (уровни 0–3). Чтобы убрать и их — `boot.kernel.sysctl."kernel.printk" = "3 4 1 3";`. Цена: ошибки вроде NVIDIA Xid будут видны только в `journalctl -k`.
- **При переходе** поправить упоминания «PAM (lightdm)» в `modules/home/hyprland/env.nix` и в пункте про TZDIR (раздел «Правила и выученные уроки»).

## Сеть
- Часть доменов заблокирована. Прокси-клиент **Throne** (sing-box), локальный прокси `127.0.0.1:2080` (mixed).
- Через прокси `cache.nixos.org` бывает очень медленным — такие домены в `no_proxy`.
- **AmneziaWG/WARP** (`amneziawg-awg0`) режет доступ к Claude и `cache.nixos.org`.
- Частая ловушка: старые `http_proxy`/`https_proxy` в окружении запущенной оболочки перебивают маршрут → `unset http_proxy https_proxy` или перезаход в сессию.
- Если после падения Throne не работает DNS — остались его `ip rule` (fwmark 0x2023/0x2024, таблица 51820): `ip rule list`, удалить лишние, или перезагрузиться.

## Открытые задачи
1. **fluff**: установлен и загружается (хост переименован desktop→stem, fluff добавлен, `services.asusd` для подсветки клавиатуры настроен). Осталось: раскомментировать `./spicetify.nix` (`modules/home/default.nix`), настроить Throne постоянно (`programs.throne`), докачать `discord-canary` и C#-расширение VSCodium, донастроить ноут (батарея/tlp, Wi-Fi, тачпад, разрешение в Hyprland).
2. **fluff переведён на Hyprland на Lua.** Осталось проверить `monitor-watcher.sh` на зацикливание: он реагирует на событие `configreloaded`, а `hyprctl eval 'hl.monitor(…)'` не должен вызывать его снова (иначе зациклится).
3. **DaVinci Resolve** закомментирован в `modules/core/davinchi.nix` — ждёт PR nixpkgs #562336 (фикс хеша).
4. ~~`gemini-cli` / `gemini-cli-bin` убраны из конфига~~ (сделано).
5. Перегенерировать приватный ключ WARP (засвечен ранее).
6. Waybar: перевести на systemd user service или добавить перезапуск в `nixup`.
7. BIOS не обновлён (прошивка 10.2023), память на 2133 МГц без XMP.
