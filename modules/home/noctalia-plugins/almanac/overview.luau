local dialSize = 208

local function clockFace(hour, minute)
  local center = dialSize / 2
  local children = {}
  -- The native row lays out each stroke from the left. Translate its centre to
  -- the point on the dial and rotate about that centre; transformations are paint-only.
  local rowX = 0
  local function stroke(key, degrees, distance, width, length, color)
    local angle = math.rad(degrees)
    table.insert(children, ui.box({
      key = key, width = width, height = length, fill = color, radius = width / 2,
      translateX = center + math.sin(angle) * distance - rowX - width / 2,
      translateY = -math.cos(angle) * distance,
      rotation = degrees,
    }))
    rowX = rowX + width
  end

  for tick = 0, 59 do
    local isHour = tick % 5 == 0
    local length = isHour and 8 or 3
    stroke("tick-" .. tick, tick * 6, center - 10 - length / 2,
      isHour and 2 or 1, length, isHour and "on_surface_variant" or "outline_variant")
  end
  stroke("hour", (hour % 12 + minute / 60) * 30, 23, 5, 54, "primary")
  stroke("minute", minute * 6, 33, 3, 74, "secondary")
  stroke("pivot", 0, 0, 7, 7, "on_surface")

  return ui.row({
    key = "dial", width = dialSize, height = dialSize, align = "center", gap = 0,
    fill = "surface_container", radius = center, border = "outline_variant", borderWidth = 1,
  }, children)
end

local function openCalendar()
  noctalia.runAsync({ "noctalia", "msg", "panel-toggle", "control-center", "calendar" })
end

local function localCover(url)
  if url:sub(1, 7) == "file://" then
    url = url:sub(8):gsub("%%(%x%x)", function(code)
      return string.char(tonumber(code, 16))
    end)
  end
  if url:sub(1, 1) == "/" and noctalia.fileExists(url) then return url end
end

local function playbackButton(glyph, tooltip, action)
  return ui.button({
    glyph = glyph, tooltip = tooltip, controlSize = "sm", variant = "ghost",
    onClick = function() noctalia.runAsync({ "noctalia", "msg", "media", action }) end,
  })
end

local function mediaSection(player, cover)
  local artwork = cover and ui.image({
    key = "cover", path = cover, width = 52, height = 52, radius = 5, fit = "cover",
  }) or ui.glyph({ name = "disc", size = 32, width = 52, color = "secondary" })
  local artists = table.concat(player.artists, ", ")
  local playing = player.status == "Playing"
  return ui.column({ gap = 8, align = "stretch" }, {
    ui.separator({ color = "outline_variant" }),
    ui.row({ gap = 12, align = "center" }, {
      artwork,
      ui.column({ gap = 3, flexGrow = 1 }, {
        ui.label({ text = player.title ~= "" and player.title or player.identity,
          maxWidth = 202, maxLines = 1, fontSize = 15, fontWeight = "bold" }),
        ui.label({ text = artists ~= "" and artists or player.album, maxWidth = 202,
          maxLines = 1, fontSize = 12, color = "on_surface_variant" }),
      }),
    }),
    ui.row({ justify = "center", gap = 8 }, {
      playbackButton("player-track-prev", "Previous track", "previous"),
      playbackButton(playing and "player-pause" or "player-play", playing and "Pause" or "Play", "toggle"),
      playbackButton("player-track-next", "Next track", "next"),
    }),
  })
end

local lastView
function update()
  local now = os.time()
  local time = os.date("*t", now)
  local date = noctalia.formatTime("{:%A, %d %B}", now)
  local player = noctalia.mediaPlayer()
  local cover = player and localCover(player.artUrl)
  local view = { time.hour, time.min, date }
  if player then
    table.insert(view, player.title)
    table.insert(view, player.identity)
    table.insert(view, table.concat(player.artists, ", "))
    table.insert(view, player.album)
    table.insert(view, player.status)
    table.insert(view, cover or "")
  end
  local signature = table.concat(view, "\n")
  if signature == lastView then return end
  lastView = signature

  local children = {
    ui.column({ gap = 14, paddingV = 10, align = "center" }, {
      clockFace(time.hour, time.min),
      ui.button({ text = date, glyph = "calendar-month", variant = "ghost",
        tooltip = "Open calendar", onClick = openCalendar }),
    }),
  }
  if player then table.insert(children, mediaSection(player, cover)) end
  panel.render(ui.column({ gap = 12, padding = 18, align = "stretch" }, children))
end

function onOpen()
  lastView = nil
  panel.setWantsSecondTicks(true)
  update()
end

function onClose()
  panel.setWantsSecondTicks(false)
end
