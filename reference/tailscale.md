---
title: Tailscale
type: reference
status: stable
tags: [tailscale]
updated: 2026-08-14
---

# Tailscale

| | |
|---|---|
| Tailnet | `thanakijwanavit.github` |
| MagicDNS | `taile8dc37.ts.net` (enabled) |
| CLI on nmba | `~/.local/bin/tailscale` wraps Tailscale.app. Do **not** symlink the binary — argv[0] must stay inside the app bundle |
| App Store limitation | `tailscale ssh` is not available. Use OpenSSH |
| This Air | `nmba` / `100.85.210.76` / Funnel on `https://nmba.taile8dc37.ts.net` |

## Useful commands

```bash
tailscale status
tailscale status --json
tailscale ping --c 2 --timeout 4s mac-mini-3
# --timeout needs a duration suffix; `--timeout 4` prints help and looks like a hang
```

## Path notes (2026-08-14)

- [[magnus-mac-mini]] and [[mac-mini-3]]: direct WireGuard to public `27.130.19.243` (different UDP ports).
- [[nics-macbook-pro]]: DERP Singapore only from nmba, even though it shares LAN with the minis (seen via Bonjour from mini-3).
- Several node keys have expired (mini-2, Marcus, Alexander, old iOS). Expired nodes stay in `status` as offline until re-auth or removal in the admin console.

Linux nodes on the same tailnet (GPUs, gastown, openclawmaster, …) are not this vault's job unless a Mac uses them as an exit node. [[magnus-mac-mini]] and [[nics-mac-mini-2]] advertise exit nodes.
