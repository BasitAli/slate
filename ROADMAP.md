# Roadmap

Detail: [docs/plans/slate.md](docs/plans/slate.md). Journeys: [docs/journeys.md](docs/journeys.md).

| Phase | Status | What |
|-------|--------|------|
| **1 — Core** | done | CLI + block graph + profiles + Claude skill + `open`/`review`/`capture` |
| **2 — UI** | done | `noctalia-slate` cards + `/slate` launcher; polish later |
| **3 — Voice** | done (v1) | Wisp macros (list/open/capture/review/todo → type into kitty) |
| Later | deferred | Switchboard/acli ingest, Cursor skill, Multica, richer statuses |

## Done when (Phase 1)

- [x] Repo + docs + plan checked in
- [x] CLI: capture / review / start / link / done-block
- [x] Skill checked in (`skill/slate`)
- [x] Skill installed for Claude on this machine
- [x] nixos-config installs `slate` on PATH

## Done when (Phase 2)

- [x] Bar widget + panel of open blocks
- [x] `/slate` launcher (todos + Jira/PR/Slack paste → open/park)
- [ ] Thumbnail / registry polish
- [ ] Detail view richer than Open/Done

## Done when (Phase 3 v1)

- [x] Wisp sample macros + machine `commands.toml` phrases
