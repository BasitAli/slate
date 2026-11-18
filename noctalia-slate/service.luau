--!nonstrict
-- Headless [[service]]: refreshes slate ls --json for panel/widget.
-- Clipboard → launcher is manual: open launcher, type /slate, paste.

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

local lastReqSeq = 0

local function handleRequest(req: any)
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
  local refreshEvery = tonumber(cfg("blocks_refresh_ms")) or 5000
  noctalia.setUpdateInterval(math.max(1000, math.min(refreshEvery, 60000)))

  local t = nowMs()
  if t - lastBlocksAt >= refreshEvery then
    lastBlocksAt = t
    refreshBlocks()
  end
end

function onIpc(cmd: string)
  if cmd == "refresh" then
    refreshBlocks()
  end
end

noctalia.state.watch("request", handleRequest)
refreshBlocks()
noctalia.setUpdateInterval(1000)
