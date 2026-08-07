# SHIP_AUTH — ship-gate usage

The `pre-push` hook is the **only** enforcement layer for what may land on this
repo (platform branch protection is not available on the free/private plan). It
fails **closed**: with no valid grant, every push is denied.

Canonical hook source: [`tools/ship-auth-pre-push`](../tools/ship-auth-pre-push).
Install / re-install with `bash tools/install-ship-auth-hook.sh` (it copies the
source into `<git-common-dir>/hooks/pre-push`; the hook itself is not tracked
because `.git/` lives outside the repo tree).

Both grant files live in the **git-common dir** (`.git/` of the main clone),
so a single grant covers the main working tree and every worktree.

---

## Two grant modes

### 1. `SHIP_AUTH` — per-SHA (strict; the only way to push `main`)

A single 40-char SHA. If it equals the SHA being pushed, the push is allowed —
for **any** branch, including `main`.

```bash
# hari authorizes exactly one SHA -> one push
printf '%s' 9e82dd9cb69805778664d13ce8225ca113e6f807 > "$(git rev-parse --git-common-dir)/SHIP_AUTH"
```

One token = one SHA = one push. A mismatch blocks. After a successful push the
worker deletes the token. If `origin/main` moves between authorization and push,
the authorized SHA can never land (rebase/merge mint a new SHA); remove the dead
token, rebase, and **re-ask** — see the REBASE-OK grant convention.

### 2. `SHIP_AUTH_BRANCH` — windowed branch pre-grant (feature branches only)

One line: `<glob-pattern> <duration>`. It authorizes pushes to **feature**
branches whose name matches the glob, for `<duration>` measured from the file's
mtime. It **never** authorizes `main`.

```bash
# hari pre-grants once per session; workers push matching branches freely until it expires
printf 'feature/retention-* 2h\n' > "$(git rev-parse --git-common-dir)/SHIP_AUTH_BRANCH"
```

- `<glob-pattern>` — shell glob against the **target** branch name, e.g.
  `feature/retention-*`, `feature/*`, `hotfix/*`.
- `<duration>` — `30m`, `2h`, `4h`. **Hard cap: 8h** (longer is rejected).
- The window is `now - mtime(file) < duration`. Re-`touch` (or rewrite) the file
  to extend it.
- When the window lapses the hook **deletes** the file — no dead grants linger.

---

## Why `main` is still per-SHA (never a branch grant)

`main` is production's source of truth. A branch pre-grant is a *broad*,
time-boxed convenience for the noisy part of the workflow (pushing hotfix /
feature commits for backup, sharing, or PRs). Landing on `main` is the one
irreversible, high-blast-radius act, so it keeps the narrowest possible
authorization: one human-typed SHA, one push. The hook enforces this
structurally — the branch-grant path is skipped entirely when the target ref is
`refs/heads/main`.

## Security envelope

- **Fail-closed.** No matching `SHIP_AUTH` and no matching `SHIP_AUTH_BRANCH`
  ⇒ deny. (This is stricter than the previous hook, which gated only `main`.)
- **`main` ⇒ per-SHA only.** Branch grants can never authorize `main`.
- **8h cap** on any branch grant. No all-day pre-grants.
- **Only hari writes grant files.** Workers/agents writing `SHIP_AUTH*`
  themselves is self-authorization and defeats the gate. This is a policy control
  (also stated in the repo-root `README.md` and in the hook header) — the hook
  cannot tell who wrote the file, so the discipline is on us.
- **`--no-verify` is forbidden.** It bypasses the hook entirely.

## Audit log

Every decision that turns on a grant is appended to
`<git-common-dir>/SHIP_AUTH_AUDIT.log` (tab-separated, grep-able):

```
<UTC-timestamp>  <event>  <sha>  <branch>  <user name <email>>  <detail>
```

Events: `ALLOW-SHA`, `ALLOW-BRANCH`, `EXPIRE-DELETE`, `REJECT-CAP`. To trace a
push:

```bash
grep ALLOW-BRANCH "$(git rev-parse --git-common-dir)/SHIP_AUTH_AUDIT.log"
```

## Tests

`bash tools/test-ship-auth.sh` drives the hook hermetically (throwaway repo, no
network) and asserts: matching SHA → allow; matching branch in window → allow;
branch grant to `main` → deny; out-of-window grant → deny + file deleted; no
grant → deny; over-cap grant → deny; matching SHA to `main` → allow.
