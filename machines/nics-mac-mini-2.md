---
title: nic’s Mac mini (nics-mac-mini-2)
type: machine
status: open
tags: [machine, mini, offline]
tailscale_host: nics-mac-mini-2
symptoms:
  - "offline, last seen 11d ago"
  - "tailscale key expired"
created: 2026-08-14
updated: 2026-08-14
owner: nic
---

# nics-mac-mini-2

Display name `nic’s Mac mini`. MagicDNS `nics-mac-mini-2.taile8dc37.ts.net`, IPv4 `100.97.242.33`. Advertises an exit node in the coordination map but is **offline**.

## Why it is dark

Measured 2026-08-14 from nmba and from [[mac-mini-3]]:

- Tailscale `LastSeen`: 2026-08-03T01:34:58Z
- Tailscale `KeyExpiry`: **2026-08-01T06:47:04Z** (expired 13 days before inventory)
- TCP 22 and 5900 **closed**
- Bonjour `_ssh._tcp` on the mini LAN does **not** list it
- `nics-mac-mini-2.local` does not resolve from mini-3 or magnus

This is powered off, asleep off-network, or Tailscale-expired — not a firewall-on-an-online-box. Re-auth requires a console (physical or a Jump session while it is up). Wake-on-LAN over Tailscale cannot start a daemon that is not running.

## Access that is already prepared

| | |
|---|---|
| SSH config | `ssh mini2` → MagicDNS, user `nic`, Air key |
| Jump VNC | Bookmark `mac-mini-2` → hostname `nics-mac-mini-2` port 5900 |
| Jump SSH | Added 2026-08-14 → MagicDNS port 22 user `nic` |

`authorized_keys` on this box is unknown until it comes back. The Air key is present on the other minis; likely the same there historically (`known_hosts` already has `100.97.242.33`).
