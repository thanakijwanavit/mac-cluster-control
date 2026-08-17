---
title: Fleet dashboard
type: system
status: stable
tags: [dashboard, tailscale, inventory]
created: 2026-08-16
updated: 2026-08-16
owner: nic
---

# Fleet dashboard

Live per-Mac status (online, macOS, Tailscale, SSH/VNC ports, agent CLI
versions, disk, uptime), tailnet-only:

**https://doconnect-sf.taile8dc37.ts.net:8443/** (primary, always-on Linux box)

Secondary copy on the auditing Mac itself: https://mac-mini-3.taile8dc37.ts.net/

## How it works

| Piece | Where |
|---|---|
| Registry | `reference/fleet.json` — the one place to add/remove a Mac |
| Audit | `scripts/fleet-audit.sh` → `dashboard/data.json` (read-only, safe to run anytime) |
| Page | `dashboard/index.html` — static, reloads `data.json` every 60 s |
| Publisher | launchd `com.maccluster.fleet-audit` on mini3, hourly via `scripts/scheduled-audit.sh` — audits, then rsyncs `index.html`+`data.json` to `doconnect-sf:/var/www/mac-fleet/` |
| Serving | `tailscale serve --bg --https=8443 /var/www/mac-fleet` on doconnect-sf (Linux tailscaled can serve paths directly, unlike the sandboxed macOS app) |
| mini3 copy | launchd `com.maccluster.fleet-dashboard` (python http.server :8788) + `tailscale serve --bg 8788` |

doconnect-sf root :443 already proxies another service on localhost:8471 — do
not reset its serve config; the dashboard deliberately lives on **:8443**.

## Operating it

```bash
# force a fresh audit + publish right now (from mini3)
ssh mini3 'bash ~/stacks/mac-cluster-control/scripts/scheduled-audit.sh'

# audit only, no publish
~/stacks/mac-cluster-control/scripts/fleet-audit.sh

# check the jobs on mini3
ssh mini3 'launchctl print gui/$(id -u)/com.maccluster.fleet-dashboard | grep "state ="'
ssh mini3 'tail -5 ~/Library/Logs/fleet-audit.log'
```

If the publish leg fails (doconnect-sf down), the mini3 copy still updates and
the failure is logged, never fatal. `data.json` is regenerated, never
hand-edited. Rows for offline/SSH-denied hosts stay in the table with empty
fields — intended signal, not a bug.

nmba keeps Remote Login off, so mini3's audit shows it online-with-no-details;
running `fleet-audit.sh` on the Air fills its own row in (but only mini3's
hourly run publishes to doconnect-sf).
