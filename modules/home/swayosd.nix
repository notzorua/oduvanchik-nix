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

    -- Сервер всплывающих индикаторов. Было: exec-once = [ "swayosd-server" ].
    hl.on("hyprland.start", function()
    	hl.exec_cmd("swayosd-server")
    end)

    hl.bind("XF86AudioMute", osd("--output-volume mute-toggle"))
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("toggle-mic"))

    hl.bind("SUPER + XF86MonBrightnessUp", osd("--brightness 100"), { locked = true })
    hl.bind("SUPER + XF86MonBrightnessDown", osd("--brightness 0"), { locked = true })

    hl.bind("XF86MonBrightnessUp", osd("--brightness raise"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", osd("--brightness lower"), { locked = true, repeating = true })

    hl.bind("XF86AudioRaiseVolume", osd("--output-volume +2"), { repeating = true })
    hl.bind("XF86AudioLowerVolume", osd("--output-volume -2"), { repeating = true })
    hl.bind("SUPER + f11", osd("--output-volume +2"), { repeating = true })
    hl.bind("SUPER + f12", osd("--output-volume -2"), { repeating = true })

    hl.bind("CAPS + Caps_Lock", osd("--caps-lock"), { release = true })
    hl.bind("Scroll_Lock", osd("--scroll-lock"), { release = true })
    hl.bind("Num_Lock", osd("--num-lock"), { release = true })
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
