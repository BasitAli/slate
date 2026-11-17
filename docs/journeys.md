# User journeys

## A — Claude already open (implement)

You say “Start working on PROJ-456…”. Skill: ensure **block**, `start` session (root), `add jira`, link both to block; `note`/`next` as you go; `done-block` when the effort is done.

## B — `slate open jira:KEY`

CLI opens kitty at profile root, runs `claude` with seed “Start working on KEY.” Skill does A.

## C — Morning review

`slate ls` / noctalia-slate: open **blocks** as cards; expand for children.

## D — Stub only

`slate add jira KEY` without a block — orphan until linked.

## E — Code review

Paste PR URL → `slate review <url>` or tell Claude (skill reads PR, extracts Jira, links). `done-block` when review submitted.

## F — Clipboard → Add to slate

noctalia-slate (Phase 2): copy PR/Jira → notification **Add to slate** → `review` / `capture`. No auto-add without click.
