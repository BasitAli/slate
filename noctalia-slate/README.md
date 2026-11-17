# noctalia-slate

## Plugin

Native Noctalia v5 plugin for [slate](https://github.com/BasitAli/slate).

- **Bar widget** `basitali/noctalia-slate:widget` — **My Slate** + open-block count
- **Panel** `basitali/noctalia-slate:panel` — block cards (next/notes/chips), Add/Open/Done
- **Service** — refreshes via `slate ls --json`

Requires `slate` on `PATH`.

## Usage

```sh
# local iterate (preferred while hacking)
noctalia msg plugins source add slate path /work/Developer/personal/slate
# or after push:
# noctalia msg plugins source add slate git https://github.com/BasitAli/slate

noctalia msg plugins enable basitali/noctalia-slate
```

Add bar widget type `basitali/noctalia-slate:widget` (Settings → Bar, or `[widget.slate]` in settings.toml).

IPC: `noctalia msg panel-toggle basitali/noctalia-slate:panel`

Launcher: type **`/slate`** — New todo, Open My Slate, pick an open block (Enter opens session).
`/slate Buy milk` offers creating that titled card.
Paste a Jira / PR / Slack link (or `KEY`) after `/slate ` → **Open session** / **Park only**.
No automatic clipboard watch — you open the launcher and paste.
