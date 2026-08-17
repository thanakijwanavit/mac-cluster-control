---
title: nmba (nic’s MacBook Air)
type: machine
status: stable
tags: [machine, client]
tailscale_host: nmba
created: 2026-08-14
updated: 2026-08-14
owner: nic
---

# nmba

The control laptop. ComputerName `nic’s MacBook Air`, LocalHostName `nics-MacBook-Air`, macOS 26.6.1 (25G76). Tailscale MagicDNS `nmba.taile8dc37.ts.net`, IPv4 `100.85.210.76`.

| | |
|---|---|
| Role | Client: SSH, mosh, Jump Desktop, this vault |
| Tailscale | App Store / TestFlight build. Funnel advertised on `https://nmba.taile8dc37.ts.net` |
| CLI | Wrapper `~/.local/bin/tailscale` execs Tailscale.app. A symlink of that binary crashes (`bundleIdentifier is unknown`) |
| SSH client | OpenSSH_10.3, key `~/.ssh/id_ed25519` comment `nic@nics-MacBook-Air.local` |
| SSH server | Remote Login **off** — nothing listens on :22 locally |
| Screen Sharing | nothing listens on :5900 locally |
| Mosh client | Homebrew 1.4.0 (`/opt/homebrew/bin/mosh`) |
| Jump Desktop | `/Applications/Jump Desktop.app`, bookmarks in the app-container `Documents/JumpDesktop/Viewer/Servers/` |

Agent CLIs (2026-08-16): kimi 0.35.0 (`~/.kimi-code/bin`), claude 2.1.233 (native, `~/.local/share/claude/versions/`), cursor-agent 2026.08.11 (native; `cursor-agent update` fails `[unauthenticated]` non-interactively), grok 1.0.4 (brew cask `grok-build`). Stale brew duplicates also present (`kimi-cli`, `cursor-cli`, `cursor`, `claude` formula). MCP server `fleet-mcp` (this repo) is registered for kimi, claude, cursor, and grok — see `mcp/fleet-mcp/README.md`. The mini3 fleet pubkey is in `authorized_keys` (Remote Login still off).

`tailscale ssh` is **not available** on this App Store build. Use normal `ssh`.
