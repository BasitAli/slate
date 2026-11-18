# Changelog

## 0.2.14 — 2026-11-18

### Added

- `slate prune [block]` — one open `agent_session` per block; also runs on open/start/focus

## 0.2.13 — 2026-11-18

### Changed

- Store `agent_session.kitty_pid` on launch; Open focuses that first (covers `/slate` seed chats without `--resume` on cmdline). UUID discover remains fallback. `slate start` updates the existing open session instead of always adding another.

## 0.2.12 — 2026-11-18

### Added

- Open focuses an existing Hyprland kitty already running that `claude_session` (else `--resume`)

## 0.2.11 — 2026-11-18

### Added

- `slate start --claude-session` / `$CLAUDE_CODE_SESSION_ID` → `refs.claude_session`; Open uses `claude --resume <uuid>`
- Skill: agent must record conversation id (CLI still must not invent kitty/env links)

## 0.2.10 — 2026-11-18

### Fixed

- Panel Open watches `request` immediately (was polling, looked dead)
- Card Open uses block id + continue / `claude --continue` (was re-running park+“Start working on”)

## 0.2.9 — 2026-11-18

### Fixed

- `slate open` launches via `fish -lc` so PATH tracks login fish (no hardcoded bin dirs)

## 0.2.8 — 2026-11-18

### Fixed

- `slate open` prepends `~/.local/bin` + `~/.npm-global/bin` so Noctalia-launched sessions find switchboard/twg

## 0.2.7 — 2026-11-18

### Changed

- Bar label **My Slate (N)**; panel cards use kitty dark palette fills

## 0.2.6 — 2026-11-18

### Fixed

- **`slate open` from launcher/home** uses `slate profile default` (set to `ithaka`) instead of
  personal/`$HOME`
- Kitty windows from `slate open` get the same random dark bg/tab tint as interactive fish
  (claude is launched directly, so `kitty-window-bg.fish` never ran)

### Added

- `slate profile default ithaka|personal` — fallback when cwd is not under Ithaka

## 0.2.5 — 2026-11-18

### Changed

- No auto clipboard watch — paste into **`/slate`** yourself

## 0.2.4 — 2026-11-18

### Changed

- Clipboard offer opened the **`/slate` launcher** instead of notify-send (reverted in 0.2.5)

## 0.2.3 — 2026-11-18

### Added

- Launcher provider **`/slate`**: new todo, open panel, jump to open blocks;
  paste Jira/PR/Slack (or KEY) → Open session / Park only

## 0.2.2 — 2026-11-18

### Changed

- Bar pill shows **My Slate** label; sits at bar `start` (top of the right bar)
- noctalia-slate panel cards match sticky-notes style (filled `surface_container`,
  radius 8, separator, outline sm actions)

## 0.2.1 — 2026-11-17

### Changed

- Clipboard / `slate open`: **Jira, PR/MR, and Slack** all open a Claude session (primary);
  **Park only** via `slate park` or the notify action
- Slack permalinks recognized (`*.slack.com/archives/…`)

## 0.2.0 — 2026-11-17

### Added

- **noctalia-slate** bar widget + panel (block cards) + service
- Clipboard watch → `notify-send` **Add to slate** / **Open session** (opt-out `clipboard_offer`)
- `slate ls --json` for the panel

### Changed

- Phase 2 UI marked in progress on ROADMAP

## 0.1.0 — 2026-11-17

### Added

- Repo skeleton: README, ROADMAP, docs (plans/journeys/usage), examples
- Phase 1 **CLI** (`cli/slate`): profiles, block cards, start/add/link/note/next/done/done-block,
  review (URL), capture (jira), open (kitty + claude seed), show/ls
- Claude **skill** (`skill/slate`) for implement + review journeys
- **noctalia-slate** stub + `catalog.toml`
- **CLI:** `ls`/`show` search both profiles (cwd no longer hides ithaka); `open` accepts browse URLs;
  capture help clarifies no session
- **Wisp** sample macros (`examples/wisp-slate-commands.toml`) — launch kitty + type `slate …`
  (no Wisp `exec` action)
