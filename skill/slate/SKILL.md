---
name: slate
description: >
  Track work on the user's slate ledger (block cards linked to Jira, agent sessions, PRs).
  Use when starting work on a Jira id, pasting a PR/MR review URL, updating next steps/notes,
  or finishing a block of work. Runs the `slate` CLI.
---

# slate skill

`slate` is on PATH. Profiles: `ithaka` (under `/work/Developer/Ithaka`) vs `personal`.
Cards are **blocks**; children (jira, sessions, PRs) link to the block.

## Implement — user says they’re working on a Jira

1. Resolve root: path they named, else omit `--root` (CLI uses profile config / `$PWD`).
2. ```bash
   SID=$(slate start "short title · KEY" --jira KEY [--root DIR])
   ```
   (`--jira` ensures block + jira child and links the session.)
3. Print/remember the session id (stdout) and block id (stderr `block=`).
4. Progress: `slate note <block-id> "…"`, `slate next <block-id> "…"`.
5. Finish the effort: `slate done-block <block-id>` or `slate done-block jira:KEY`.
   Session-only: `slate done <session-id>` (does not close the whole card).

Do **not** use kitty focus or `CLAUDE_CODE_SESSION_ID` to invent links.

## Review — user pastes a PR/MR URL

1. Fetch PR metadata (`gh` / `glab` / page): title, body, branch.
2. Extract Jira keys with `[A-Z][A-Z0-9]+-\d+` (title → body → branch).
3. ```bash
   BID=$(slate review 'https://…' [--jira KEY])
   ```
4. For each extra key not passed as `--jira`:
   ```bash
   J=$(slate add jira KEY)
   slate link "$BID" "$J"
   ```
5. If no key found: leave a note `slate note "$BID" "no jira key in PR"`.
6. Only `slate start … --block "$BID"` if they want agent help on the review.

## Linking more artifacts

`slate add slack|pagerduty REF` then `slate link <block> <id>`.
