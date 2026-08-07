# Worker deploy allowlist

`.claude/settings.local.json` (git-ignored, machine-local) pre-approves a
**narrow** set of deploy commands so a dispatched worker can run them without a
permission prompt. Everything else still prompts.

## What workers can now run autonomously

| Pattern | Purpose |
|---|---|
| `Bash(ssh laravel-api-server *)` | Run deploy / restart / cache commands on the Sakura app host |
| `Bash(scp * laravel-api-server:*)` | Upload files (bind-mount deploy assets) to the Sakura app host |
| `Bash(curl.exe -sf https://api.sapporosoft.com/*)` | Post-deploy smoke GET against prod API |
| `Bash(curl.exe -s -X POST -H * -d * -o NUL -w * https://api.sapporosoft.com/api/v1/telemetry/*)` | Telemetry endpoint smoke POST |

Host is pinned to the `laravel-api-server` SSH alias and the API host to
`api.sapporosoft.com` — the patterns do **not** match any other host.

## What still requires hari (by design)

- **`git push` / landing on `main`.** Not a permission-classifier concern — it is
  gated by the `pre-push` hook (`SHIP_AUTH` / `SHIP_AUTH_BRANCH`). See
  [SHIP_AUTH-USAGE.md](./SHIP_AUTH-USAGE.md). `git push` is deliberately **not**
  in this allowlist.
- **`ssh` / `scp` to any other host.** Only `laravel-api-server` is allowed.
- **Writing `.git/SHIP_AUTH*`.** No `Set-Content` / write rule for the grant
  files — self-authorization is forbidden.
- **Prod deploy sequencing.** The allowlist removes the *prompt*, not the
  judgement: follow the deploy runbook (restart first, `config:cache` last) and
  wait for Dispatch ACK before touching prod.

## Scope note

`.claude/` is git-ignored in this repo, so `settings.local.json` is per-machine
and is **not** committed. Re-apply these entries on any new worker machine.
