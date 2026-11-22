-- Короткое затухание при смене фокуса, лёгкое смещение при смене рабочего стола.
hl.curve("frostEase", { type = "bezier", points = { { 0.2, 0.8 }, { 0.25, 1 } } })

local function transition(leaf, speed, style)
	hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = "frostEase", style = style })
end

transition("windowsIn", 2.5, "popin 97%")
transition("windowsOut", 1.6, "popin 98%")
transition("windowsMove", 2.2)
transition("fade", 1.6)
transition("border", 1.8)
transition("workspaces", 2.6, "slidefade 8%")
hl.animation({ leaf = "borderangle", enabled = false })

hl.layer_rule({
	name = "rose-frost-floating-menus",
	match = { namespace = "^(rofi|noctalia-window-switcher)$" },
	dim_around = false,
	blur = true,
	ignore_alpha = 0.45,
})

-- Переходы панелей, уведомлений и OSD рисует Noctalia.
hl.layer_rule({
	name = "noctalia-own-transitions",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
	no_anim = true,
})
