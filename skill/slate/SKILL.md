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
2. From **this** conversation’s Bash (so `CLAUDE_CODE_SESSION_ID` is set), run:
   ```bash
   SID=$(slate start "short title · KEY" --jira KEY [--root DIR] \
     --claude-session "$CLAUDE_CODE_SESSION_ID")
   ```
   (`--jira` ensures block + jira child and links the session. `--claude-session` stores
   this chat’s UUID on the `agent_session` as `refs.claude_session` so later `slate open`
   can `claude --resume` the same conversation. If the env var is already set, `slate start`
   records it even without the flag — still pass the flag when you can.)
3. Print/remember the slate session id (stdout) and block id (stderr `block=`). Confirm with
   `slate show "$SID"` that `refs.claude_session` is present; if missing, re-run start with
   the flag or set it via `slate start` only after the env is visible in Bash.
4. Progress: `slate note <block-id> "…"`, `slate next <block-id> "…"`.
5. Finish the effort: `slate done-block <block-id>` or `slate done-block jira:KEY`.
   Session-only: `slate done <session-id>` (does not close the whole card).

**Linking the Claude conversation id is the agent’s job** (this skill). The slate CLI must
not invent links from kitty focus or by guessing env outside an explicit `slate start`.

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
