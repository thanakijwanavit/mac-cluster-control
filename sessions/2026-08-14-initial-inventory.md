---
title: 2026-08-14 initial inventory
type: session
status: open
tags: [session]
created: 2026-08-14
updated: 2026-08-14
owner: nic
---

# 2026-08-14 initial inventory

Stood up this Obsidian vault and probed every macOS node on the tailnet from [[nmba]].

## Done

- Vault at repo root (Obsidian `.obsidian/`, `Home.md`, machine/runbook/reference notes)
- `~/.ssh/config` cluster aliases; verified `ssh magnus` and `ssh mini3`
- `~/.local/bin/tailscale` wrapper (symlink of the app binary crashes)
- Jump Desktop: SSH bookmarks for mini-3, mini-2, MBP; VNC for MBP; retargeted stale `nics-mac-mini-3-pratham` → mini-3 MagicDNS
- Probe script `scripts/probe-macs.sh`

## Measured

- 8 macOS devices on the tailnet; 4 online (nmba, magnus, mini-3, nics-macbook-pro)
- Mini-3 Bonjour also sees nic's MacBook Pro on the same LAN; mini-2 is not there
- Mini-2 Tailscale key expired 2026-08-01, last seen 2026-08-03
- MBP :22/:5900 open, Air key denied for nic/thanakijwanavit/admin/pratham
- Mosh UDP timeout; magnus disk 101 MiB free

## Left open

SSH onto MBP via Jump + key install (`mcc-bzh`). Power/re-auth mini-2 (`mcc-2a3`). Free magnus disk (`mcc-bhh`). Mosh UDP (`mcc-87g`). Beads prefix `mcc` initialised (local commit `9b1f50c`, not pushed).
