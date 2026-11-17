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
root = "/work/Developer/Ithaka"
```

Root resolution: `--root` → profile `root` → `$PWD`.

## Blocks (cards)

```fish
slate ls                   # open blocks
slate ls --all             # + recent done
slate show <id>
slate next <block> "…"
slate note <block> "…"
slate done-block <id|jira:KEY>
```

## Implement

```fish
slate open jira:PROJ-456           # kitty + claude seed (root from profile)
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

```fish
slate capture PROJ-456
slate capture https://…/browse/PROJ-456
```
