--!nonstrict
-- Launcher provider: type `/slate` (prefix from plugin.toml).
--   /slate              → New todo, Open panel, open blocks
--   /slate Buy milk     → create titled block (and fuzzy-filter list)
--   /slate <jira|pr|slack url or KEY> → Open session / Park only

local PANEL = "basitali/noctalia-slate:panel"

local function shQuote(s: string): string
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function refresh()
  local seq = tonumber(noctalia.formatTime("%s")) or 0
  noctalia.state.set("request", { seq = seq, action = "refresh" })
end

-- Same shapes as service clipboard match: kind, token, label — or nil.
local function matchLink(text: string)
  if type(text) ~= "string" then
    return nil
  end
  text = noctalia.string.trim(text)
  if text == "" or #text > 2000 or text:find("\n") then
    return nil
  end

  local browse = text:match("/browse/([A-Za-z][A-Za-z0-9]+%-%d+)")
  if browse then
    return "jira", browse:upper(), browse:upper()
  end

  local key = text:match("^([A-Za-z][A-Za-z0-9]+%-%d+)$")
  if key then
    return "jira", key:upper(), key:upper()
  end

  if text:match("^https?://") then
    if text:find("slack%.com/") and (text:find("/archives/") or text:find("/client/")) then
      local short = (#text > 80) and (text:sub(1, 77) .. "…") or text
      return "slack", text, short
    end
    if text:find("/pull/%d+") or text:find("/merge_requests/%d+") or text:find("/-/merge_requests/%d+") then
      local short = (#text > 80) and (text:sub(1, 77) .. "…") or text
      return "review", text, short
    end
  end
  return nil
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

  local kind, token, label = matchLink(text)
  if kind then
    table.insert(rows, {
      id = "link:open:" .. token,
      title = "Open session",
      subtitle = label,
      glyph = "player-play",
      score = 1000,
    })
    table.insert(rows, {
      id = "link:park:" .. token,
      title = "Park only",
      subtitle = label,
      glyph = "bookmark",
      score = 999,
    })
    table.insert(rows, {
      id = "action:panel",
      title = "Open My Slate",
      subtitle = "Panel of open blocks",
      glyph = "layout-list",
      score = 900,
    })
    launcher.setResults(query, rows)
    return
  end

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
  local linkOpen = id:match("^link:open:(.+)$")
  if linkOpen then
    noctalia.runAsync("slate open " .. shQuote(linkOpen), function(r)
      if r.exitCode == 0 then
        refresh()
      else
        noctalia.notifyError("My Slate", noctalia.string.trim(r.stderr or "open failed"))
      end
    end, 15000)
    return
  end

  local linkPark = id:match("^link:park:(.+)$")
  if linkPark then
    noctalia.runAsync("slate park " .. shQuote(linkPark), function(r)
      if r.exitCode == 0 then
        noctalia.notify("My Slate", "Parked")
        refresh()
      else
        noctalia.notifyError("My Slate", noctalia.string.trim(r.stderr or "park failed"))
      end
    end, 8000)
    return
  end

  if id == "action:new" then
    noctalia.runAsync("slate block start", function(r)
      if r.exitCode == 0 then
        noctalia.notify("My Slate", "Untitled card " .. noctalia.string.trim(r.stdout or ""))
        refresh()
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
        refresh()
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
