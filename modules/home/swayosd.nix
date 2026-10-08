{ pkgs, ... }:
{
  home.packages = with pkgs; [ swayosd ];

  # Привязки громкости, яркости и индикаторов — на Lua (~/.config/hypr/swayosd.lua).
  # Флаги старых списков стали опциями hl.bind:
  #   binde  (повтор при удержании)          → { repeating = true }
  #   bindl  (работает на экране блокировки) → { locked = true }
  #   bindel (оба)                           → { locked = true, repeating = true }
  #   bindr  (при отпускании клавиши)        → { release = true }
  wayland.windowManager.hyprland.extraLuaFiles.swayosd.content = ''
    local function osd(args)
    	return hl.dsp.exec_cmd("swayosd-client " .. args)
    end

    -- description — для списка привязок (show-keybinds).
    local function bind(keys, description, dispatcher, opts)
    	opts = opts or {}
    	opts.description = description
    	return hl.bind(keys, dispatcher, opts)
    end

    -- Сервер всплывающих индикаторов. Было: exec-once = [ "swayosd-server" ].
    hl.on("hyprland.start", function()
    	hl.exec_cmd("swayosd-server")
    end)

    bind("XF86AudioMute", "звук: выключить/включить", osd("--output-volume mute-toggle"))
    bind("XF86AudioMicMute", "микрофон: выключить/включить", hl.dsp.exec_cmd("toggle-mic"))

    bind("SUPER + XF86MonBrightnessUp", "яркость: максимум", osd("--brightness 100"), { locked = true })
    bind("SUPER + XF86MonBrightnessDown", "яркость: минимум", osd("--brightness 0"), { locked = true })

    bind("XF86MonBrightnessUp", "яркость: больше", osd("--brightness raise"), { locked = true, repeating = true })
    bind("XF86MonBrightnessDown", "яркость: меньше", osd("--brightness lower"), { locked = true, repeating = true })

    bind("XF86AudioRaiseVolume", "громкость: больше", osd("--output-volume +2"), { repeating = true })
    bind("XF86AudioLowerVolume", "громкость: меньше", osd("--output-volume -2"), { repeating = true })
    bind("SUPER + f11", "громкость: больше", osd("--output-volume +2"), { repeating = true })
    bind("SUPER + f12", "громкость: меньше", osd("--output-volume -2"), { repeating = true })

    bind("CAPS + Caps_Lock", "индикатор Caps Lock", osd("--caps-lock"), { release = true })
    bind("Scroll_Lock", "индикатор Scroll Lock", osd("--scroll-lock"), { release = true })
    bind("Num_Lock", "индикатор Num Lock", osd("--num-lock"), { release = true })
  '';

  xdg.configFile."swayosd/config.toml".text = ''
    [server]
    max_volume = 100
    show_percentage = true
  '';

  xdg.configFile."swayosd/style.css".text = ''
    window {
        padding: 0px 10px;
        border-radius: 25px;
        border: 10px;
        background: alpha(#282828, 0.99);
    }

    #container {
        margin: 15px;
    }

    image, label {
        color: #FBF1C7;
    }

    progressbar:disabled,
    image:disabled {
        opacity: 0.95;
    }

    progressbar {
        min-height: 6px;
        border-radius: 999px;
        background: transparent;
        border: none;
    }
    trough {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background: alpha(#DDDDDD, 0.2);
    }
    progress {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background: #FBF1C7;
    }
  '';
}
