#!/usr/bin/env bash
# Install the canonical ship-gate pre-push hook into this repo's git-common dir.
#
#   Usage:  bash tools/install-ship-auth-hook.sh
#
# Copies tools/ship-auth-pre-push -> <git-common-dir>/hooks/pre-push and makes
# it executable. Any pre-existing pre-push is backed up next to it once.
# Safe to re-run: it overwrites the installed hook with the tracked source.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$here/tools/ship-auth-pre-push"
common="$(git rev-parse --git-common-dir)"
dst="$common/hooks/pre-push"

[ -f "$src" ] || { echo "ERROR: source hook not found: $src" >&2; exit 1; }
mkdir -p "$common/hooks"

if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
  if [ ! -f "$dst.pre-shipauth.bak" ]; then
    cp "$dst" "$dst.pre-shipauth.bak"
    echo "backed up existing hook -> $dst.pre-shipauth.bak"
  fi
fi

cp "$src" "$dst"
chmod +x "$dst"
echo "installed ship-gate pre-push -> $dst"
