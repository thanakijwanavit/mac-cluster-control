---
title: mac mini 3
type: machine
status: stable
tags: [machine, mini]
tailscale_host: mac-mini-3
created: 2026-08-14
updated: 2026-08-19
owner: nic
---

# mac mini 3

M4 Pro Mac mini (`Mac16,11`), 64 GB, macOS 26.5 (25F71). MagicDNS `mac-mini-3.taile8dc37.ts.net`, IPv4 `100.122.229.17`. Data volume 159 GB / 460 GB (37%).

| | |
|---|---|
| SSH | **Works.** `ssh mini3` → `nic` (uid 501) |
| Other user | `villa` uid 502, admin group, **SSH disabled** (`com.apple.access_ssh-disabled`). No `authorized_keys` |
| Mosh | `mosh-server` 1.4.0. Same UDP failure from nmba as magnus |
| Jump VNC | Bookmark `mac-mini-3` → hostname `mac-mini-3` port 5900. Port **open** |
| Jump SSH | Added 2026-08-14 → `mac-mini-3.taile8dc37.ts.net:22` user `nic` |
| Stale Jump | Bookmark `nics-mac-mini3` used to target `nics-mac-mini-3-pratham` (not on the tailnet). Retargeted to MagicDNS 2026-08-14 |
| Tailscale path from nmba | direct via `27.130.19.243:41641`, ping 24 ms |
| LAN | Advertises `_ssh._tcp` Bonjour. Sees magnus and nic's MacBook Pro on the same LAN |

Same Air pubkey in `nic`'s `authorized_keys` as on [[magnus-mac-mini]].

## Control-plane hub (2026-08-16)

This mini hosts the fleet control plane:

- Fleet SSH key `~/.ssh/fleet_ed25519` (`fleet@mac-mini-3`); its pubkey is in `authorized_keys` on magnus and nmba. Config block `# mac-cluster fleet block` in `~/.ssh/config` (aliases magnus, nmbp, mini2, nmba).
- Repo checkout `~/stacks/mac-cluster-control` (HTTPS clone of the public repo).
- launchd: `com.maccluster.fleet-dashboard` (python http.server :8788 → dashboard dir), `com.maccluster.fleet-audit` (hourly audit + rsync publish to doconnect-sf), `com.maccluster.fleet-housekeeping` (Mon 09:17).
- `tailscale serve --bg 8788` exposes a secondary copy at https://mac-mini-3.taile8dc37.ts.net/ tailnet-only. Primary dashboard is on doconnect-sf — see [[fleet-dashboard]] and [[housekeeping]].

Agent CLIs (2026-08-19 housekeeping): Kimi Code **0.37.2**, claude native **2.1.235** (`~/.local/share/claude/versions/2.1.235`). `/opt/homebrew/bin/claude` was a leftover 2.1.31 Mach-O (not a keg); it is now a symlink to the native binary so the `.zshrc` `claude()` wrapper still works. Old 2.1.31 sits at `~/.local/share/claude-leftovers/`. `cursor-agent update` fails `[unauthenticated]`; brew `cursor-agent` reports 2026.02.13-41ac335, versions dir also has 2026.05.24. grok **1.0.5**.

Housekeeping from this box used to stop after the local host — see [[housekeeping]] stdin bug. `nmbp` from here is `Host key verification failed` (known_hosts has no key for this Pro).
