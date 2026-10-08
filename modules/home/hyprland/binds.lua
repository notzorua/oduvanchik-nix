-- Привязки клавиш Hyprland (Lua). Было: binds.nix — списки bind/bindm в формате hyprlang.
--
-- Как читать:  bind("МОДИФИКАТОРЫ + КЛАВИША", "описание", ЧТО_СДЕЛАТЬ, { опции })
--   было  "SUPER, Q, killactive,"   →  bind("SUPER + Q", "закрыть окно", hl.dsp.window.close())
-- bind — короткая обёртка над hl.bind (ниже): кладёт описание в опцию description. Описания
-- показывает show-keybinds (SUPER + F1): у Lua-привязок hyprctl binds вместо команды пишет
-- «__lua», так что без описаний список был бы непонятен.
-- Что сделать — «диспетчер» из hl.dsp: exec_cmd, focus, window.move, window.resize…
-- Запуск с правилами окна: было exec, [float; size 1111 700] cmd
--                          стало hl.dsp.exec_cmd("cmd", { float = true, size = "1111 700" })
-- Внимание: имена правил в таблице проверяются только при нажатии, не --verify-config.
--
-- Аргументы диспетчеров сверены с исходником Hyprland v0.56.2
-- (src/config/lua/bindings/LuaBindingsDispatchers.cpp) и проверены --verify-config.

local mod = "SUPER"

local function bind(keys, description, dispatcher, opts)
	opts = opts or {}
	opts.description = description
	return hl.bind(keys, dispatcher, opts)
end

-- Короткая запись для запуска программ.
local function exec(cmd, rules)
	return hl.dsp.exec_cmd(cmd, rules)
end

-- Было: binds { scroll_event_delay, movefocus_cycles_fullscreen } в settings.
hl.config({
	binds = {
		scroll_event_delay = 100,
		movefocus_cycles_fullscreen = true,
	},
})

---------------------------------------------------------------------------
-- Программы
---------------------------------------------------------------------------

bind(mod .. " + F1", "список привязок", exec("show-keybinds"))

bind(mod .. " + Return", "терминал", exec("ghostty --gtk-single-instance=true"))
bind("ALT + Return", "терминал в плавающем окне", exec("ghostty", { float = true, size = "1111 700" }))
bind(mod .. " + SHIFT + Return", "терминал на весь экран", exec("ghostty", { fullscreen = true }))
bind(mod .. " + B", "браузер Zen на столе 1", exec("zen-beta", { workspace = "1 silent" }))
bind(mod .. " + D", "меню программ (rofi)", exec("toggle-rofi rofi -show drun"))
bind(
	mod .. " + SHIFT + D",
	"Vesktop (Discord)",
	exec("vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland")
)
-- Было через hyprctl dispatch exec '[workspace 5 silent] …' — теперь правило прямо здесь.
bind(mod .. " + SHIFT + S", "SoundWireServer на столе 5", exec("SoundWireServer", { workspace = "5 silent" }))
bind("ALT + Escape", "заблокировать экран", exec("hyprlock"))
bind(mod .. " + SHIFT + Escape", "меню выключения", exec("power-menu"))
bind(mod .. " + E", "файлы (Nemo)", exec("nemo"))
bind("ALT + E", "файлы (Nemo) в плавающем окне", exec("nemo", { float = true, size = "1111 700" }))
bind(mod .. " + SHIFT + B", "показать/скрыть Waybar", exec("toggle-waybar"))
bind(mod .. " + C", "пипетка: цвет с экрана", exec("hyprpicker -a"))
bind(mod .. " + W", "выбрать обои", exec("wallpaper-picker"))
bind(mod .. " + SHIFT + W", "Waypaper в плавающем окне", exec("waypaper", { float = true, size = "925 615" }))
bind(mod .. " + N", "уведомления (swaync)", exec("swaync-client -t -sw"))
bind("CTRL + SHIFT + Escape", "Mission Center на столе 9", exec("missioncenter", { workspace = "9" }))
bind(mod .. " + equal", "лупа (woomer)", exec("woomer"))
bind(mod .. " + ALT + S", "включить/выключить экранный чтец Orca", exec("pkill -x orca || orca"))

-- Снимки экрана и распознавание текста. [[…]] — строка Lua без экранирования кавычек.
bind("F11", "снимок экрана в буфер", exec("grim - | wl-copy"))
bind(
	"CTRL + F11",
	"снимок области с правкой (satty)",
	exec([[grim -g "$(slurp)" - | satty --filename - --fullscreen --early-exit --copy-command "wl-copy" && wl-paste | wl-copy]])
)
bind(mod .. " + CTRL + O", "распознать текст с экрана (OCR)", exec("ocr"))

-- Буфер обмена (cliphist)
bind(
	mod .. " + V",
	"история буфера обмена",
	exec(
		[[toggle-rofi "cliphist list | rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' | cliphist decode | wl-copy"]]
	)
)

---------------------------------------------------------------------------
-- Окна
---------------------------------------------------------------------------

bind(mod .. " + Q", "закрыть окно", hl.dsp.window.close()) -- было killactive
-- было fullscreen, 0: полный экран, переключить
bind(mod .. " + F", "полный экран", hl.dsp.window.fullscreen())
-- было fullscreenstate, 2: внутри Hyprland — полный экран, программе об этом не сообщаем.
-- В Lua «оставить как есть» (-1) не поддерживается, поэтому client = 0; поведение проверить вручную.
bind(
	mod .. " + SHIFT + F",
	"полный экран без сообщения программе",
	hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" })
)
bind(mod .. " + Space", "плавающее/закреплённое окно", exec("toggle-float"))
bind(mod .. " + P", "псевдоплитка", hl.dsp.window.pseudo())
bind(mod .. " + X", "сменить направление деления", hl.dsp.layout("togglesplit")) -- было layoutmsg, togglesplit
bind(mod .. " + T", "прозрачность окон", exec("toggle-oppacity"))

-- Фокус на плавающее / закреплённое окно. Было: exec, hyprctl dispatch focuswindow floating —
-- в Lua-режиме hyprctl dispatch принимает только Lua, поэтому вызываем диспетчер напрямую.
bind("CTRL + ALT + up", "фокус на плавающее окно", hl.dsp.focus({ window = "floating" }))
bind("CTRL + ALT + down", "фокус на закреплённое окно", hl.dsp.focus({ window = "tiled" }))

-- Направления: стрелки и hjkl. Было по четыре строки на каждое действие —
-- movefocus l / movewindow l / resizeactive -80 0 / moveactive -80 0.
local step = 80
local directions = {
	{ keys = { "left", "h" }, dir = "left", name = "влево", x = -step, y = 0 },
	{ keys = { "right", "l" }, dir = "right", name = "вправо", x = step, y = 0 },
	{ keys = { "up", "k" }, dir = "up", name = "вверх", x = 0, y = -step },
	{ keys = { "down", "j" }, dir = "down", name = "вниз", x = 0, y = step },
}

for _, d in ipairs(directions) do
	for _, key in ipairs(d.keys) do
		-- Было две привязки на одну клавишу: movefocus и alterzorder top.
		-- hl.bind добавляет привязку так же, как hyprlang, — сработают обе, как раньше.
		bind(mod .. " + " .. key, "фокус " .. d.name, hl.dsp.focus({ direction = d.dir }))
		bind(mod .. " + " .. key, "поднять окно наверх", hl.dsp.window.alter_zorder({ mode = "top" }))

		bind(mod .. " + SHIFT + " .. key, "переместить окно " .. d.name, hl.dsp.window.move({ direction = d.dir }))
		bind(
			mod .. " + CTRL + " .. key,
			"изменить размер " .. d.name,
			hl.dsp.window.resize({ x = d.x, y = d.y, relative = true })
		)
		bind(
			mod .. " + ALT + " .. key,
			"сдвинуть плавающее окно " .. d.name,
			hl.dsp.window.move({ x = d.x, y = d.y, relative = true })
		)
	end
end

-- Мышь. Было bindm = [ "SUPER, mouse:272, movewindow" … ].
bind(mod .. " + mouse:272", "перетащить окно мышью", hl.dsp.window.drag(), { mouse = true })
bind(mod .. " + mouse:273", "изменить размер мышью", hl.dsp.window.resize(), { mouse = true })

---------------------------------------------------------------------------
-- Рабочие столы
---------------------------------------------------------------------------

-- Было по строке на каждый: "SUPER, 1, workspace, 1" и "SUPER SHIFT, 1, movetoworkspacesilent, 1".
for i = 1, 10 do
	local key = i % 10 -- десятый стол — клавиша 0
	bind(mod .. " + " .. key, "стол " .. i, hl.dsp.focus({ workspace = i }))
	-- follow = false — окно уезжает, а вы остаётесь (было movetoworkspacesilent)
	bind(
		mod .. " + SHIFT + " .. key,
		"отправить окно на стол " .. i .. " (не переходя)",
		hl.dsp.window.move({ workspace = i, follow = false })
	)
end

bind(mod .. " + CTRL + c", "окно на пустой стол", hl.dsp.window.move({ workspace = "empty" }))
bind(mod .. " + mouse_down", "предыдущий стол (колесо)", hl.dsp.focus({ workspace = "e-1" }))
bind(mod .. " + mouse_up", "следующий стол (колесо)", hl.dsp.focus({ workspace = "e+1" }))

---------------------------------------------------------------------------
-- Музыка (playerctl)
---------------------------------------------------------------------------

bind("XF86AudioPlay", "музыка: пауза/продолжить", exec("playerctl play-pause"))
bind("XF86AudioNext", "музыка: следующий трек", exec("playerctl next"))
bind("XF86AudioPrev", "музыка: предыдущий трек", exec("playerctl previous"))
bind("XF86AudioStop", "музыка: стоп", exec("playerctl stop"))
