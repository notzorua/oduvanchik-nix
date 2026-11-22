
-- Фоновые программы — в том же порядке, что были.
local services = {
	"lock", -- экран блокировки сразу после входа (скрипт lock — hyprlock.nix)
	"nm-applet",
	"poweralertd",
	"wl-clip-persist --clipboard regular",
	"wl-paste --type text --watch cliphist store",
	"wl-paste --type image --watch cliphist store",
	"hyprtime watch",
	"udiskie --automount --notify --smart-tray",
	"xrdb -merge ~/.Xresources",
	"hyprctl setcursor Qogir-Light 48", -- setcursor — не dispatch, в Lua-режиме работает
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
