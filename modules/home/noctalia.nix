{ config, host, inputs, lib, pkgs, ... }:
let
  dualOutput = host == "stem";
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    # Noctalia 5.6 keeps panel alpha and switcher geometry in the shell implementation.
    package = (pkgs.callPackage "${inputs.noctalia}/nix/package.nix" {
      rev = inputs.noctalia.rev or "unknown";
    }).overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        # Read Hyprland creation IDs and keep the focused card in its sorted position.
        patch -p1 <<'PATCH'
        --- a/src/compositors/workspace_backend.h
        +++ b/src/compositors/workspace_backend.h
        @@ -36,4 +36,6 @@
           std::string outputName;
           std::optional<WindowMinimizeState> minimizeState;
        +  std::optional<std::uint32_t> workspaceNumber = std::nullopt;
        +  std::optional<std::uint64_t> creationOrder = std::nullopt;
         };

        @@ -46,4 +48,6 @@
           std::int32_t y = 0;
           std::optional<WindowMinimizeState> minimizeState;
        +  std::optional<std::uint32_t> workspaceNumber = std::nullopt;
        +  std::optional<std::uint64_t> creationOrder = std::nullopt;
         };

        --- a/src/compositors/hyprland/hyprland_workspace_backend.h
        +++ b/src/compositors/hyprland/hyprland_workspace_backend.h
        @@ -101,4 +101,6 @@
             std::int32_t x = 0;
             std::int32_t y = 0;
        +    std::optional<std::uint32_t> workspaceNumber;
        +    std::optional<std::uint64_t> creationOrder;
           };

        --- a/src/compositors/hyprland/hyprland_workspace_backend.cpp
        +++ b/src/compositors/hyprland/hyprland_workspace_backend.cpp
        @@ -178,4 +178,6 @@
                     .y = toplevel.y,
                     .outputName = {},
        +            .workspaceNumber = toplevel.workspaceNumber,
        +            .creationOrder = toplevel.creationOrder,
                 }
             );
        @@ -566,10 +568,16 @@
               const auto identity = parseJsonWorkspaceIdentity(*wsIt, m_ipcSchema);
               if (!identity.has_value()) {
        -        kLog.warn("rejecting malformed Hyprland client workspace identity");
        -        return;
        +        if (!wsIt->contains("type") || (*wsIt)["type"] != "") {
        +          kLog.warn("skipping malformed Hyprland client workspace identity");
        +        }
        +        continue;
               }
               state.workspaceKey = identity->key;
        +      state.workspaceNumber = identity->number;
             } else {
               state.workspaceKey = m_ipcSchema == IpcSchema::LegacyId ? "-1" : std::string{};
        +    }
        +    if (const auto id = item.find("stableId"); id != item.end() && id->is_string()) {
        +      state.creationOrder = compositors::hyprland::parseWindowAddress(id->get_ref<const std::string&>());
             }
             state.appId = item.value("class", "");
        --- a/src/compositors/compositor_platform.cpp
        +++ b/src/compositors/compositor_platform.cpp
        @@ -1612,4 +1612,6 @@
                     .y = window.y,
                     .minimizeState = window.minimizeState,
        +            .workspaceNumber = window.workspaceNumber,
        +            .creationOrder = window.creationOrder,
                 }
             );
        --- a/src/shell/switcher/window_switcher.cpp
        +++ b/src/shell/switcher/window_switcher.cpp
        @@ -237,4 +237,10 @@
           }

        +  std::size_t offsetSelection(std::size_t index, int delta, std::size_t count) {
        +    const auto size = static_cast<long>(count);
        +    const auto offset = (static_cast<long>(index) + delta) % size;
        +    return static_cast<std::size_t>(offset < 0 ? offset + size : offset);
        +  }
        +
           std::string identityKeyForEntry(const WindowSwitcherEntry& entry) { return entry.identityKey; }

        @@ -262,4 +268,8 @@
                   handle != nullptr) {
                 return reinterpret_cast<std::uintptr_t>(handle);
        +      }
        +      if (compositors::isHyprland()) {
        +        // An unrelated window can have the same app id and title.
        +        return 0;
               }
             }
        @@ -325,4 +335,6 @@
             WindowSwitcherEntry entry;
             std::string workspaceKey;
        +    std::optional<std::uint32_t> workspaceNumber;
        +    std::optional<std::uint64_t> creationOrder;
             std::int32_t sortX = 0;
             std::int32_t sortY = 0;
        @@ -346,5 +358,7 @@
             entry.iconPath = resolveWindowIconPath(entry.appId, iconResolver, iconSize);
             entry.closeHandle = resolveCloseHandle(platform, entry.windowId, entry.appId, entry.title);
        -    entry.captureHandle = resolveCaptureHandle(platform.foreignToplevels(), entry.appId, entry.title);
        +    if (!compositors::isHyprland() || entry.windowId.empty()) {
        +      entry.captureHandle = resolveCaptureHandle(platform.foreignToplevels(), entry.appId, entry.title);
        +    } // Hyprland acquires the preview through the exact window identity join below.
             return entry;
           }
        @@ -534,4 +548,6 @@
               candidate.entry = makeEntryFromAssignment(platform, iconResolver, iconSize, assignment);
               candidate.workspaceKey = assignment.workspaceKey;
        +      candidate.workspaceNumber = assignment.workspaceNumber;
        +      candidate.creationOrder = assignment.creationOrder;
               candidate.sortX = assignment.x;
               candidate.sortY = assignment.y;
        @@ -572,5 +588,18 @@
             }

        -    std::ranges::stable_sort(candidates, [](const WindowSwitcherCandidate& a, const WindowSwitcherCandidate& b) {
        +    const bool orderByCreation = compositors::isHyprland() && mruKeys == nullptr;
        +    std::ranges::stable_sort(candidates, [orderByCreation](const WindowSwitcherCandidate& a, const WindowSwitcherCandidate& b) {
        +      if (orderByCreation) {
        +        if (a.workspaceNumber != b.workspaceNumber) {
        +          return a.workspaceNumber && (!b.workspaceNumber || a.workspaceNumber < b.workspaceNumber);
        +        }
        +        if (a.workspaceKey != b.workspaceKey) {
        +          return a.workspaceKey < b.workspaceKey;
        +        }
        +        if (a.creationOrder != b.creationOrder) {
        +          return a.creationOrder && (!b.creationOrder || a.creationOrder < b.creationOrder);
        +        }
        +        return a.entry.identityKey < b.entry.identityKey;
        +      }
               if (a.mruIndex != b.mruIndex) {
                 return a.mruIndex < b.mruIndex;
        @@ -596,5 +625,5 @@
             out.reserve(candidates.size());

        -    if (!focusedKey.empty()) {
        +    if (!orderByCreation && !focusedKey.empty()) {
               for (auto it = candidates.begin(); it != candidates.end(); ++it) {
                 const std::string key = identityKeyForEntry(it->entry);
        @@ -843,13 +872,10 @@
             cycleSelection(direction);
           } else {
        -    bool focusedListedFirst = false;
        -    if (!focusedKey.empty() && !m_windows.empty()) {
        -      const std::string frontKey = identityKeyForEntry(m_windows.front());
        -      focusedListedFirst = identityKeysEqual(frontKey, focusedKey);
        -    }
        -    m_selectedIndex = 0;
        -    if (m_windows.size() > 1 && focusedListedFirst) {
        -      m_selectedIndex = direction < 0 ? m_windows.size() - 1 : 1;
        -    }
        +    const auto focused = std::ranges::find_if(m_windows, [&](const WindowSwitcherEntry& entry) {
        +      return !focusedKey.empty() && identityKeysEqual(identityKeyForEntry(entry), focusedKey);
        +    });
        +    m_selectedIndex = focused == m_windows.end()
        +        ? 0
        +        : offsetSelection(static_cast<std::size_t>(focused - m_windows.begin()), direction, m_windows.size());
           }
           m_active = true;
        @@ -1120,8 +1146,5 @@
             return;
           }
        -  const auto count = m_windows.size();
        -  const auto next = (static_cast<long>(m_selectedIndex) + delta) % static_cast<long>(count);
        -  m_selectedIndex =
        -      next >= 0 ? static_cast<std::size_t>(next) : static_cast<std::size_t>(next + static_cast<long>(count));
        +  m_selectedIndex = offsetSelection(m_selectedIndex, delta, m_windows.size());
           prioritizeSelectedThumbnail();
           syncSelection(true);
        PATCH

        # The header shares the Surface role with popovers.
        substituteInPlace src/shell/bar/bar.cpp \
          --replace-fail 'colorForRole(ColorRole::Surface, instance.barConfig.backgroundOpacity)' \
                         'withAlpha(rgbHex(0x2B2030), instance.barConfig.backgroundOpacity)'

        substituteInPlace src/config/config_types.cpp \
          --replace-fail 'return 0.55F;' 'return 0.72F;'

        substituteInPlace src/shell/panel/panel_manager.cpp \
          --replace-fail '? barConfig.backgroundOpacity' '? std::min(barConfig.backgroundOpacity, 0.76F)' \
          --replace-fail 'const float newOpacity = barConfig.backgroundOpacity;' \
                         'const float newOpacity = std::min(barConfig.backgroundOpacity, 0.76F);'

        substituteInPlace src/shell/switcher/window_switcher_grid_style.cpp \
          --replace-fail '  layout.gridColumns = std::max<std::size_t>(1, std::min<std::size_t>(5, context.windowCount));' "" \
          --replace-fail '  float gap = Style::spaceMd * context.scale;' '  float gap = 32.0F * context.scale;' \
          --replace-fail '  float cardWidth = Style::windowSwitcherCompactCardWidth * context.scale;' '  float cardWidth = 460.0F * context.scale;
          const auto fittingColumns = static_cast<std::size_t>(
              std::max(1.0F, std::floor((maxWidth - 2.0F * padding + gap) / (cardWidth + gap)))
          );
          layout.gridColumns = std::clamp(context.windowCount, std::size_t{1}, fittingColumns);' \
          --replace-fail '    const std::size_t rowColumns = std::min(layout.gridColumns, context.windowCount - row * layout.gridColumns);
            const float rowOffset = static_cast<float>(layout.gridColumns - rowColumns) * columnStride * 0.5F;
            auto& target = layout.cards[index];' '    auto& target = layout.cards[index];' \
          --replace-fail 'target.x = rowOffset + static_cast<float>(index % layout.gridColumns) * columnStride;' \
                         'target.x = static_cast<float>(index % layout.gridColumns) * columnStride;'

        substituteInPlace src/shell/switcher/window_switcher_tile.cpp \
          --replace-fail '  if (m_selected) {' '  if (m_pointerHovered && m_integratedCaption) {
          m_frame->setFill(colorSpecFromRole(ColorRole::Hover, 0.84F));
          m_frame->setBorder(
              colorSpecFromRole(m_selected ? ColorRole::Primary : ColorRole::Secondary), Style::emphasizedBorderWidth
          );
          m_previewHost->setFill(colorSpecFromRole(ColorRole::SurfaceContainerHigh));
        } else if (m_selected && m_integratedCaption) {
          m_frame->setFill(colorSpecFromRole(ColorRole::SurfaceContainer, 0.82F));
          m_frame->setBorder(colorSpecFromRole(ColorRole::Primary), Style::emphasizedBorderWidth);
          m_previewHost->setFill(colorSpecFromRole(ColorRole::SurfaceContainer));
        } else if (m_integratedCaption) {
          m_frame->setFill(colorSpecFromRole(ColorRole::Surface, 0.76F));
          m_frame->setBorder(colorSpecFromRole(ColorRole::OutlineVariant, Style::disabledOutlineAlpha), Style::borderWidth);
          m_previewHost->setFill(colorSpecFromRole(ColorRole::SurfaceContainer));
        } else if (m_selected) {' \
          --replace-fail 'const bool showClose = m_pointerHovered && m_showPreview;' \
                         'const bool showClose = m_pointerHovered && m_showPreview && !m_integratedCaption;'

        substituteInPlace src/shell/switcher/window_switcher.cpp \
          --replace-fail '.opacity = Style::windowSwitcherDimOpacity,' '.opacity = 0.08F,' \
          --replace-fail '.out = &instance.countBackground,
                .fill = colorSpecFromRole(ColorRole::Surface),' '.out = &instance.countBackground,
                .fill = colorSpecFromRole(ColorRole::Surface, 0.76F),' \
          --replace-fail '  if (!instance.revealStarted && instance.panel != nullptr) {' \
                         '  if (!layout.grid && !instance.revealStarted && instance.panel != nullptr) {' \
          --replace-fail '    showFromShortcut(output, modifiers);' '    if (action == "hold") {
          showFromShortcut(output, modifiers);
        } else {
          showWithDirection(output, reverse ? -1 : 1);
        }' \
          --replace-fail '  const std::uint32_t normalizedModifiers = event.modifiers & ~m_shortcutState.modifiers();' '  if (!m_shortcutSession && matchesTrigger(event)) {
                cycleSelection((event.modifiers & KeyMod::Shift) != 0 ? -1 : 1);
                return true;
              }

              const std::uint32_t normalizedModifiers = event.modifiers & ~m_shortcutState.modifiers();' \
          --replace-fail '    if (pressed
                && onTarget
                && (target->inputDispatcher.hoveredArea() == nullptr
                    || target->inputDispatcher.hoveredArea() == target->input)) {
              hide();
              return true;
            }' '    if (pressed && onTarget) {
              const auto* clicked = target->inputDispatcher.inputAreaAt(
                  static_cast<float>(event.sx), static_cast<float>(event.sy)
              );
              if (clicked == nullptr || clicked == target->input) {
                hide();
                return true;
              }
            }'
      '';
    });
    extraPackages = lib.optional dualOutput
      (pkgs.writeShellScriptBin "noctalia-dual-output" ''
        set -euo pipefail
        export PATH=${lib.makeBinPath [ pkgs.pulseaudio pkgs.jq pkgs.coreutils ]}:"$PATH"
        export LC_ALL=C
        ${builtins.readFile ./noctalia-plugins/dual-output.sh}
      '');

    customPalettes."Rose Frost" = {
      version = 2;
      dark = {
        primary = "#F2A9C3";
        on_primary = "#351F2B";
        secondary = "#D4C5E9";
        on_secondary = "#2D2538";
        tertiary = "#B6CBD1";
        on_tertiary = "#233038";
        error = "#E8A0AA";
        on_error = "#391820";
        surface = "#2B2030";
        on_surface = "#F6EEE8";
        surface_container = "#3E2D46";
        on_surface_variant = "#DDD0DF";
        outline_variant = "#787878";
        shadow = "#151515";
        hover = "#626262";
        on_hover = "#FAEFEA";

        # Keep the terminal colors from the previously rendered Noctalia fallback.
        terminal = {
          normal = {
            black = "#292B49";
            red = "#E78B9D";
            green = "#A5D19C";
            yellow = "#F3E09D";
            blue = "#A3B6EB";
            magenta = "#C3A4DD";
            cyan = "#96D2CC";
            white = "#DBD9E8";
          };
          bright = {
            black = "#8589AC";
            red = "#F3A0B0";
            green = "#B8E1B1";
            yellow = "#FAEBB4";
            blue = "#B9C8F5";
            magenta = "#D5B8EC";
            cyan = "#ADE3DC";
            white = "#F5F1FA";
          };
          foreground = "#ECE9F4";
          background = "#15162E";
          cursor = "#F7E9A8";
          cursor_text = "#15162E";
          selection_fg = "#F5F1FA";
          selection_bg = "#42476C";
        };
      };
    };

    settings = {
      theme = {
        source = "custom";
        custom_palette = "Rose Frost";
        mode = "dark";
      };

      shell = {
        panel_anchor_bar = "header";
        lang = "en";
        font_family = "DejaVu Sans";
        corner_radius_scale = 0.75;
        card_borders = false;
        app_icon_color = "on_surface_variant";
        animation.speed = 1.15;
        launcher = {
          layout = "simple";
          width = 720;
          search_position = "top";
          compact = false;
          categories = false;
          colorize_icons = true;
        };
        window_switcher = {
          style = "grid";
          mru = false;
        };
        panel = {
          transparency_mode = "glass";
          shadow = false;
          control_center_placement = "attached";
          control_center_position = "top_right";
          wallpaper_placement = "attached";
          launcher_placement = "floating";
          launcher_position = "center";
          clipboard_placement = "attached";
          session_placement = "attached";
        };
      };

      notification = {
        background_opacity = 0.80;
        border_color = "outline_variant";
        colorize_icons = true;
      };
      osd.background_opacity = 0.80;

      control_center = {
        sidebar = "compact";
        width = 660;
        show_avatar_border = false;
        show_shortcut_labels = true;
      };

      bar.header = {
        position = "top";
        thickness = 34;
        margin_edge = 0;
        margin_ends = 0;
        radius = 0;
        concave_edge_corners = false;
        background_opacity = 0.92;
        compositor_blur = true;
        shadow = false;
        reserve_space = true;
        capsule = false;
        padding = 16;
        widget_spacing = 12;
        start = [ "launcher" "clock" "date" ];
        center = [ "workspaces" ];
        end = [ "privacy" "network" "bluetooth" "notifications" "tray" ]
          ++ [ (if dualOutput then "dual-output" else "battery") "control-center" ];
      };

      widget = {
        launcher = {
          glyph = "apps";
          icon_color = "secondary";
        };
        workspaces = {
          style = "focus_hint";
          show_icons = false;
          focused_color = "primary";
          occupied_color = "secondary";
          empty_color = "surface_container_high";
          urgent_color = "error";
        };
        clock = {
          format = "{:%H:%M}";
          tooltip_format = "{:%A, %d %B}";
          show_glyph = false;
          font_family = "Maple Mono";
          font_weight = 600;
          font_scale = 1.12;
          color = "on_surface";
          actions = {
            left = "panel-toggle control-center calendar";
            right = "panel-toggle zoroa/almanac:overview";
          };
        };
        date = {
          type = "clock";
          format = "{:%d %b}";
          show_glyph = false;
          color = "primary";
          actions.left = "panel-toggle control-center calendar";
        };
        network.show_label = false;
        privacy.hide_inactive = true;
        notifications.hide_when_no_unread = true;
        tray = {
          drawer = true;
          detached_panel = false;
          colorize_icons = true;
        };
        bluetooth.show_label = false;
        control-center = {
          glyph = "adjustments";
          custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
          custom_image_colorize = true;
          icon_color = "#DEDEDE";
        };
      } // lib.optionalAttrs dualOutput {
        dual-output = {
          type = "custom_button";
          glyph = "headphones";
          tooltip = "Speakers and headphones";
          actions.left = "panel-toggle zoroa/dual-output:volume";
        };
      };

      plugins = {
        enabled = lib.optional dualOutput "zoroa/dual-output" ++ [ "zoroa/almanac" ];
        source = [
          {
            name = "desktop";
            kind = "path";
            location = "${./noctalia-plugins}";
            enabled = true;
          }
        ];
      };

      dock.enabled = false;
      desktop_widgets.enabled = false;
      lockscreen.enabled = false;

      wallpaper = {
        enabled = true;
        directory = "${config.home.homeDirectory}/nixos-configuration/wallpapers";
        fill_mode = "crop";
        transition = [ "fade" ];
        transition_duration = 350;
        automation.enabled = false;
      };
    };
  };

  wayland.windowManager.hyprland.extraLuaFiles.noctalia.content = ''
    hl.layer_rule({
      name = "noctalia-rose-frost-blur",
      match = { namespace = "^noctalia-(bar-header|attached-panel|panel|notification|osd)$" },
      blur = true,
      blur_popups = true,
      ignore_alpha = 0.5,
    })

    hl.bind("SUPER + D", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), {
      description = "Open application launcher",
    })

    hl.bind("ALT + Tab", hl.dsp.exec_cmd("noctalia msg window-switcher hold"), {
      description = "Open the window switcher and select the next window",
    })
    hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("noctalia msg window-switcher hold reverse"), {
      description = "Open the window switcher and select the previous window",
    })

    hl.bind("SUPER + W", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"), {
      description = "Choose desktop wallpaper",
    })
  '';

  # Remove the old Rosé Pine override while retaining wallpaper selections and other GUI state.
  home.activation.migrateNoctaliaTheme = lib.mkIf (host == "stem") (lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    run ${lib.getExe pkgs.python3} - "${config.xdg.stateHome}/noctalia/settings.toml" <<'PY'
    import pathlib
    import re
    import sys

    path = pathlib.Path(sys.argv[1])
    if path.is_file():
        before = path.read_text()
        after = re.sub(
            r'^\[theme\]\nbuiltin = "Rosé Pine"\nsource = "builtin"\n(?:\n|$)',
            "",
            before,
            flags=re.MULTILINE,
        )
        if after != before:
            temporary = path.with_name(".settings.toml.arctic-dream")
            temporary.write_text(after)
            temporary.chmod(path.stat().st_mode & 0o777)
            temporary.replace(path)
    PY
  '');
}
