-- Автозапуск при входе в Hyprland (Lua). Было: exec-once.nix — список exec-once.
--
-- Было:  exec-once = "waybar &"
-- Стало: hl.on("hyprland.start", function() hl.exec_cmd("waybar") end)
-- «&» в конце больше не пишем: Hyprland и так запускает программу в фоне и не ждёт её.
-- Правила в скобках — таблицей:  "[workspace 1 silent] zen-beta"
--                            →  hl.exec_cmd("zen-beta", { workspace = "1 silent" })
--
-- Файл подключается из extraConfig (exec-once.nix), а не автоматически: home-manager
-- вставляет extraConfig в конец hyprland.lua, после своего обработчика «hyprland.start»
-- (импорт окружения в systemd и D-Bus, запуск hyprland-session.target). Так порядок — как
-- раньше: сначала окружение, потом программы.
-- Первые две строки старого списка (dbus-update-activation-environment --all … и
-- systemctl --user import-environment …) делает home-manager: systemd.variables = [ "--all" ]
-- в hyprland.nix.

-- Фоновые программы — в том же порядке, что были.
local services = {
	"hyprlock", -- экран блокировки сразу после входа
	"nm-applet",
	"poweralertd",
	"wl-clip-persist --clipboard regular",
	"wl-paste --type text --watch cliphist store",
	"wl-paste --type image --watch cliphist store",
	"waybar",
	"hyprtime watch",
	"udiskie --automount --notify --smart-tray",
	"xrdb -merge ~/.Xresources",
	"hyprctl setcursor Qogir-Light 48", -- setcursor — не dispatch, в Lua-режиме работает
	"init-wallpaper",
	"xembedsniproxy",
	"ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false",
}

-- Программы на своих рабочих столах (silent — не переключаться на этот стол).
local apps = {
	{ "zen-beta", "1 silent" },
	{ "ghostty", "2 silent" },
	-- Было «Bluetooth Manager» — программа «Bluetooth» с аргументом «Manager», не запускалась.
	{ "blueman-manager", "2 silent" },
	{ "AyuGram", "3 silent" },
	{ "Throne", "4 silent" },
}

hl.on("hyprland.start", function()
	for _, cmd in ipairs(services) do
		hl.exec_cmd(cmd)
	end
	for _, app in ipairs(apps) do
		hl.exec_cmd(app[1], { workspace = app[2] })
	end
end)
