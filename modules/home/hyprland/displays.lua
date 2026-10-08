-- Мониторы (Lua). Было: monitors.nix — settings.monitor и «source» файлов nwg-displays.
-- Файл называется displays.lua, а не monitors.lua: monitors.lua в ~/.config/hypr пишет nwg-displays.
--
-- Было:  monitor = ",preferred,auto,auto"   (выход, режим, положение, масштаб)
-- Стало: hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
-- Внимание: значения hl.monitor --verify-config не проверяет (опечатку в «auto» он пропустит).

-- Запасное правило: любой монитор, не описанный ниже, — в его лучшем режиме, автоматически.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Настройки из nwg-displays. В Lua нет «source» для .conf, но nwg-displays (с 0.4.4) рядом
-- с monitors.conf / workspaces.conf пишет monitors.lua / workspaces.lua — их и подключаем.
-- Было «# hyprlang noerror true»: нет файла — не ошибка. Здесь так же: файла нет — пропускаем,
-- а ошибка внутри существующего файла видна (dofile без pcall).
local hypr = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr/"

for _, name in ipairs({ "monitors.lua", "workspaces.lua" }) do
	local path = hypr .. name
	local file = io.open(path, "r")
	if file then
		file:close()
		dofile(path)
	end
end
