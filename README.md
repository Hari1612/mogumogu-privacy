# mogumogu-privacy

Public legal & support pages for **MoguMogu** (by Sapporosoft), served via GitHub Pages
at <https://hari1612.github.io/mogumogu-privacy/>.

## 🛑 Ship gate — do not self-authorize

Pushing to this repo is gated by the `pre-push` hook (fail-closed: no valid grant
⇒ push denied). **Only hari writes** `.git/SHIP_AUTH` / `.git/SHIP_AUTH_BRANCH`;
workers/agents must never write them (self-authorization defeats the gate).
`main` is per-SHA only; branch grants never authorize `main`; `--no-verify` is
forbidden. Full usage: [`docs/SHIP_AUTH-USAGE.md`](./docs/SHIP_AUTH-USAGE.md).
Install/refresh the hook: `bash tools/install-ship-auth-hook.sh`.

## Canonical pages

| Page | Path | URL |
|---|---|---|
| Privacy Policy (EN) | `index.html` | `/` |
| Terms of Service (EN) | `terms/index.html` | `/terms/` |
| Support (EN) | `support/index.html` | `/support/` |
| Privacy Policy (JA) | `ja/index.html` | `/ja/` |
| Terms of Service (JA) | `ja/terms/index.html` | `/ja/terms/` |
| Support (JA) | `ja/support/index.html` | `/ja/support/` |

English is the canonical version; on any conflict, the EN page controls. Each JA page
states this at the top and links to its EN counterpart.

## Other files

- `delete-account.html` — account-deletion instructions (linked from Google Play / the app).
- `support.html` — legacy path, now redirects to `/support/`.
- `docs/index.html` — legacy path, now redirects to `/` (canonical Privacy Policy).

Pages are self-contained static HTML (no Jekyll layout/theme dependency), so they render
identically regardless of the Pages build environment.
