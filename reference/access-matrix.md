---
title: Access matrix
type: reference
status: open
tags: [ssh, mosh, jump, tailscale]
updated: 2026-08-14
---

# Access matrix

Measured from [[nmba]] on 2026-08-14. Re-run [[probe-cluster]] before trusting this.

| Host | Online | TS ping | :22 | SSH login | mosh | :5900 | Jump VNC bookmark | Jump SSH bookmark |
|---|---|---|---|---|---|---|---|---|
| nmba | yes | self | no listener | n/a | client only | no listener | n/a | n/a |
| magnus-mac-mini | yes | direct 29 ms | open | **nic / Air key** | server up, UDP fail | open | yes (`magnus`) | yes |
| mac-mini-3 | yes | direct 24 ms | open | **nic / Air key** | server up, UDP fail | open | yes + stale alias fixed | **added** |
| nics-macbook-pro | yes | DERP 80 ms | open | denied (4 users) | not tested | open | **added** | **added** |
| nics-mac-mini-2 | no | — | closed | — | — | closed | yes (`mac-mini-2`) | **added** |
| prathams-macbook-air-1 | no | — | closed | — | — | closed | no | no |

SSH aliases: `magnus`, `mini3`, `mini2`, `nmbp` — see [[ssh-config]].

## From mac-mini-3 (fleet key, 2026-08-16)

mini3 has its own fleet ed25519 key (see [[ssh-config]]) and can SSH to
**magnus** (verified) and itself; `nmbp`/`mini2` stanzas exist but fail until
those boxes get the key / come back online. The fleet key pubkey is also in
nmba's `authorized_keys` (Remote Login still off there). This path is what the
scheduled audit, housekeeping, and the [[fleet-dashboard]] use — the Air no
longer needs to be awake for those.

Version inventory (kimi / claude / cursor-agent / grok, macOS, Tailscale) now
lives on the dashboard: https://doconnect-sf.taile8dc37.ts.net:8443/ —
refreshed hourly, see [[fleet-dashboard]].
