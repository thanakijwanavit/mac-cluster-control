---
title: Fleet housekeeping
type: runbook
status: stable
tags: [runbook, housekeeping, upgrades]
created: 2026-08-16
updated: 2026-08-19
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
| grok | brew cask `grok-build` **or** `~/.grok/bin/grok` | `brew upgrade grok-build`, else `grok update` (nmbp 2026-08-19: already 1.0.5 via `~/.grok/bin`, not brew) |

macOS updates are **report-only** — `softwareupdate` is never run automatically.

## Bugs (found 2026-08-19)

Scheduled runs **from mini3 never reached magnus**. `run_on ""` did
`bash -c "$REMOTE"` with stdin still attached to the `while read` over
`fleet.json`. `brew` / `claude update` consumed the remaining host lines, so
the loop ended after the self host. Fix: redirect local stdin from `/dev/null`
(in the working tree of this vault; copied onto mini3's checkout). **Not on
`origin/main` yet** — mini3's next `git pull` in `scheduled-housekeeping.sh`
will revert it until this is pushed.

`claude update` on a brew-cask install (magnus `claude-code` 2.1.29) only
prints `To update, run: brew upgrade claude-code` and does not upgrade.
Housekeeping will keep reporting that until the remote snippet grows a brew
branch. Manual `brew upgrade claude-code` on magnus → 2.1.227.

## Known quirks (2026-08-16, updated 2026-08-19)

- `cursor-agent update` on nmba and mini3 fails `[unauthenticated] Error` —
  needs a logged-in Cursor session. On magnus it fails `Your macOS login
  keychain is locked` (no TTY to `security unlock-keychain`).
- magnus's `kimi` on PATH is still kimi-cli; Kimi Code 0.37.2 is at
  `~/.kimi-code/bin/kimi`. The installer appended `fish_add_path` to
  `~/.config/fish/config.fish`; that function is missing on magnus's fish
  (`fish: Unknown command: fish_add_path`).
- mini3 login PATH does **not** include `~/.local/bin` until late in `.zshrc`.
  `claude` was a leftover 180 MB 2.1.31 binary at `/opt/homebrew/bin/claude`
  (not a keg). After the 2026-08-19 upgrade that path is a symlink to
  native 2.1.235; the old binary is at `~/.local/share/claude-leftovers/`.
- nics-macbook-pro can SSH **out** to `nic@mac-mini-3` and
  `nic@magnus-mac-mini` with `~/.ssh/id_rsa` (short Tailscale names only;
  MagicDNS FQDNs fail host-key check). Inbound from mini3 is still denied.
- Offline / SSH-denied hosts are skipped and stay visible on the dashboard:
  [[nics-macbook-pro]] inbound, [[nics-mac-mini-2]] (key expired),
  [[prathams-macbook-air-1]] (no alias).
