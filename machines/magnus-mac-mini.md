---
title: magnus mac mini
type: machine
status: monitoring
tags: [machine, mini, exit-node]
tailscale_host: magnus-mac-mini
created: 2026-08-14
updated: 2026-08-19
owner: nic
---

# magnus mac mini

M1 Mac mini (`Macmini9,1`), 16 GB, macOS 26.2 (25C56). MagicDNS `magnus-mac-mini.taile8dc37.ts.net`, IPv4 `100.122.25.8`. Advertises a Tailscale **exit node**. Uptime ~20 days when inventoried.

| | |
|---|---|
| SSH | **Works.** `ssh magnus` → `nic` (uid 501). Also `macports` uid 502 |
| Mosh | `mosh-server` 1.3.2 at `/opt/homebrew/bin/mosh-server`. Binds UDP `100.122.25.8:60001`. From nmba the UDP handshake **times out** — see [[2026-08-14-mosh-udp-blocked-over-tailscale]] |
| Jump VNC | Bookmark `magnus` → hostname `magnus-mac-mini` port 5900. Port **open** |
| Jump SSH | Bookmark `magnus-mac-mini` → `100.122.25.8:22` user `nic` |
| Tailscale path from nmba | direct via `27.130.19.243:1386`, ping 29 ms |
| Disk | **2.1 GiB free** on 228 GB APFS Data after 2026-08-19 `brew cleanup -s` (was 349 Mi, 101 Mi on 2026-08-14) — [[2026-08-14-magnus-disk-full]] |

`~/.ssh/authorized_keys` on this box already contains the Air ed25519 key (`nic@nics-MacBook-Air.local`) and an RSA key from `nic@nics-MacBook-Pro.local`.

2026-08-16: the mac-mini-3 fleet key (`fleet@mac-mini-3`) is now in `authorized_keys` too — the scheduled audit/housekeeping from mini3 uses it (verified `fleet_ssh_ok`). Default shell for `nic` is **fish**; run probes as `ssh magnus "bash -s"` heredocs, not POSIX `$()` one-liners. Note: `kimi` here is brew `kimi-cli` 1.14.0 (a different tool), not Kimi Code. grok cannot be installed — `brew install --cask grok-build` fails `No space left on device` (220Mi free) until `mcc-bhh` is fixed. Tailscale pings from nmba are intermittently lost even while the box is up (observed during housekeeping runs).

2026-08-19: disk reclaimed to 2.6 Gi (`brew cleanup -s` freed ~2.3 GB; deleted unused cursor-agent `2026.01.28-fd13201`). Housekeeping from mini3 now reaches this host after the stdin fix. Kimi Code **0.37.2** is at `~/.kimi-code/bin/kimi` (installer added `fish_add_path` to `config.fish`; that command does not exist on this fish). `kimi` on PATH is still kimi-cli. claude brew cask **2.1.227** (`claude update` does not upgrade a cask — had to `brew upgrade claude-code`). `cursor-agent update` fails because the login keychain is locked. grok still missing. From nics-macbook-pro, `ssh nic@magnus-mac-mini` works (RSA); fish will error on `$(hostname)` in a remote command — use `bash -s`.
