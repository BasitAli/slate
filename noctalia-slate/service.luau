--!nonstrict
-- Headless [[service]]: clipboard offer + slate ls --json refresh.
-- Jira / PR/MR / Slack permalink → Open session (primary) or Park only.

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

local function matchClip(text: string)
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

local function doOpen(token: string)
  runSlate("open " .. shQuote(token), "Opening session")
end

local function doPark(token: string)
  runSlate("park " .. shQuote(token), "Parked")
end

local function offer(kind: string, token: string, label: string)
  if offering then
    return
  end
  offering = true
  lastOffered = token
  noctalia.state.set("offer", { kind = kind, token = token, label = label })

  local cmd = "notify-send -a slate -t 20000"
    .. " -A open='Open session'"
    .. " -A park='Park only'"
    .. " -A dismiss=Dismiss 'Slate' "
    .. shQuote(label)

  noctalia.runAsync(cmd, function(r)
    offering = false
    local act = noctalia.string.trim(r.stdout or "")
    if act == "open" then
      doOpen(token)
    elseif act == "park" then
      doPark(token)
    end
    noctalia.state.set("offer", nil)
  end, 25000)
end

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
  if action == "open" and type(token) == "string" then
    doOpen(token)
    noctalia.state.set("offer", nil)
  elseif (action == "park" or action == "add") and type(token) == "string" then
    doPark(token)
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
  if type(text) ~= "string" or text == lastClip then
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

refreshBlocks()
noctalia.setUpdateInterval(1000)
