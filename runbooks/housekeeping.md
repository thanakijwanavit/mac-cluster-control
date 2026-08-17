---
title: Fleet housekeeping
type: runbook
status: stable
tags: [runbook, housekeeping, upgrades]
created: 2026-08-16
updated: 2026-08-16
owner: nic
---

# Fleet housekeeping

Upgrades the agent CLIs (`kimi`, `claude`, `cursor-agent`, `grok`) on every
reachable Mac in [[fleet]] (`reference/fleet.json`), reports brew staleness,
and re-runs the audit so the [[fleet-dashboard]] shows the result.

## Scheduled (mac-mini-3)

launchd agent `com.maccluster.fleet-housekeeping` → `scripts/scheduled-housekeeping.sh`,
**Mondays 09:17 local**, runs with `--install-missing`. Logs:
`~/Library/Logs/fleet-housekeeping.log` on mini3; per-run detail appended to
`dashboard/housekeeping.log` (also served at
`https://mac-mini-3.taile8dc37.ts.net/housekeeping.log`, tailnet-only).

## Manual / agent-run

From any machine with fleet SSH access (nmba has the Air key, mini3 has the fleet key):

```bash
~/stacks/mac-cluster-control/scripts/housekeeping.sh                    # upgrade only
~/stacks/mac-cluster-control/scripts/housekeeping.sh --install-missing  # also install missing CLIs
```

After a run: check the dashboard, update the machine notes that changed, and
file a `bd` issue for anything that failed.

## What each tool's upgrade path is (verified 2026-08-16)

| Tool | Install method | Upgrade command used |
|---|---|---|
| kimi (Kimi Code) | curl installer → `~/.kimi-code/bin/kimi` | re-run `curl -fsSL https://code.kimi.com/kimi-code/install.sh \| bash` (idempotent; `kimi upgrade` opens a TUI so it is avoided) |
| claude (Claude Code) | native installer → `~/.local/share/claude/versions/` | `claude update` |
| cursor-agent | native installer → `~/.local/share/cursor-agent/versions/` | `cursor-agent update` |
| grok | brew cask `grok-build` | `brew upgrade grok-build \|\| brew install grok-build` |

macOS updates are **report-only** — `softwareupdate` is never run automatically.

## Known quirks (2026-08-16)

- `cursor-agent update` on nmba fails `[unauthenticated] Error` — needs a
  logged-in Cursor session; update it from an interactive terminal instead.
- magnus's `kimi` is a different tool (`kimi, version 1.14.0`, brew `kimi-cli`),
  not Kimi Code. The housekeeping installer puts Kimi Code at
  `~/.kimi-code/bin/kimi`; PATH precedence decides which `kimi` wins.
- nmba brew has stale duplicates of fleet tools (`kimi-cli`, `cursor-cli`,
  `cursor` cask, `claude` formula) alongside the native installs.
- Offline / SSH-denied hosts are skipped and stay visible on the dashboard:
  [[nics-macbook-pro]] (bd mcc-bzh), [[nics-mac-mini-2]] (bd mcc-2a3),
  [[prathams-macbook-air-1]] (no alias yet).
