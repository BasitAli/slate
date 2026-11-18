--!nonstrict
-- Block cards styled like sticky-notes: filled rounded card, body, separator,
-- footer with meta + outline sm actions. Actions via state.request → service.

local seq = tonumber(noctalia.formatTime("%s")) or 0

local function request(action: string, extra: table?)
  seq = seq + 1
  local req = { seq = seq, action = action }
  if type(extra) == "table" then
    for k, v in pairs(extra) do
      req[k] = v
    end
  end
  noctalia.state.set("request", req)
end

local function trunc(s: string, n: number): string
  if type(s) ~= "string" then
    return ""
  end
  if #s <= n then
    return s
  end
  return s:sub(1, n - 1) .. "…"
end

local function header()
  return ui.row({ align = "center", justify = "space_between", gap = 8 }, {
    ui.label({
      text = noctalia.tr("title"),
      fontSize = 16,
      fontWeight = "bold",
      color = "on_surface",
      flexGrow = 1,
    }),
    ui.button({
      glyph = "refresh",
      variant = "outline",
      controlSize = "sm",
      tooltip = noctalia.tr("refresh"),
      onClick = function()
        request("refresh")
      end,
    }),
    ui.button({
      glyph = "close",
      variant = "outline",
      controlSize = "sm",
      onClick = function()
        panel.close()
      end,
    }),
  })
end

local function offerBanner(offer)
  return ui.column({
    key = "offer",
    fill = "primary_container",
    radius = 8,
    padding = 10,
    gap = 6,
  }, {
    ui.label({
      text = noctalia.tr("offer_title"),
      fontWeight = "bold",
      color = "on_primary_container",
      fontSize = 13,
    }),
    ui.label({
      text = tostring(offer.label or offer.token),
      color = "on_primary_container",
      fontSize = 12,
      maxLines = 2,
    }),
    ui.separator({}),
    ui.row({ align = "center", justify = "end", gap = 4 }, {
      ui.button({
        glyph = "player-play",
        text = noctalia.tr("open_session"),
        variant = "outline",
        controlSize = "sm",
        onClick = function()
          request("open", { token = offer.token })
        end,
      }),
      ui.button({
        glyph = "bookmark",
        text = noctalia.tr("park"),
        variant = "outline",
        controlSize = "sm",
        onClick = function()
          request("park", { token = offer.token })
        end,
      }),
      ui.button({
        glyph = "close",
        variant = "outline",
        controlSize = "sm",
        onClick = function()
          request("dismiss_offer")
        end,
      }),
    }),
  })
end

-- Same distinct dark hues as kitty-window-bg / slate open (readable light text).
local CARD_BG = {
  "#1a1028",
  "#10201a",
  "#201010",
  "#102028",
  "#281810",
  "#101828",
  "#182010",
  "#281028",
}
local CARD_FG = "#e8e8e8"
local CARD_MUTED = "#a8a8a8"

local function cardFill(id: string, index: number): string
  -- Stable per id so refresh doesn’t reshuffle; index breaks ties.
  local h = 0
  for i = 1, #id do
    h = (h * 31 + string.byte(id, i)) % 2147483647
  end
  return CARD_BG[((h + index) % #CARD_BG) + 1]
end

-- Sticky-notes-style card: dark fill + radius 8 + padding 10 + body / sep / footer.
local function blockCard(b, index)
  local chips = ""
  if type(b.chips) == "table" and #b.chips > 0 then
    chips = table.concat(b.chips, " · ")
  end
  local nxt = trunc(b.next or "", 120)
  local note = trunc(b.note or "", 100)
  local meta = tostring(b.profile or "")
  if chips ~= "" then
    meta = meta .. " · " .. chips
  end
  local fill = cardFill(tostring(b.id or index), index)

  local bodyKids = {
    ui.label({
      text = tostring(b.title or b.id),
      fontWeight = "bold",
      fontSize = 14,
      color = CARD_FG,
      maxLines = 2,
    }),
  }
  if nxt ~= "" then
    table.insert(bodyKids, ui.label({
      text = "next: " .. nxt,
      fontSize = 12,
      color = CARD_FG,
      maxLines = 3,
    }))
  end
  if note ~= "" then
    table.insert(bodyKids, ui.label({
      text = note,
      fontSize = 12,
      color = CARD_MUTED,
      maxLines = 3,
    }))
  end

  local openToken = b.open
  local actions = {
    ui.button({
      glyph = "player-play",
      variant = "outline",
      controlSize = "sm",
      tooltip = noctalia.tr("open"),
      enabled = type(openToken) == "string" and openToken ~= "",
      onClick = function()
        if type(openToken) == "string" and openToken ~= "" then
          request("open", { token = openToken })
        end
      end,
    }),
    ui.button({
      glyph = "check",
      variant = "outline",
      controlSize = "sm",
      tooltip = noctalia.tr("done"),
      onClick = function()
        request("done", { token = b.id })
      end,
    }),
  }

  return ui.column({
    key = "card-" .. tostring(b.id),
    fill = fill,
    radius = 8,
    padding = 10,
    gap = 6,
    align = "stretch",
  }, {
    ui.column({ gap = 4, align = "stretch" }, bodyKids),
    ui.separator({}),
    ui.row({ align = "center", justify = "space_between" }, {
      ui.label({ text = meta, fontSize = 10, color = CARD_MUTED, flexGrow = 1 }),
      ui.row({ gap = 4, align = "center" }, actions),
    }),
  })
end

local function emptyState()
  return ui.column({
    flexGrow = 1,
    align = "center",
    justify = "center",
    gap = 14,
  }, {
    ui.glyph({ name = "clipboard-list", size = 48, color = "on_surface_variant" }),
    ui.label({
      text = noctalia.tr("empty"),
      fontSize = 13,
      color = "on_surface_variant",
      textAlign = "center",
    }),
  })
end

local function render()
  local blocksState = noctalia.state.get("blocks")
  local items = (type(blocksState) == "table" and type(blocksState.items) == "table")
      and blocksState.items
    or {}
  local offer = noctalia.state.get("offer")

  local listKids = {}
  if type(offer) == "table" and offer.token then
    table.insert(listKids, offerBanner(offer))
  end
  if #items == 0 and not (type(offer) == "table" and offer.token) then
    table.insert(listKids, emptyState())
  else
    for i, b in ipairs(items) do
      if i > 16 then
        break
      end
      table.insert(listKids, blockCard(b, i))
    end
  end

  panel.render(ui.column({
    flexGrow = 1,
    gap = 8,
    padding = 8,
    justify = "start",
    align = "stretch",
  }, {
    header(),
    ui.scroll({ flexGrow = 1, gap = 4, align = "stretch", justify = "start" }, listKids),
  }))
end

function update()
  render()
end

function onOpen(_context)
  request("refresh")
  noctalia.state.watch("blocks", function()
    render()
  end)
  noctalia.state.watch("offer", function()
    render()
  end)
  render()
end
