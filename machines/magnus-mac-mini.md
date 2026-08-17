---
title: magnus mac mini
type: machine
status: monitoring
tags: [machine, mini, exit-node]
tailscale_host: magnus-mac-mini
created: 2026-08-14
updated: 2026-08-14
owner: nic
---

# magnus mac mini

M1 Mac mini (`Macmini9,1`), 16 GB, macOS 26.2 (25C56). MagicDNS `magnus-mac-mini.taile8dc37.ts.net`, IPv4 `100.122.25.8`. Advertises a Tailscale **exit node**. Uptime ~20 days when inventoried.

| | |
|---|---|
| SSH | **Works.** `ssh magnus` → `nic` (uid 501). Also `macports` uid 502 |
| Mosh | `mosh-server` 1.3.2 at `/opt/homebrew/bin/mosh-server`. Binds UDP `100.122.25.8:60001`. From nmba the UDP handshake **times out** — see [[2026-08-14-mosh-udp-blocked-over-tailscale]] |
| Jump VNC | Bookmark `magnus` → hostname `magnus-mac-mini` port 5900. Port **open** |
| Jump SSH | Bookmark `magnus-mac-mini` → `100.122.25.8:22` user `nic` |
| Tailscale path from nmba | direct via `27.130.19.243:1386`, ping 29 ms |
| Disk | **101 MiB free** on 228 GB APFS Data — [[2026-08-14-magnus-disk-full]] |

`~/.ssh/authorized_keys` on this box already contains the Air ed25519 key (`nic@nics-MacBook-Air.local`) and an RSA key from `nic@nics-MacBook-Pro.local`.

2026-08-16: the mac-mini-3 fleet key (`fleet@mac-mini-3`) is now in `authorized_keys` too — the scheduled audit/housekeeping from mini3 uses it (verified `fleet_ssh_ok`). Default shell for `nic` is **fish**; run probes as `ssh magnus "bash -s"` heredocs, not POSIX `$()` one-liners. Note: `kimi` here is brew `kimi-cli` 1.14.0 (a different tool), not Kimi Code. grok cannot be installed — `brew install --cask grok-build` fails `No space left on device` (220Mi free) until `mcc-bhh` is fixed. Tailscale pings from nmba are intermittently lost even while the box is up (observed during housekeeping runs).
