#!/usr/bin/env bash
# ============================================================================
# Hermetic test harness for the ship-gate pre-push hook.
#
#   Usage:  bash tools/test-ship-auth.sh
#
# Builds a throwaway git repo, drives the hook (tools/ship-auth-pre-push) by
# feeding it pre-push stdin lines and controlled SHIP_AUTH / SHIP_AUTH_BRANCH
# tokens, and asserts the exit code + side effects. No network, no real push.
#
# Cases:
#   (a) matching SHA               -> ALLOW  (exit 0)
#   (b) matching branch, in window -> ALLOW  (exit 0)
#   (c) branch grant aimed at main -> DENY   (exit 1)   [main is per-SHA only]
#   (d) branch grant out of window -> DENY   (exit 1) + grant file DELETED
#   (e) no grant                   -> DENY   (exit 1)
#   (f) over-8h-cap branch grant   -> DENY   (exit 1)   [duration cap]
#   (g) matching SHA to main       -> ALLOW  (exit 0)   [per-SHA works on main]
# ============================================================================
set -uo pipefail

HOOK_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/tools/ship-auth-pre-push"
[ -f "$HOOK_SRC" ] || { echo "ERROR: hook not found: $HOOK_SRC" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

REPO="$TMP/repo"
git init -q "$REPO"
git -C "$REPO" config user.name  "test-runner"
git -C "$REPO" config user.email "test@example.com"
COMMON="$(git -C "$REPO" rev-parse --git-common-dir)"
# git-common-dir may be relative to the repo dir
case "$COMMON" in /*|?:*) : ;; *) COMMON="$REPO/$COMMON" ;; esac
TOKEN="$COMMON/SHIP_AUTH"
BTOKEN="$COMMON/SHIP_AUTH_BRANCH"

FAKE_SHA="1111111111111111111111111111111111111111"
OTHER_SHA="2222222222222222222222222222222222222222"

pass=0; fail=0
# run_case <name> <want_exit> <stdin-line>   (env: token files already staged)
run_case() {
  local name="$1" want="$2" line="$3" got
  ( cd "$REPO" && printf '%s\n' "$line" | bash "$HOOK_SRC" ) >/dev/null 2>&1
  got=$?
  if [ "$got" = "$want" ]; then
    echo "  PASS  $name (exit $got)"; pass=$((pass+1))
  else
    echo "  FAIL  $name (want exit $want, got $got)"; fail=$((fail+1))
  fi
}

echo "== ship-auth hook tests =="

# (a) matching SHA -> allow, feature branch
rm -f "$TOKEN" "$BTOKEN"; printf '%s' "$FAKE_SHA" > "$TOKEN"
run_case "(a) matching SHA -> allow" 0 \
  "refs/heads/feature/x $FAKE_SHA refs/heads/feature/x $OTHER_SHA"

# (b) matching branch pattern, fresh mtime -> allow
rm -f "$TOKEN" "$BTOKEN"; printf 'feature/retention-* 2h\n' > "$BTOKEN"
run_case "(b) branch grant in window -> allow" 0 \
  "refs/heads/feature/retention-abc $FAKE_SHA refs/heads/feature/retention-abc $OTHER_SHA"

# (c) branch grant must NOT authorize main -> deny
rm -f "$TOKEN" "$BTOKEN"; printf 'main 2h\n' > "$BTOKEN"
run_case "(c) branch grant to main -> deny" 1 \
  "refs/heads/main $FAKE_SHA refs/heads/main $OTHER_SHA"

# (d) branch grant out of window -> deny + file deleted
rm -f "$TOKEN" "$BTOKEN"; printf 'feature/retention-* 30m\n' > "$BTOKEN"
touch -d '2 hours ago' "$BTOKEN" 2>/dev/null || touch -t "$(date -v-2H +%Y%m%d%H%M 2>/dev/null || echo 202001010000)" "$BTOKEN"
run_case "(d) branch grant expired -> deny" 1 \
  "refs/heads/feature/retention-abc $FAKE_SHA refs/heads/feature/retention-abc $OTHER_SHA"
if [ ! -f "$BTOKEN" ]; then echo "  PASS  (d) expired grant file was deleted"; pass=$((pass+1));
else echo "  FAIL  (d) expired grant file still present"; fail=$((fail+1)); fi

# (e) no grant -> deny
rm -f "$TOKEN" "$BTOKEN"
run_case "(e) no grant -> deny" 1 \
  "refs/heads/feature/x $FAKE_SHA refs/heads/feature/x $OTHER_SHA"

# (f) over-8h cap -> deny
rm -f "$TOKEN" "$BTOKEN"; printf 'feature/* 9h\n' > "$BTOKEN"
run_case "(f) branch grant over 8h cap -> deny" 1 \
  "refs/heads/feature/x $FAKE_SHA refs/heads/feature/x $OTHER_SHA"

# (g) matching SHA to main -> allow (per-SHA authorizes main)
rm -f "$TOKEN" "$BTOKEN"; printf '%s' "$FAKE_SHA" > "$TOKEN"
run_case "(g) matching SHA to main -> allow" 0 \
  "refs/heads/main $FAKE_SHA refs/heads/main $OTHER_SHA"

echo "== $pass passed, $fail failed =="
[ "$fail" = "0" ]
