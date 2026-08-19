---
title: nic’s MacBook Pro
type: machine
status: open
tags: [machine, laptop]
tailscale_host: nics-macbook-pro
symptoms:
  - "Permission denied (publickey,password,keyboard-interactive)"
created: 2026-08-14
updated: 2026-08-19
owner: nic
---

# nics-macbook-pro

MagicDNS `nics-macbook-pro.taile8dc37.ts.net`, IPv4 `100.65.143.12`. ComputerName hostname `nics-MacBook-Pro-3`, macOS 26.2. Same LAN as the minis (Bonjour `_ssh._tcp` instance `nic’s MacBook Pro`). Used as the operator console on 2026-08-19 ([[2026-08-19-upgrade]]).

Agent CLIs (2026-08-19, upgraded on-box): Kimi Code **0.37.2** (`~/.kimi-code/bin`, wins PATH; brew `kimi-code` 0.36.1 also present), claude **2.1.227** (native `~/.local/bin` and brew), cursor-agent **2026.08.11-e8db854**, grok **1.0.5** (`~/.grok/bin`, not the brew cask; `grok update` is the path). No `~/.local/bin/tailscale` wrapper — use Tailscale.app.

SSH **out** works with `~/.ssh/id_rsa` (`id_rsa.pub` only key here, agent empty) to `nic@mac-mini-3` and `nic@magnus-mac-mini` (short Tailscale names). There is **no** fleet block in `~/.ssh/config` (only `Host capybaras`). MagicDNS FQDNs fail `Host key verification failed`. Inbound from mini3 / the Air key is still denied — dashboard will keep showing `ssh-denied` until a fleet or Air pubkey is in `authorized_keys`.

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
