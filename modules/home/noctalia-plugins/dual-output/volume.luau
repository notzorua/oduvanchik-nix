local command = "noctalia-dual-output"
local outputs = {}
local watching = false
local opened = false
local busy = false
local errorText = nil
local render

local function change(action, output)
  if busy then return end
  busy = true
  errorText = nil
  if not noctalia.runAsync({ command, action, output }, function(result)
    busy = false
    errorText = if result.exitCode == 0 then nil else "Could not change audio settings"
    if opened then render() end
  end) then
    busy = false
    errorText = "Could not start audio controls"
  end
  render()
end

local function outputRow(id, title, glyph, accent)
  local output = outputs[id]
  local enabled = output ~= nil and not busy
  local muted = output ~= nil and output.muted
  local color = if output and not muted then accent else "on_surface_variant"
  local level = if output then output.volume .. "%" else "Disconnected"

  return ui.column({ key = id, gap = 6, align = "stretch" }, {
    ui.row({ align = "center", gap = 6 }, {
      ui.button({
        glyph = if muted then "volume-off" else glyph,
        variant = "ghost", controlSize = "sm", selected = muted, enabled = enabled,
        tooltip = if muted then "Unmute" else "Mute",
        onClick = function() change("toggle", id) end,
      }),
      ui.label({ text = title, flexGrow = 1 }),
      ui.label({ text = level, fontFamily = "Maple Mono", fontSize = 13, color = color }),
      ui.button({
        text = "−", variant = "ghost", controlSize = "sm", enabled = enabled,
        tooltip = "Decrease volume by 5 points", onClick = function() change("down", id) end,
      }),
      ui.button({
        text = "+", variant = "ghost", controlSize = "sm", enabled = enabled,
        tooltip = "Increase volume by 5 points", onClick = function() change("up", id) end,
      }),
    }),
    ui.progress({
      progress = if output then math.clamp(output.volume / 100, 0, 1) else 0,
      fill = color, track = "surface_container", radius = 2, height = 3,
    }),
  })
end

render = function()
  local master = outputs.combined
  local masterLevel = if not master then "Disconnected"
    elseif master.muted then "Muted"
    else master.volume .. "%"
  local children = {
    ui.row({ align = "center", gap = 10 }, {
      ui.label({ text = "Speakers + Headphones", fontSize = 17, fontWeight = "bold", flexGrow = 1 }),
      ui.label({ text = masterLevel, fontSize = 13, color = "on_surface_variant" }),
    }),
    outputRow("speakers", "Realtek speakers", "device-speaker", "primary"),
    outputRow("headphones", "Redmi Buds 4 Active", "headphones", "secondary"),
    ui.button({
      text = "Match volumes", variant = "outline", controlSize = "sm",
      tooltip = "Lower the louder output to match the quieter one",
      enabled = outputs.speakers ~= nil and outputs.headphones ~= nil and not busy,
      onClick = function() change("balance", "both") end,
    }),
  }
  if errorText then
    table.insert(children, ui.label({ text = errorText, color = "error" }))
  end
  panel.render(ui.column({ gap = 14, padding = 16, align = "stretch" }, children))
end

function onOpen()
  opened = true
  if not watching then
    watching = noctalia.runStream(command .. " watch", function(line)
      outputs = noctalia.json.decode(line) or {}
      if opened then render() end
    end)
  end
  render()
end

function onClose()
  opened = false
end
