# Changelog

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
