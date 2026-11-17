# Usage

## Profiles

Auto: `$PWD` under `/work/Developer/Ithaka` → `ithaka`, else `personal`.

```fish
slate profile              # show
slate profile ithaka       # pin
slate profile auto         # follow cwd again
```

Config: `~/.config/slate/<profile>.toml`

```toml
root = "/work/Developer/Ithaka/projects"
```

Root resolution: `--root` → profile `root` → `$PWD`.

## Blocks (cards)

```fish
slate ls                   # open blocks (ithaka + personal)
slate ls --profile ithaka  # one profile
slate ls --all             # + recent done
slate show <id|KEY>        # block/jira/session + neighbors
slate next <block> "…"
slate note <block> "…"
slate done-block <id|jira:KEY>
```

## Implement

```fish
slate open PROJ-456                                      # kitty + claude
slate open https://…/browse/PROJ-456
slate open https://github.com/…/pull/1                   # review session
slate open 'https://….slack.com/archives/…/p…'         # slack session
slate park <same targets>                                # block only, no session
# or in an existing Claude session — skill runs:
slate start "flaky auth · PROJ-456"
slate add jira PROJ-456
slate link <session> <block>       # skill links session + jira → block
```

## Review

```fish
slate review https://gitlab.com/…/merge_requests/123
slate review 'https://github.com/…/pull/456' --jira PROJ-789
```

Prefer pasting the URL to Claude so the skill can read the PR and link Jira keys.

## Capture (clipboard / no agent)

Parks a block only — does **not** launch Claude. For a session, use `open` with the same token.

```fish
slate capture PROJ-456
slate capture https://…/browse/PROJ-456
slate open https://…/browse/PROJ-456   # kitty + claude (reuses block if already captured)
```

## Wisp

Merge `examples/wisp-slate-commands.toml` into `~/.config/wisp/commands.toml`, restart `wispd`.
Phrases: *slate list* / *what's on my slate*, *slate open*, *slate capture*, *slate review*.
Each opens kitty and types the CLI (Wisp has no shell-exec). After *open* / *capture* / *review*,
finish the KEY or URL yourself.

## Noctalia panel

```sh
noctalia msg plugins source add slate path /work/Developer/personal/slate
noctalia msg plugins enable basitali/noctalia-slate
# bar: widget type basitali/noctalia-slate:widget (already in flake noctalia-settings.toml)
noctalia msg panel-toggle basitali/noctalia-slate:panel
```

Copy a Jira URL / `KEY` / PR URL → notification **Add to slate** (or use the panel banner).
`slate ls --json` feeds the cards.
