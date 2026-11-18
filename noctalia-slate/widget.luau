--!nonstrict
-- Bar pill: "My Slate" / "My Slate (N)" + glyph. Click opens panel.

local PANEL = "basitali/noctalia-slate:panel"
local LABEL = "My Slate"

local function cfg(key)
  return noctalia.getConfig(key)
end

local function snap()
  local b = noctalia.state.get("blocks")
  local items = (type(b) == "table" and type(b.items) == "table") and b.items or {}
  local offer = noctalia.state.get("offer")
  return items, (type(offer) == "table" and offer.token ~= nil)
end

local function render()
  local items, hasOffer = snap()
  local n = #items
  local glyph = cfg("glyph")
  if type(glyph) ~= "string" or glyph == "" then
    glyph = "clipboard-list"
  end
  local color = hasOffer and "primary" or "on_surface"
  local text = n > 0 and (LABEL .. " (" .. tostring(n) .. ")") or LABEL

  local kids = {
    ui.glyph({ name = glyph, color = color }),
    ui.label({
      text = text,
      fontSize = 11,
      fontWeight = "bold",
      color = color,
    }),
  }
  if hasOffer then
    table.insert(kids, ui.box({
      width = 6,
      height = 6,
      radius = 3,
      fill = "primary",
    }))
  end

  if barWidget.isVertical and barWidget.isVertical() then
    barWidget.render(ui.column({ align = "center", gap = 2 }, kids))
  else
    barWidget.render(ui.row({ align = "center", gap = 4 }, kids))
  end

  if n == 0 then
    barWidget.setTooltip(LABEL .. " — /slate in launcher")
  else
    barWidget.setTooltip(LABEL .. ": " .. n .. " open")
  end
end

function onClick()
  noctalia.togglePanel(PANEL)
end

function update()
  render()
end

noctalia.state.watch("blocks", function()
  render()
end)
noctalia.state.watch("offer", function()
  render()
end)
render()
