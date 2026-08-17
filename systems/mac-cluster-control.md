---
title: mac-cluster-control
type: system
status: stable
tags: [system]
updated: 2026-08-14
---

# mac-cluster-control

Git repo `thanakijwanavit/mac-cluster-control` (public) plus the live config on [[nmba]].

| Piece | Where |
|---|---|
| Knowledge | this vault (repo root) |
| Fleet registry | `reference/fleet.json` — drives audit, dashboard, MCP |
| SSH aliases | `~/.ssh/config` on nmba, documented in [[ssh-config]] |
| Jump bookmarks | Jump Desktop app container, documented in [[jump-desktop]] |
| Tailscale CLI | `~/.local/bin/tailscale` wrapper |
| Probe | [[probe-cluster]] (quick reachability) |
| Audit | `scripts/fleet-audit.sh` → [[fleet-dashboard]] |
| Dashboard | https://mac-mini-3.taile8dc37.ts.net/ — see [[fleet-dashboard]] |
| Housekeeping | [[housekeeping]] — weekly CLI upgrades via launchd on mini3 |
| Fleet MCP | `mcp/fleet-mcp/` — agents run commands on any cluster Mac over SSH |

Control plane (2026-08-16): mini3 is the always-on hub — it runs the hourly
audit, the weekly housekeeping job, and serves the dashboard, using its own
fleet SSH key (`~/.ssh/fleet_ed25519` there, pubkey in each Mac's
`authorized_keys`).
