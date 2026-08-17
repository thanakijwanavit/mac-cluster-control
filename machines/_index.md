---
title: Machines
type: reference
status: stable
tags: [moc, inventory]
updated: 2026-08-14
---

# Machines

Macs on tailnet `thanakijwanavit.github`. Linux/iOS nodes are out of scope except as they affect path (DERP, exit nodes).

## Cluster we operate (`thanakijwanavit@`)

| Note | MagicDNS | Hardware | Last measured |
|---|---|---|---|
| [[nmba]] | `nmba.taile8dc37.ts.net` | MacBook Air (this client) | 2026-08-16 |
| [[magnus-mac-mini]] | `magnus-mac-mini.taile8dc37.ts.net` | Mac mini M1, 16 GB | 2026-08-16 online |
| [[mac-mini-3]] | `mac-mini-3.taile8dc37.ts.net` | Mac mini M4 Pro, 64 GB | 2026-08-16 online, control-plane hub |
| [[nics-mac-mini-2]] | `nics-mac-mini-2.taile8dc37.ts.net` | Mac mini (offline) | last seen 2026-08-03 |
| [[nics-macbook-pro]] | `nics-macbook-pro.taile8dc37.ts.net` | MacBook Pro | 2026-08-16 online, SSH denied |
| [[prathams-macbook-air-1]] | `prathams-macbook-air-1.taile8dc37.ts.net` | MacBook Air | offline 2026-08-16 |

Live versions and online status: https://doconnect-sf.taile8dc37.ts.net:8443/ ([[fleet-dashboard]], refreshed hourly). Machine-readable registry: `reference/fleet.json`.

## Same LAN as the minis (Bonjour `_ssh._tcp` from mini-3)

`mac mini 3`, `magnus mac mini`, `nic's MacBook Pro`. [[nics-mac-mini-2]] is **not** on that LAN.

## Not ours to break

[[others]] — Marcus's MacBook Pro, Alexander's Mac, iOS devices.
