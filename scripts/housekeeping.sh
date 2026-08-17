#!/usr/bin/env bash
# Fleet housekeeping: upgrade agent CLIs (kimi, claude, cursor-agent, grok)
# on every reachable Mac in reference/fleet.json, report brew staleness,
# then re-run the audit so the dashboard reflects the result.
#
# Usage: housekeeping.sh [--install-missing]
#   --install-missing   also install tools that are absent (default: upgrade only)
#
# Logs to dashboard/housekeeping.log (served on the dashboard URL).
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLEET="$REPO/reference/fleet.json"
LOG="$REPO/dashboard/housekeeping.log"
TS="${TAILSCALE:-$HOME/.local/bin/tailscale}"
[[ -x "$TS" ]] || TS="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

INSTALL=0
[[ "${1:-}" == "--install-missing" ]] && INSTALL=1

SELF="$("$TS" status --json 2>/dev/null | jq -r '.Self.DNSName // empty' | cut -d. -f1 | tr 'A-Z' 'a-z')"
[[ -n "$SELF" ]] || SELF="$(hostname -s | tr 'A-Z' 'a-z')"

read -r -d '' REMOTE <<'EOF' || true
pathof() {
  p=$(command -v "$1" 2>/dev/null) && { echo "$p"; return 0; }
  for d in "$HOME/.kimi-code/bin" "$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin; do
    [[ -x "$d/$1" ]] && { echo "$d/$1"; return 0; }
  done
  return 1
}
have() { pathof "$1" >/dev/null 2>&1; }

echo "## kimi"
if have kimi; then
  # curl installer is idempotent and non-interactive; `kimi upgrade` prompts a TUI
  curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash 2>&1 | tail -3
elif [ INSTALLFLAG -eq 1 ]; then
  curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash 2>&1 | tail -3
else
  echo "missing (run with --install-missing to install)"
fi

echo "## claude"
if have claude; then
  "$(pathof claude)" update 2>&1 | tail -3
elif [ INSTALLFLAG -eq 1 ]; then
  curl -fsSL https://claude.ai/install.sh | bash 2>&1 | tail -3
else
  echo "missing (run with --install-missing to install)"
fi

echo "## cursor-agent"
if have cursor-agent; then
  "$(pathof cursor-agent)" update 2>&1 | tail -3
elif [ INSTALLFLAG -eq 1 ]; then
  curl -fsSL https://cursor.com/install | bash 2>&1 | tail -3
else
  echo "missing (run with --install-missing to install)"
fi

echo "## grok"
if have grok; then
  brew upgrade grok-build 2>&1 | tail -2
elif [ INSTALLFLAG -eq 1 ]; then
  if have brew; then
    brew install --cask grok-build 2>&1 | tail -2 || brew install grok-build 2>&1 | tail -2
  else
    echo "no homebrew on this host — install brew first"
  fi
else
  echo "missing (run with --install-missing to install)"
fi

echo "## brew outdated"
if have brew; then brew update --quiet 2>/dev/null; brew outdated 2>/dev/null || echo "(all current)"; else echo "no homebrew"; fi
EOF
REMOTE="${REMOTE//INSTALLFLAG/$INSTALL}"

run_on() { # $1=alias-or-empty
  if [[ -z "$1" ]]; then bash -c "$REMOTE" 2>&1
  else ssh -o BatchMode=yes -o ConnectTimeout=8 "$1" "bash -s" <<<"$REMOTE" 2>&1; fi
}

{
  echo "================================================================"
  echo "housekeeping run $(date -u +%Y-%m-%dT%H:%M:%SZ) from $SELF (install-missing=$INSTALL)"

  while IFS= read -r host; do
    name=$(jq -r '.name' <<<"$host")
    alias=$(jq -r '.alias // empty' <<<"$host")
    echo
    echo "######## $name ########"
    if [[ "$(tr 'A-Z' 'a-z' <<<"$name")" == "$SELF" ]]; then
      run_on ""
      continue
    fi
    if ! "$TS" ping --c 2 --timeout 4s "$name" >/dev/null 2>&1; then
      echo "offline — skipped"; continue
    fi
    if [[ -z "$alias" ]]; then
      echo "no SSH alias — skipped"; continue
    fi
    if ! ssh -n -o BatchMode=yes -o ConnectTimeout=6 "$alias" true 2>/dev/null; then
      echo "ssh unavailable — skipped"; continue
    fi
    run_on "$alias"
  done < <(jq -c '.hosts[]' "$FLEET")

  echo
  echo "######## re-audit ########"
  bash "$REPO/scripts/fleet-audit.sh"
} 2>&1 | tee -a "$LOG"
