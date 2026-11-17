--!nonstrict
-- Block cards + pending clipboard offer. Actions via state.request → service.

local seq = tonumber(noctalia.formatTime("%s")) or 0
local rowData = {}

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
    ui.label({ text = noctalia.tr("title"), fontSize = 16, fontWeight = "bold", color = "on_surface", flexGrow = 1 }),
    ui.button({ glyph = "refresh", variant = "ghost", onClick = "onRefresh" }),
    ui.button({ glyph = "close", variant = "ghost", onClick = "onClose" }),
  })
end

local function offerBanner(offer)
  local actions = {
    ui.button({ text = noctalia.tr("add"), onClick = "onOfferAdd" }),
  }
  if offer.kind == "jira" then
    table.insert(actions, ui.button({ text = noctalia.tr("open_session"), variant = "ghost", onClick = "onOfferOpen" }))
  end
  table.insert(actions, ui.button({ text = noctalia.tr("dismiss"), variant = "ghost", onClick = "onOfferDismiss" }))
  return ui.column({ gap = 8, paddingV = 6, fill = "primary/0.15", radius = 8, paddingH = 10 }, {
    ui.label({ text = noctalia.tr("offer_title"), fontWeight = "bold", color = "primary" }),
    ui.label({ text = tostring(offer.label or offer.token), color = "on_surface", fontSize = 12 }),
    ui.row({ gap = 6 }, actions),
  })
end
local function card(b, index)
  rowData[index] = b
  local chips = ""
  if type(b.chips) == "table" then
    chips = table.concat(b.chips, " · ")
  end
  local nxt = trunc(b.next or "", 90)
  local note = trunc(b.note or "", 70)
  local sub = chips
  if nxt ~= "" then
    sub = (sub ~= "" and (sub .. "\n") or "") .. "next: " .. nxt
  end
  if note ~= "" then
    sub = (sub ~= "" and (sub .. "\n") or "") .. note
  end

  return ui.column({ gap = 4, paddingV = 6, paddingH = 4 }, {
    ui.row({ align = "center", justify = "space_between", gap = 6 }, {
      ui.column({ gap = 2, flexGrow = 1 }, {
        ui.label({ text = tostring(b.title or b.id), fontWeight = "bold", color = "on_surface" }),
        ui.label({
          text = tostring(b.profile or "") .. " · " .. tostring(b.status or ""),
          fontSize = 11,
          color = "on_surface_variant",
        }),
        ui.label({ text = sub, fontSize = 11, color = "on_surface_variant" }),
      }),
    }),
    ui.row({ gap = 6 }, {
      ui.button({ text = noctalia.tr("open"), variant = "ghost", onClick = "onOpen" .. index }),
      ui.button({ text = noctalia.tr("done"), variant = "ghost", onClick = "onDone" .. index }),
    }),
    ui.separator({}),
  })
end

local function render()
  local blocksState = noctalia.state.get("blocks")
  local items = (type(blocksState) == "table" and type(blocksState.items) == "table") and blocksState.items or {}
  local offer = noctalia.state.get("offer")
  rowData = {}

  local body = {}
  if type(offer) == "table" and offer.token then
    table.insert(body, offerBanner(offer))
  end
  if #items == 0 then
    table.insert(body, ui.label({ text = noctalia.tr("empty"), color = "on_surface_variant" }))
  else
    for i, b in ipairs(items) do
      if i > 16 then
        break
      end
      table.insert(body, card(b, i))
    end
  end

  panel.render(ui.column({ flexGrow = 1, gap = 10 }, {
    header(),
    ui.scroll({ flexGrow = 1, gap = 2 }, body),
  }))
end

function onClose()
  panel.close()
end

function onRefresh()
  request("refresh")
end

function onOfferAdd()
  local offer = noctalia.state.get("offer")
  if type(offer) == "table" then
    request("add", { kind = offer.kind, token = offer.token })
  end
end

function onOfferOpen()
  local offer = noctalia.state.get("offer")
  if type(offer) == "table" and offer.kind == "jira" then
    request("open", { token = offer.token })
  end
end

function onOfferDismiss()
  request("dismiss_offer")
end

local function openAt(i)
  local b = rowData[i]
  if not b then
    return
  end
  -- Prefer jira chip for open; else id won't launch — skip if no jira
  local key = nil
  if type(b.chips) == "table" then
    for _, c in ipairs(b.chips) do
      if type(c) == "string" and c:match("^[A-Z][A-Z0-9]+%-%d+$") then
        key = c
        break
      end
    end
  end
  if key then
    request("open", { token = key })
  else
    noctalia.notify("Slate", "No Jira key on this block")
  end
end

local function doneAt(i)
  local b = rowData[i]
  if not b then
    return
  end
  request("done", { token = b.id })
end

function onOpen1() openAt(1) end   function onOpen2() openAt(2) end   function onOpen3() openAt(3) end
function onOpen4() openAt(4) end   function onOpen5() openAt(5) end   function onOpen6() openAt(6) end
function onOpen7() openAt(7) end   function onOpen8() openAt(8) end   function onOpen9() openAt(9) end
function onOpen10() openAt(10) end function onOpen11() openAt(11) end function onOpen12() openAt(12) end
function onOpen13() openAt(13) end function onOpen14() openAt(14) end function onOpen15() openAt(15) end
function onOpen16() openAt(16) end

function onDone1() doneAt(1) end   function onDone2() doneAt(2) end   function onDone3() doneAt(3) end
function onDone4() doneAt(4) end   function onDone5() doneAt(5) end   function onDone6() doneAt(6) end
function onDone7() doneAt(7) end   function onDone8() doneAt(8) end   function onDone9() doneAt(9) end
function onDone10() doneAt(10) end function onDone11() doneAt(11) end function onDone12() doneAt(12) end
function onDone13() doneAt(13) end function onDone14() doneAt(14) end function onDone15() doneAt(15) end
function onDone16() doneAt(16) end

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
