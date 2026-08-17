#!/usr/bin/env bash
# Scheduled audit entry point (launchd on mac-mini-3).
# Pulls the repo if possible (data files are untracked there, so a failed
# pull is non-fatal), runs the fleet audit, then publishes the dashboard
# to doconnect-sf (the always-on Linux box that serves it tailnet-wide).
set -uo pipefail
REPO="$HOME/stacks/mac-cluster-control"
git -C "$REPO" pull --rebase --quiet 2>/dev/null || echo "git pull skipped/failed; auditing from on-disk copy"
bash "$REPO/scripts/fleet-audit.sh"
rsync -az -e "ssh -o BatchMode=yes -o ConnectTimeout=8" \
  "$REPO/dashboard/index.html" "$REPO/dashboard/data.json" \
  doconnect-sf:/var/www/mac-fleet/ \
  && echo "published to doconnect-sf" || echo "publish to doconnect-sf failed (kept local copy)"
