---
title: Mosh access
type: runbook
status: open
tags: [mosh, runbook]
updated: 2026-08-14
---

# Mosh access

## What is installed

| Side | Version |
|---|---|
| nmba client | mosh 1.4.0 (Homebrew) |
| magnus `mosh-server` | 1.3.2 |
| mini-3 `mosh-server` | 1.4.0 |

macOS Application Firewall is **off** on magnus. `mosh-server new` binds `UDP 100.122.25.8:60001` correctly. A UDP probe from nmba to that address **times out**. SSH (TCP 22) on the same Tailscale IP works.

So: bootstrap via SSH succeeds; the UDP session does not traverse this Tailscale path. Details: [[2026-08-14-mosh-udp-blocked-over-tailscale]].

Until UDP works, use SSH (and tmux on the remote) instead of mosh.

## Retry after a network change

```bash
mosh --predict=never --bind-server=any nic@magnus -- echo MOSH_OK
mosh --predict=never --bind-server=any nic@mini3 -- echo MOSH_OK
```

If that prints `MOSH_OK`, update [[access-matrix]] and close the incident.
