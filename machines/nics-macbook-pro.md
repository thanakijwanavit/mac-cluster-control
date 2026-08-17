---
title: nic’s MacBook Pro
type: machine
status: open
tags: [machine, laptop]
tailscale_host: nics-macbook-pro
symptoms:
  - "Permission denied (publickey,password,keyboard-interactive)"
created: 2026-08-14
updated: 2026-08-14
owner: nic
---

# nics-macbook-pro

MagicDNS `nics-macbook-pro.taile8dc37.ts.net`, IPv4 `100.65.143.12`. Online on 2026-08-14. Same LAN as the minis (Bonjour `_ssh._tcp` instance `nic’s MacBook Pro`). Tailscale path from nmba was **DERP(sin)** only (79–80 ms), no direct WireGuard — unlike the minis.

## Access

| | |
|---|---|
| TCP 22 | **open** |
| TCP 5900 | **open** |
| SSH as `nic`, `thanakijwanavit`, `admin`, `pratham` | **Permission denied** (BatchMode, Air ed25519) |
| Tailscale SSH | unavailable on nmba's App Store client |
| Jump VNC | Added 2026-08-14 → MagicDNS port 5900 |
| Jump SSH | Added 2026-08-14 → MagicDNS port 22 user `nic` |
| SSH config | `ssh nmbp` |

Remote Login is on (port 22 answers) but this Air's key is not in whoever the login user is. The minis' `authorized_keys` contain `ssh-rsa … nic@nics-MacBook-Pro.local`, so this machine used to SSH *out* with an RSA key; that does not grant inbound access from the Air.

## How to finish SSH

Use Jump Desktop screen sharing (port is open), log in, then [[add-ssh-key-via-jump]]. Until then, Jump is the only console path from nmba.
