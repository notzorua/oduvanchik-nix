-- Кривые и анимации Hyprland (Lua). Было: settings.nix → animations.bezier / animations.animation.
-- Сами анимации сейчас выключены (animations.enabled = false в settings.nix) — описания сохранены,
-- чтобы включить их одной строкой.
--
-- Кривая:    было  "bounce, 0.175, 0.885, 0.32, 1.275"            (имя, x1, y1, x2, y2)
--            стало hl.curve("bounce", { type = "bezier", points = { {0.175, 0.885}, {0.32, 1.275} } })
-- Анимация:  было  "windowsIn, 1, 4, bounce, popin 60%"          (что, вкл, скорость, кривая, стиль)
--            стало hl.animation({ leaf = "windowsIn", enabled = true, speed = 4,
--                                 bezier = "bounce", style = "popin 60%" })

-- Кривые Безье: две опорные точки {x, y}.
local curves = {
	fluent_decel = { { 0, 0.2 }, { 0.4, 1 } },
	easeOutCirc = { { 0, 0.55 }, { 0.45, 1 } },
	easeOutCubic = { { 0.33, 1 }, { 0.68, 1 } },
	fade_curve = { { 0, 0.55 }, { 0.45, 1 } },
	easeInOutBack = { { 0.68, -0.6 }, { 0.32, 1.6 } },
	bounce = { { 0.175, 0.885 }, { 0.32, 1.275 } },
}

for name, points in pairs(curves) do
	hl.curve(name, { type = "bezier", points = points })
end

-- Анимации: { что анимировать, скорость, кривая, стиль (необязательно) }.
local animations = {
	{ "windowsIn", 4, "bounce", "popin 60%" }, -- окна открываются снизу с пружиной
	{ "windowsOut", 3, "easeOutCubic", "popin 80%" }, -- закрываются с затуханием
	{ "windowsMove", 3, "easeInOutBack", "slide" }, -- перемещение окон

	{ "fadeIn", 3, "fade_curve" },
	{ "fadeOut", 3, "fade_curve" },
	{ "fadeSwitch", 2, "easeOutCirc" },
	{ "fadeShadow", 6, "easeOutCirc" },
	{ "fadeDim", 4, "fluent_decel" },

	{ "border", 3, "easeOutCirc" }, -- рамка
	{ "borderangle", 60, "fluent_decel", "loop" },

	{ "workspaces", 4, "easeOutCubic", "slidefade 30%" }, -- переключение рабочих столов со слайдом
}

for _, a in ipairs(animations) do
	hl.animation({ leaf = a[1], enabled = true, speed = a[2], bezier = a[3], style = a[4] })
end
