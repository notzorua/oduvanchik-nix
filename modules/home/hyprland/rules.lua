-- Правила окон, слоёв и рабочих столов (Lua). Было: windowrules.nix (windowrule, layerrule,
-- workspace) и правило для пустых окон XWayland в extraConfig файла hyprland.nix.
--
-- Правило окна:  было "match:class ^(mpv)$, float on"
--                стало hl.window_rule({ match = { class = "^(mpv)$" }, float = true })
-- В match — условия (что за окно), рядом — эффекты (что с ним сделать). Несколько эффектов
-- с одним условием теперь в одном правиле, а не в нескольких строках.
-- Значения: on/off → true/false, «size 850 500» → size = "850 500", «rounding 0» → rounding = 0.
-- Неизвестный ключ условия или эффекта — ошибка --verify-config, опечатку не пропустим.

local function rule(match, effects)
	effects.match = match
	return hl.window_rule(effects)
end

local function class(name)
	return { class = "^(" .. name .. ")$" }
end

---------------------------------------------------------------------------
-- Плавающие окна, закреплённые, размеры
---------------------------------------------------------------------------

local floating = {
	"imv",
	"mpv",
	"zenity",
	"waypaper",
	"SoundWireServer",
	".sameboy-wrapped",
	"org.gnome.Calculator",
	"org.gnome.FileRoller",
	"org.pulseaudio.pavucontrol",
}
for _, name in ipairs(floating) do
	rule(class(name), { float = true })
end

rule(class("rofi"), { pin = true })
rule(class("waypaper"), { pin = true })
rule(class("Aseprite"), { tile = true })

rule(class("zenity"), { size = "850 500" })
rule(class("SoundWireServer"), { size = "725 330" })

-- Было две строки с одним условием — теперь одно правило с двумя эффектами.
rule({ title = "^(Volume Control)$" }, { size = "700 450", move = "40 55%" })
rule({ title = "^(Picture-in-Picture)$" }, { pin = true, float = true })

-- Окно перевода pyugt: было четыре строки с одним условием.
rule(
	{ class = "^(Tk)$", title = "^(pyugt translation)$" },
	{ float = true, pin = true, size = "300 1000", move = "2200 220" }
)

---------------------------------------------------------------------------
-- На какой рабочий стол открывать
---------------------------------------------------------------------------

local workspaces = {
	["zen-beta"] = "1",
	["Gimp-2.10"] = "4",
	["Aseprite"] = "4",
	["Audacious"] = "5",
	["Spotify"] = "5",
	["com.obsproject.Studio"] = "8",
	["discord"] = "10",
	["WebCord"] = "10",
	["vesktop"] = "10",
}
for name, ws in pairs(workspaces) do
	rule(class(name), { workspace = ws })
end

---------------------------------------------------------------------------
-- Не гасить экран (idle_inhibit), затемнение, оформление
---------------------------------------------------------------------------

rule(class("mpv"), { idle_inhibit = "focus" })
rule({ class = "^(zen-beta)$", title = "^(.*YouTube.*)$" }, { idle_inhibit = "focus" })
rule(class("zen"), { idle_inhibit = "fullscreen" })

rule(class("xdg-desktop-portal-gtk"), { dim_around = true })

rule({ xwayland = true }, { rounding = 0 })
rule({ fullscreen = true }, { border_size = 0 }) -- было match:fullscreen 1

-- Одно окно на столе — без рамки и скругления (вместе с правилами рабочих столов ниже).
-- Было match:float 0 → float = false.
for _, ws in ipairs({ "w[tv1]", "f[1]" }) do
	rule({ float = false, workspace = ws }, { border_size = 0, rounding = 0 })
end

-- Пустые служебные окна XWayland (часто — меню и значки в трее у Wine) — прозрачные и плавающие.
-- Было в extraConfig файла hyprland.nix одной строкой windowrule.
rule(
	{ xwayland = true, title = "^$", class = "^$", initial_class = "^$", initial_title = "^$" },
	{ opacity = "0.0", float = true, no_blur = true }
)

---------------------------------------------------------------------------
-- Слои (панели, меню) и рабочие столы
---------------------------------------------------------------------------

-- Было layerrule = [ "match:namespace rofi, dim_around on" … ].
hl.layer_rule({ match = { namespace = "rofi" }, dim_around = true })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, dim_around = true })
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })

-- Одно окно на столе — без отступов. Было workspace = [ "w[tv1], gapsout:0, gapsin:0" … ].
for _, ws in ipairs({ "w[tv1]", "f[1]" }) do
	hl.workspace_rule({ workspace = ws, gaps_out = 0, gaps_in = 0 })
end
