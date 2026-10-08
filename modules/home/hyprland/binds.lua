-- Привязки клавиш Hyprland (Lua). Было: binds.nix — списки bind/bindm в формате hyprlang.
--
-- Как читать:  hl.bind("МОДИФИКАТОРЫ + КЛАВИША", ЧТО_СДЕЛАТЬ, { опции })
--   было  "SUPER SHIFT, Q, killactive,"   →  hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close())
-- Что сделать — «диспетчер» из hl.dsp: exec_cmd, focus, window.move, window.resize…
-- Запуск с правилами окна: было exec, [float; size 1111 700] cmd
--                          стало hl.dsp.exec_cmd("cmd", { float = true, size = "1111 700" })
-- Внимание: имена правил в таблице проверяются только при нажатии, не --verify-config.
--
-- Аргументы диспетчеров сверены с исходником Hyprland v0.56.2
-- (src/config/lua/bindings/LuaBindingsDispatchers.cpp) и проверены --verify-config.

local mod = "SUPER"

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

hl.bind(mod .. " + F1", exec("show-keybinds")) -- список привязок

hl.bind(mod .. " + Return", exec("ghostty --gtk-single-instance=true"))
hl.bind("ALT + Return", exec("ghostty", { float = true, size = "1111 700" }))
hl.bind(mod .. " + SHIFT + Return", exec("ghostty", { fullscreen = true }))
hl.bind(mod .. " + B", exec("zen-beta", { workspace = "1 silent" }))
hl.bind(mod .. " + D", exec("toggle-rofi rofi -show drun"))
hl.bind(mod .. " + SHIFT + D", exec("vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland"))
-- Было через hyprctl dispatch exec '[workspace 5 silent] …' — теперь правило прямо здесь.
hl.bind(mod .. " + SHIFT + S", exec("SoundWireServer", { workspace = "5 silent" }))
hl.bind("ALT + Escape", exec("hyprlock"))
hl.bind(mod .. " + SHIFT + Escape", exec("power-menu"))
hl.bind(mod .. " + E", exec("nemo"))
hl.bind("ALT + E", exec("nemo", { float = true, size = "1111 700" }))
hl.bind(mod .. " + SHIFT + B", exec("toggle-waybar"))
hl.bind(mod .. " + C", exec("hyprpicker -a"))
hl.bind(mod .. " + W", exec("wallpaper-picker"))
hl.bind(mod .. " + SHIFT + W", exec("waypaper", { float = true, size = "925 615" }))
hl.bind(mod .. " + N", exec("swaync-client -t -sw"))
hl.bind("CTRL + SHIFT + Escape", exec("missioncenter", { workspace = "9" }))
hl.bind(mod .. " + equal", exec("woomer"))
hl.bind(mod .. " + ALT + S", exec("pkill -x orca || orca")) -- включить/выключить экранный чтец Orca

-- Снимки экрана и распознавание текста. [[…]] — строка Lua без экранирования кавычек.
hl.bind("F11", exec("grim - | wl-copy"))
hl.bind(
	"CTRL + F11",
	exec([[grim -g "$(slurp)" - | satty --filename - --fullscreen --early-exit --copy-command "wl-copy" && wl-paste | wl-copy]])
)
hl.bind(mod .. " + CTRL + O", exec("ocr"))

-- Буфер обмена (cliphist)
hl.bind(
	mod .. " + V",
	exec(
		[[toggle-rofi "cliphist list | rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' | cliphist decode | wl-copy"]]
	)
)

---------------------------------------------------------------------------
-- Окна
---------------------------------------------------------------------------

hl.bind(mod .. " + Q", hl.dsp.window.close()) -- было killactive
-- было fullscreen, 0: полный экран, переключить
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
-- было fullscreenstate, 2: внутри Hyprland — полный экран, программе об этом не сообщаем.
-- В Lua «оставить как есть» (-1) не поддерживается, поэтому client = 0; поведение проверить вручную.
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))
hl.bind(mod .. " + Space", exec("toggle-float"))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + X", hl.dsp.layout("togglesplit")) -- было layoutmsg, togglesplit
hl.bind(mod .. " + T", exec("toggle-oppacity"))

-- Фокус на плавающее / закреплённое окно. Было: exec, hyprctl dispatch focuswindow floating —
-- в Lua-режиме hyprctl dispatch принимает только Lua, поэтому вызываем диспетчер напрямую.
hl.bind("CTRL + ALT + up", hl.dsp.focus({ window = "floating" }))
hl.bind("CTRL + ALT + down", hl.dsp.focus({ window = "tiled" }))

-- Направления: стрелки и hjkl. Было по четыре строки на каждое действие —
-- movefocus l / movewindow l / resizeactive -80 0 / moveactive -80 0.
local step = 80
local directions = {
	{ keys = { "left", "h" }, dir = "left", x = -step, y = 0 },
	{ keys = { "right", "l" }, dir = "right", x = step, y = 0 },
	{ keys = { "up", "k" }, dir = "up", x = 0, y = -step },
	{ keys = { "down", "j" }, dir = "down", x = 0, y = step },
}

for _, d in ipairs(directions) do
	for _, key in ipairs(d.keys) do
		-- Было две привязки на одну клавишу: movefocus и alterzorder top.
		-- hl.bind добавляет привязку так же, как hyprlang, — сработают обе, как раньше.
		hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = d.dir }))
		hl.bind(mod .. " + " .. key, hl.dsp.window.alter_zorder({ mode = "top" }))

		hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = d.dir }))
		hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }))
		hl.bind(mod .. " + ALT + " .. key, hl.dsp.window.move({ x = d.x, y = d.y, relative = true }))
	end
end

-- Мышь. Было bindm = [ "SUPER, mouse:272, movewindow" … ].
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

---------------------------------------------------------------------------
-- Рабочие столы
---------------------------------------------------------------------------

-- Было по строке на каждый: "SUPER, 1, workspace, 1" и "SUPER SHIFT, 1, movetoworkspacesilent, 1".
for i = 1, 10 do
	local key = i % 10 -- десятый стол — клавиша 0
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	-- follow = false — окно уезжает, а вы остаётесь (было movetoworkspacesilent)
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mod .. " + CTRL + c", hl.dsp.window.move({ workspace = "empty" })) -- на пустой стол и туда же
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

---------------------------------------------------------------------------
-- Музыка (playerctl)
---------------------------------------------------------------------------

hl.bind("XF86AudioPlay", exec("playerctl play-pause"))
hl.bind("XF86AudioNext", exec("playerctl next"))
hl.bind("XF86AudioPrev", exec("playerctl previous"))
hl.bind("XF86AudioStop", exec("playerctl stop"))
