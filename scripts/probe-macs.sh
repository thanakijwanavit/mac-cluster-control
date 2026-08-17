#!/usr/bin/env bash
# Probe macOS nodes on the tailnet from nmba. Writes to stdout; update
# reference/access-matrix.md with anything that changed.
set -euo pipefail

TS="${TAILSCALE:-$HOME/.local/bin/tailscale}"
if [[ ! -x "$TS" ]]; then
  TS="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

hosts=(
  magnus-mac-mini
  mac-mini-3
  nics-macbook-pro
  nics-mac-mini-2
  prathams-macbook-air-1
)

echo "=== tailscale macOS ==="
"$TS" status | awk 'tolower($0) ~ /macos/' || true
echo

for h in "${hosts[@]}"; do
  echo "======== $h ========"
  if ! "$TS" ping --c 1 --timeout 3s "$h" 2>/dev/null | tail -1; then
    echo "tailscale ping: no pong"
  fi
  ip="$("$TS" ip -4 "$h" 2>/dev/null || true)"
  if [[ -z "$ip" ]]; then
    echo "no tailscale ipv4"
    echo
    continue
  fi
  echo "ipv4 $ip"
  if nc -z -G 3 "$ip" 22 >/dev/null 2>&1; then echo "22 open"; else echo "22 closed"; fi
  if nc -z -G 3 "$ip" 5900 >/dev/null 2>&1; then echo "5900 open"; else echo "5900 closed"; fi
  ssh -o BatchMode=yes -o ConnectTimeout=6 -o IdentitiesOnly=yes -i "$HOME/.ssh/id_ed25519" \
    "nic@$ip" 'echo ssh_ok $(hostname) $(whoami)' 2>&1 | sed 's/^/ssh: /' || true
  echo
done
