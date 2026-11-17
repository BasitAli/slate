# slate

Personal work ledger: **block cards** (status, next steps, notes) with linked children —
Jira, agent sessions, PRs, Slack, and more. CLI + [noctalia-slate](noctalia-slate/) panel /
clipboard offer; Wisp macros optional. See [ROADMAP.md](ROADMAP.md).

## Quick start

```fish
# after install (nixos-config wires PATH), or:
set -x PATH /work/Developer/personal/slate/cli $PATH

mkdir -p ~/.config/slate
cp examples/ithaka.toml ~/.config/slate/ithaka.toml   # edit root=

slate profile          # ithaka | personal (from cwd / pin)
slate capture PROJ-456
slate review https://gitlab.com/org/repo/-/merge_requests/1
slate ls
slate show <id>
```

Agents: install [skill/slate](skill/slate/SKILL.md) so Claude runs `slate start` / `link` when you
say you’re working on a Jira or paste a PR URL.

## Layout

```
README.md CHANGELOG.md ROADMAP.md
docs/plans/          # design plans (canonical)
docs/usage.md        # day-to-day commands
docs/journeys.md     # user journeys A–F
cli/slate            # CLI (Python 3, stdlib)
skill/slate/         # Claude Code skill
noctalia-slate/      # Noctalia plugin (Phase 2)
examples/            # profile + Wisp samples
catalog.toml         # Noctalia plugin source index
```

## Data (on the machine, not in git)

| Path | Role |
|------|------|
| `~/.local/share/slate/{profile}/nodes.jsonl` | nodes |
| `~/.local/share/slate/{profile}/edges.jsonl` | edges |
| `~/.config/slate/{profile}.toml` | e.g. `root = "…"` |
| `~/.config/slate/state.json` | pinned profile |

## License

MIT © 2026 Basit Ali
