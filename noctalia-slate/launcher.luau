--!nonstrict
-- Launcher provider: type `/slate` (prefix from plugin.toml).
--   /slate           → New todo, Open panel, open blocks
--   /slate Buy milk  → create titled block (and fuzzy-filter list)

local PANEL = "basitali/noctalia-slate:panel"

local function shQuote(s: string): string
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function blocks(): { any }
  local b = noctalia.state.get("blocks")
  if type(b) == "table" and type(b.items) == "table" then
    return b.items
  end
  return {}
end

local function blockRows(filter: string): { any }
  local rows = {}
  local f = filter:lower()
  for _, item in ipairs(blocks()) do
    local title = tostring(item.title or item.id or "")
    local chips = ""
    if type(item.chips) == "table" then
      chips = table.concat(item.chips, " ")
    end
    local hay = (title .. " " .. chips .. " " .. tostring(item.next or "")):lower()
    local score = 1
    local include = true
    if f ~= "" then
      local s = noctalia.fuzzyScore(f, hay)
      if s == nil then
        include = false
      else
        score = s
      end
    end
    if include then
      local openTok = item.open
      local id
      if type(openTok) == "string" and openTok ~= "" then
        id = "open:" .. openTok
      else
        id = "show:" .. tostring(item.id)
      end
      table.insert(rows, {
        id = id,
        title = title,
        subtitle = (chips ~= "" and chips or tostring(item.profile or ""))
          .. ((item.next and item.next ~= "") and (" · " .. item.next) or ""),
        glyph = "clipboard-list",
        score = score,
      })
    end
  end
  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text == "" then
    table.insert(rows, {
      id = "action:new",
      title = "New todo",
      subtitle = "Create an untitled block card",
      glyph = "plus",
      score = 1000,
    })
    table.insert(rows, {
      id = "action:panel",
      title = "Open My Slate",
      subtitle = "Panel of open blocks",
      glyph = "layout-list",
      score = 999,
    })
  else
    table.insert(rows, {
      id = "action:new:" .. text,
      title = "New todo: " .. text,
      subtitle = "slate block start …",
      glyph = "plus",
      score = 1000,
    })
    table.insert(rows, {
      id = "action:panel",
      title = "Open My Slate",
      subtitle = "Panel of open blocks",
      glyph = "layout-list",
      score = 900,
    })
  end

  for _, r in ipairs(blockRows(text)) do
    table.insert(rows, r)
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  if id == "action:new" then
    noctalia.runAsync("slate block start", function(r)
      if r.exitCode == 0 then
        noctalia.notify("My Slate", "Untitled card " .. noctalia.string.trim(r.stdout or ""))
        noctalia.runAsync("noctalia msg plugin basitali/noctalia-slate:service all refresh", function() end)
      else
        noctalia.notifyError("My Slate", noctalia.string.trim(r.stderr or "failed"))
      end
    end, 8000)
    return
  end

  local titled = id:match("^action:new:(.+)$")
  if titled then
    noctalia.runAsync("slate block start " .. shQuote(titled), function(r)
      if r.exitCode == 0 then
        noctalia.notify("My Slate", "Created " .. titled)
        noctalia.runAsync("noctalia msg plugin basitali/noctalia-slate:service all refresh", function() end)
      else
        noctalia.notifyError("My Slate", noctalia.string.trim(r.stderr or "failed"))
      end
    end, 8000)
    return
  end

  if id == "action:panel" then
    noctalia.togglePanel(PANEL)
    return
  end

  local openTok = id:match("^open:(.+)$")
  if openTok then
    noctalia.runAsync("slate open " .. shQuote(openTok), function(r)
      if r.exitCode ~= 0 then
        noctalia.notifyError("My Slate", noctalia.string.trim(r.stderr or "open failed"))
      end
    end, 15000)
    return
  end

  local showId = id:match("^show:(.+)$")
  if showId then
    noctalia.togglePanel(PANEL)
  end
end
