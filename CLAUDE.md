# oduvanchik-nix — NixOS-конфигурация

Отвечай по-русски. Пользователь (zoroa / GitHub: notzorua) хорошо знает NixOS на практике, но английский у него ниже A2 — англоязычные термины и ошибки коротко поясняй.

## Что это за репозиторий
Личный NixOS flake (форк adarkaz ← Frost-Phoenix). NixOS unstable (26.11), Hyprland, home-manager, тема Gruvbox Dark Hard.

Хосты в `flake.nix` → `nixosConfigurations`:
- **desktop** — MSI PRO B760-P WIFI, i5-12400F, 32 ГБ, RTX 4060 (`nvidia-open`), NVMe 954 ГБ. Dual-boot с Windows 11 (GRUB, `useOSProber = true`, `time.hardwareClockInLocalTime = true`).
- **fluff** — новый ноутбук, AMD, btrfs (~477 ГБ, без subvolume), отдельный swap 15.5 ГБ. Установка через `nixos-install --flake .#fluff`, завершение не подтверждено.

Важные места:
- `modules/core/` — системные модули (`steam.nix`, `nixpkgs.nix`, `services.nix`, `davinchi.nix`, `bootloader.nix`, …)
- `modules/home/` — home-manager (`default.nix`, `zsh/zsh.nix`, `zsh_alias.nix`, `hyprland/exec-once.nix`, `gtk.nix`, `vscodium.nix`, `packages/`, `spicetify.nix`)
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
- Waybar запускается через `exec-once` в Hyprland, а не systemd — после пересборки может пропасть; перезапуск: `waybar & disown` или `scripts/toggle-waybar.sh`.
- `allowUnfree = true` уже включён.
- `git config --global core.fsync all` — включён после повреждения репозитория при жёстких выключениях.
- Не выполнять `sudo`, `nh os switch`, `git push` без явного подтверждения пользователя.

## Сеть
- Часть доменов заблокирована. Прокси-клиент **Throne** (sing-box), локальный прокси `127.0.0.1:2080` (mixed).
- Через прокси `cache.nixos.org` бывает очень медленным — такие домены в `no_proxy`.
- **AmneziaWG/WARP** (`amneziawg-awg0`) режет доступ к Claude и `cache.nixos.org`.
- Частая ловушка: старые `http_proxy`/`https_proxy` в окружении запущенной оболочки перебивают маршрут → `unset http_proxy https_proxy` или перезаход в сессию.
- Если после падения Throne не работает DNS — остались его `ip rule` (fwmark 0x2023/0x2024, таблица 51820): `ip rule list`, удалить лишние, или перезагрузиться.

## Открытые задачи
1. **fluff**: подтвердить установку, задать пароль, первая загрузка. Затем: раскомментировать `./spicetify.nix` (`modules/home/default.nix`), настроить Throne постоянно (`programs.throne`), докачать `discord-canary` и C#-расширение VSCodium, донастроить ноут (батарея/tlp, Wi-Fi, тачпад, разрешение в Hyprland).
2. **DaVinci Resolve** закомментирован в `modules/core/davinchi.nix` — ждёт PR nixpkgs #562336 (фикс хеша).
3. `gemini-cli` / `gemini-cli-bin` помечены на удаление из nixpkgs — убрать из конфига.
4. Перегенерировать приватный ключ WARP (засвечен ранее).
5. Waybar: перевести на systemd user service или добавить перезапуск в `nixup`.
6. BIOS не обновлён (прошивка 10.2023), память на 2133 МГц без XMP.
