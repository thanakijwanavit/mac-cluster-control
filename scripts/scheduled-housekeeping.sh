#!/usr/bin/env bash
# Scheduled housekeeping entry point (launchd on mac-mini-3, weekly).
# Pulls the repo if possible, then runs housekeeping with --install-missing
# so new gaps (missing CLIs) get fixed unattended. Ends with a fresh audit.
set -uo pipefail
REPO="$HOME/stacks/mac-cluster-control"
git -C "$REPO" pull --rebase --quiet 2>/dev/null || echo "git pull skipped/failed; using on-disk copy"
exec bash "$REPO/scripts/housekeeping.sh" --install-missing
