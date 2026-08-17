---
title: Probe the Mac cluster
type: runbook
status: stable
tags: [runbook, inventory]
updated: 2026-08-14
---

# Probe the cluster

From nmba:

```bash
~/stacks/mac-cluster-control/scripts/probe-macs.sh
```

Manual equivalent:

```bash
tailscale status
tailscale ping --c 2 --timeout 4s mac-mini-3
tailscale ping --c 2 --timeout 4s magnus-mac-mini
tailscale ping --c 2 --timeout 4s nics-macbook-pro

for h in 100.122.229.17 100.122.25.8 100.65.143.12 100.97.242.33; do
  echo "== $h =="
  nc -z -G 3 "$h" 22 && echo 22 open || echo 22 closed
  nc -z -G 3 "$h" 5900 && echo 5900 open || echo 5900 closed
done

ssh -o BatchMode=yes -o ConnectTimeout=8 magnus 'hostname; whoami'
ssh -o BatchMode=yes -o ConnectTimeout=8 mini3 'hostname; whoami'
ssh -o BatchMode=yes -o ConnectTimeout=8 nmbp 'hostname; whoami'
```

From a mini, see who is on the LAN:

```bash
ssh mini3 'dns-sd -B _ssh._tcp local.'
# wait a few seconds, Ctrl-C
```

Write results into [[access-matrix]] and the machine note. Do not leave them only in chat.
