---
title: Fleet control plane build-out
type: session
status: stable
tags: [session, dashboard, mcp, housekeeping]
created: 2026-08-16
updated: 2026-08-16
owner: nic
---

# 2026-08-16 — fleet control plane

Built the control plane on top of the reachability work from 2026-08-14:

- **Registry** `reference/fleet.json` — all six Macs, drives audit/dashboard/MCP.
- **Audit** `scripts/fleet-audit.sh` — per-Mac macOS/Tailscale/ports/CLI versions → `dashboard/data.json`.
- **Dashboard** https://mac-mini-3.taile8dc37.ts.net/ (tailnet-only) — [[fleet-dashboard]]. Hourly refresh via launchd on mini3.
- **Housekeeping** `scripts/housekeeping.sh` — upgrades kimi/claude/cursor-agent/grok fleet-wide, weekly Mon 09:17 on mini3 — [[housekeeping]].
- **Fleet MCP** `mcp/fleet-mcp/` — `fleet_hosts` + `fleet_run` over SSH, registered in kimi/claude/cursor/grok on nmba, verified live (`fleet_run mini3 sw_vers` → 26.5).
- **Fleet SSH key** on mini3 (`fleet@mac-mini-3`), authorized on magnus + nmba — [[ssh-config]].

## Measured during first runs

- mini3 was missing kimi + grok (both installed by housekeeping), claude 2.1.31 → 2.1.233.
- magnus was missing grok; its `kimi` is brew `kimi-cli` 1.14.0, a different tool.
- nmba: claude 2.1.228 → 2.1.233, grok 1.0.3 → 1.0.4.
- `cursor-agent update` fails `[unauthenticated]` everywhere non-interactively (bd issue filed).

## Bugs hit in own tooling (fixed same day)

- bash 3.2: `${name,,}` bad substitution.
- `for t in $TOOLS` broke when TOOLS was newline-separated — a newline ends the `for` word list in bash.
- `tailscale status --json` `.Self.HostName` is the pretty name ("nic's MacBook Air"); use `.Self.DNSName`.
- `kern.boottime` sed matched `usec` too — anchor on `{ sec = `.
- `ssh host true` inside a `while read` loop drains the loop's stdin → later hosts silently skipped. Always `ssh -n` for checks without stdin.
- `brew upgrade x | tail || brew install x` never runs the install — pipeline exit status is `tail`'s. Test installed-state explicitly.
- CLIs installed to `~/.kimi-code/bin` / `~/.local/bin` are invisible to `command -v` over non-interactive SSH — probe well-known paths as fallback.
- Sandboxed Tailscale.app cannot `tailscale serve /path` on macOS (sandbox) — serve a localhost http.server instead.
- mcp 2.0.0 removed `mcp.server.fastmcp`; use the standalone `fastmcp` package.

## Follow-up 2026-08-17 — dashboard moved to doconnect-sf

doconnect itself was unusable (Tailscale node key expired; bead filed).
Its sibling **doconnect-sf** (also always-on DigitalOcean) hosts the dashboard
now: `tailscale serve --bg --https=8443 /var/www/mac-fleet`, rsync-published by
mini3's hourly `scheduled-audit.sh`. doconnect-sf :443 already proxied another
service (localhost:8471) — left alone; dashboard lives on :8443. mini3 keeps a
secondary copy on its own :443. Fleet key from mini3 authorized for
`root@doconnect-sf` for the publish leg.
