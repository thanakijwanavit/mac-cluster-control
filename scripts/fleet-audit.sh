#!/usr/bin/env bash
# Fleet audit: read-only inventory of every Mac in reference/fleet.json.
# Writes dashboard/data.json and prints a summary table.
# Safe to run any time; unreachable hosts are recorded, never fatal.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLEET="$REPO/reference/fleet.json"
OUT="$REPO/dashboard/data.json"
TS="${TAILSCALE:-$HOME/.local/bin/tailscale}"
[[ -x "$TS" ]] || TS="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

TOOLS=$(jq -r '.tools | join(" ")' "$FLEET")
SELF="$("$TS" status --json 2>/dev/null | jq -r '.Self.DNSName // empty' | cut -d. -f1 | tr 'A-Z' 'a-z')"
[[ -n "$SELF" ]] || SELF="$(hostname -s | tr 'A-Z' 'a-z')"

# Probe snippet run on each target (locally for self, over SSH otherwise).
# Emits key=value lines; values are single-line.
read -r -d '' PROBE <<'EOF' || true
echo "macos=$(sw_vers -productVersion 2>/dev/null)"
echo "build=$(sw_vers -buildVersion 2>/dev/null)"
echo "arch=$(uname -m)"
boot=$(sysctl -n kern.boottime 2>/dev/null | sed -n 's/.*{ sec = \([0-9]*\).*/\1/p')
now=$(date +%s)
[[ -n "$boot" ]] && echo "uptime_days=$(( (now - boot) / 86400 ))" || echo "uptime_days="
echo "disk_free=$(df -h / 2>/dev/null | awk 'NR==2{print $4}')"
tsv=$(/Applications/Tailscale.app/Contents/MacOS/Tailscale version 2>/dev/null | head -1)
[[ -z "$tsv" ]] && tsv=$(tailscale version 2>/dev/null | head -1)
echo "tailscale=${tsv:-missing}"
jump=$(ls -d /Applications/Jump* 2>/dev/null | head -1 | xargs -I{} basename {} .app)
echo "jump=${jump:-missing}"
for t in TOOLSLIST; do
  bin=$(command -v "$t" 2>/dev/null)
  if [[ -z "$bin" ]]; then
    for d in "$HOME/.kimi-code/bin" "$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin; do
      [[ -x "$d/$t" ]] && bin="$d/$t" && break
    done
  fi
  if [[ -n "$bin" ]]; then
    v=$("$bin" --version 2>/dev/null | head -1 | tr -d '\r')
    echo "tool_$t=${v:-present}"
  else
    echo "tool_$t=missing"
  fi
done
EOF
PROBE="${PROBE//TOOLSLIST/$TOOLS}"

run_probe() { # $1=alias-or-empty  -> key=value lines on stdout
  if [[ -z "$1" ]]; then
    bash -c "$PROBE" 2>/dev/null
  else
    ssh -o BatchMode=yes -o ConnectTimeout=6 "$1" "bash -s" <<<"$PROBE" 2>/dev/null
  fi
}

kv() { grep "^$2=" <<<"$1" | head -1 | cut -d= -f2-; }

hosts_json="[]"
printf '%-24s %-8s %-12s %-10s %s\n' HOST STATUS MACOS TAILSCALE TOOLS

while IFS= read -r host; do
  name=$(jq -r '.name' <<<"$host")
  alias=$(jq -r '.alias // empty' <<<"$host")
  is_self=false
  [[ "$(tr 'A-Z' 'a-z' <<<"$name")" == "$SELF" ]] && is_self=true

  online=false; port22=closed; port5900=closed; ssh_state="n/a"; probe_out=""

  if $is_self; then
    online=true; ssh_state="self"
    nc -z -G 2 127.0.0.1 22   >/dev/null 2>&1 && port22=open
    nc -z -G 2 127.0.0.1 5900 >/dev/null 2>&1 && port5900=open
    probe_out=$(run_probe "")
  else
    if "$TS" ping --c 2 --timeout 4s "$name" >/dev/null 2>&1; then online=true; fi
    ip="$("$TS" ip -4 "$name" 2>/dev/null || true)"
    if $online && [[ -n "$ip" ]]; then
      nc -z -G 3 "$ip" 22   >/dev/null 2>&1 && port22=open
      nc -z -G 3 "$ip" 5900 >/dev/null 2>&1 && port5900=open
    fi
    if [[ "$port22" == open && -n "$alias" ]]; then
      if probe_out=$(run_probe "$alias") && [[ -n "$probe_out" ]]; then
        ssh_state="ok"
      else
        ssh_state="denied"
      fi
    elif [[ "$port22" == open ]]; then
      ssh_state="no-alias"
    fi
  fi

  status=offline
  $online && status=online
  [[ "$ssh_state" == denied ]] && status=ssh-denied

  rec=$(jq -n \
    --arg name "$name" --arg status "$status" \
    --arg port22 "$port22" --arg port5900 "$port5900" --arg ssh "$ssh_state" \
    --arg macos "$(kv "$probe_out" macos)" --arg build "$(kv "$probe_out" build)" \
    --arg arch "$(kv "$probe_out" arch)" --arg uptime "$(kv "$probe_out" uptime_days)" \
    --arg disk "$(kv "$probe_out" disk_free)" --arg ts "$(kv "$probe_out" tailscale)" \
    --arg jump "$(kv "$probe_out" jump)" \
    '{name:$name,status:$status,port22:$port22,port5900:$port5900,ssh:$ssh,
      macos:$macos,build:$build,arch:$arch,uptime_days:$uptime,disk_free:$disk,
      tailscale:$ts,jump:$jump,tools:{}}')
  for t in $TOOLS; do
    rec=$(jq --arg t "$t" --arg v "$(kv "$probe_out" "tool_$t")" '.tools[$t]=$v' <<<"$rec")
  done
  hosts_json=$(jq --argjson r "$rec" '. + [$r]' <<<"$hosts_json")

  tool_summary=$(for t in $TOOLS; do v=$(kv "$probe_out" "tool_$t"); [[ "$v" == missing || -z "$v" ]] && continue; printf '%s ' "$t"; done)
  printf '%-24s %-8s %-12s %-10s %s\n' "$name" "$status" \
    "$(kv "$probe_out" macos)" "$(kv "$probe_out" tailscale | cut -c1-10)" "$tool_summary"
done < <(jq -c '.hosts[]' "$FLEET")

mkdir -p "$REPO/dashboard"
jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg from "$SELF" --argjson h "$hosts_json" \
  '{generated:$ts,audited_from:$from,hosts:$h}' >"$OUT"
echo
echo "wrote $OUT"
