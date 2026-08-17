---
title: Mac Cluster Control
type: reference
status: stable
tags: [moc, home]
created: 2026-08-14
updated: 2026-08-14
owner: nic
---

# Mac Cluster Control

Obsidian vault for the Mac fleet on tailnet `thanakijwanavit.github` (`taile8dc37.ts.net`). **Agents write, people review.** Open this folder as an Obsidian vault.

This GitHub repo is **public**. Do not put passwords, key material, or Jump Desktop keychain secrets here. MagicDNS names and Tailscale `100.x` addresses only resolve on the tailnet.

## I need to…

| | |
|---|---|
| **see which Macs exist** | [[machines/_index\|Machines]] |
| **live status + versions (dashboard)** | https://doconnect-sf.taile8dc37.ts.net:8443/ → [[fleet-dashboard]] |
| **know what actually works today** | [[access-matrix]] |
| **SSH / mosh / Jump Desktop** | [[ssh-access]] · [[mosh-access]] · [[jump-desktop]] |
| **re-probe the fleet** | [[probe-cluster]] |
| **upgrade agent CLIs everywhere** | [[housekeeping]] |
| **run commands from any agent** | `mcp/fleet-mcp/README.md` |
| **understand Tailscale** | [[tailscale]] |
| **see what broke** | [[incidents/index\|Incidents]] |
| **how to write notes** | [[AGENTS]] |

## Access snapshot (2026-08-14, from nmba)

| Machine | Tailscale | SSH | Mosh | Jump (VNC :5900) |
|---|---|---|---|---|
| [[nmba]] (this Air) | online | n/a (client) | client 1.4.0 | n/a |
| [[magnus-mac-mini]] | online, exit node, direct | **ok** `nic@magnus` | server installed, **UDP fails** | bookmark exists, port open |
| [[mac-mini-3]] | online, direct | **ok** `nic@mini3` | server installed, **UDP fails** | bookmark exists, port open |
| [[nics-macbook-pro]] | online, DERP(sin) | port open, **key denied** | unknown | **added** 2026-08-14, port open |
| [[nics-mac-mini-2]] | **offline** (key expired 2026-08-01) | closed | — | bookmark exists, unreachable |
| [[prathams-macbook-air-1]] | offline (seen ~10 min earlier) | closed | — | none |
| Other people's Macs | see [[others]] | do not force | — | — |

Open work: [[nics-macbook-pro]] SSH key (`mcc-bzh`), [[nics-mac-mini-2]] power/re-auth (`mcc-2a3`), [[2026-08-14-magnus-disk-full|magnus disk 101Mi free]] (`mcc-bhh`), [[2026-08-14-mosh-udp-blocked-over-tailscale|mosh UDP]] (`mcc-87g`).

## Vault layout

- `machines/` — one note per Mac, current reality
- `runbooks/` — copy-pasteable procedures
- `reference/` — stable facts (tailnet, SSH config, access matrix)
- `systems/` — this repo and how control is supposed to work
- `sessions/` — dated work logs
- `incidents/` — what broke and why
- `templates/` — new-note skeletons
- `private/` — gitignored; local-only scraps

## Open this vault

Obsidian → Open folder as vault → `~/stacks/mac-cluster-control`.
