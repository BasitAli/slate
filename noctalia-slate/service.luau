--!nonstrict
-- Headless [[service]]: clipboard offer + slate ls --json refresh.
-- Widget/panel only read shared state ("blocks", "offer").

local lastClip = ""
local lastOffered = ""
local offering = false
local lastBlocksAt = 0

local function cfg(key)
  return noctalia.getConfig(key)
end

local function shQuote(s: string): string
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function nowMs(): number
  if type(noctalia.nowMs) == "function" then
    return noctalia.nowMs()
  end
  return (tonumber(noctalia.formatTime("%s")) or 0) * 1000
end

-- Returns kind ("jira"|"review"), token (key or url), label — or nil.
local function matchClip(text: string)
  if type(text) ~= "string" then
    return nil
  end
  text = noctalia.string.trim(text)
  if text == "" or #text > 2000 then
    return nil
  end
  -- single-line only (avoid huge pastes)
  if text:find("\n") then
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
    if text:find("/pull/%d+") or text:find("/merge_requests/%d+") or text:find("/-/merge_requests/%d+") then
      local short = text
      if #short > 80 then
        short = short:sub(1, 77) .. "…"
      end
      return "review", text, short
    end
  end
  return nil
end

local function refreshBlocks()
  noctalia.runAsync("slate ls --json", function(r)
    if r.exitCode ~= 0 then
      noctalia.log("slate ls --json failed: " .. tostring(r.stderr))
      return
    end
    local data, err = noctalia.json.decode(r.stdout or "")
    if type(data) ~= "table" then
      noctalia.log("slate ls --json decode: " .. tostring(err))
      return
    end
    noctalia.state.set("blocks", { items = data, at = nowMs() })
  end, 8000)
end

local function runSlate(args: string, okMsg: string)
  noctalia.runAsync("slate " .. args, function(r)
    if r.exitCode == 0 then
      noctalia.notify("Slate", okMsg)
      refreshBlocks()
    else
      noctalia.notifyError("Slate", noctalia.string.trim(r.stderr or "failed"))
    end
  end, 15000)
end

local function doAdd(kind: string, token: string)
  if kind == "jira" then
    runSlate("capture " .. shQuote(token), "Captured " .. token)
  else
    runSlate("review " .. shQuote(token), "Review parked")
  end
end

local function doOpen(token: string)
  runSlate("open " .. shQuote(token), "Opening " .. token)
end

local function offer(kind: string, token: string, label: string)
  if offering then
    return
  end
  offering = true
  lastOffered = token
  noctalia.state.set("offer", { kind = kind, token = token, label = label })

  local openAct = ""
  if kind == "jira" then
    openAct = " -A open='Open session'"
  end
  local cmd = "notify-send -a slate -t 20000 -A add='Add to slate'"
    .. openAct
    .. " -A dismiss=Dismiss 'Add to slate' "
    .. shQuote(label)

  noctalia.runAsync(cmd, function(r)
    offering = false
    local act = noctalia.string.trim(r.stdout or "")
    if act == "add" then
      doAdd(kind, token)
    elseif act == "open" and kind == "jira" then
      doOpen(token)
    end
    noctalia.state.set("offer", nil)
  end, 25000)
end

-- Panel writes requests here (seq bumps).
local lastReqSeq = 0

local function handleRequests()
  local req = noctalia.state.get("request")
  if type(req) ~= "table" then
    return
  end
  local seq = tonumber(req.seq) or 0
  if seq <= lastReqSeq then
    return
  end
  lastReqSeq = seq
  local action = req.action
  local token = req.token
  local kind = req.kind
  if action == "add" and type(token) == "string" and type(kind) == "string" then
    doAdd(kind, token)
    noctalia.state.set("offer", nil)
  elseif action == "open" and type(token) == "string" then
    doOpen(token)
    noctalia.state.set("offer", nil)
  elseif action == "dismiss_offer" then
    noctalia.state.set("offer", nil)
  elseif action == "done" and type(token) == "string" then
    runSlate("done-block " .. shQuote(token), "Done " .. token)
  elseif action == "refresh" then
    refreshBlocks()
  end
end

function update()
  handleRequests()

  local poll = tonumber(cfg("poll_ms")) or 1000
  noctalia.setUpdateInterval(math.max(250, math.min(poll, 10000)))

  local refreshEvery = tonumber(cfg("blocks_refresh_ms")) or 5000
  local t = nowMs()
  if t - lastBlocksAt >= refreshEvery then
    lastBlocksAt = t
    refreshBlocks()
  end

  if cfg("clipboard_offer") == false then
    return
  end

  local text = noctalia.clipboardText()
  if type(text) ~= "string" then
    return
  end
  if text == lastClip then
    return
  end
  lastClip = text

  local kind, token, label = matchClip(text)
  if not kind or offering then
    return
  end
  offer(kind, token, label)
end

function onIpc(cmd: string)
  if cmd == "refresh" then
    refreshBlocks()
  end
end

-- First paint
refreshBlocks()
noctalia.setUpdateInterval(1000)
