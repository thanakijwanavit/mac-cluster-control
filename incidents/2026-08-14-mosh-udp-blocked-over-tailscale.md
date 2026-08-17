---
title: mosh UDP does not complete over Tailscale from nmba
type: incident
status: open
systems: [magnus-mac-mini, mac-mini-3, nmba]
tags: [mosh, tailscale, udp]
symptoms:
  - "mosh did not make a successful connection to 100.122.25.8:60001"
  - "Please verify that UDP port 60000-61000 is not firewalled"
created: 2026-08-14
updated: 2026-08-14
owner: nic
---

# mosh UDP blocked over Tailscale

SSH to [[magnus-mac-mini]] and [[mac-mini-3]] works. Both have `mosh-server`. A mosh session from [[nmba]] fails after SSH bootstrap.

## Evidence

On magnus, firewall disabled. `mosh-server new` printed `MOSH CONNECT 60001 …` and `lsof` showed `UDP 100.122.25.8:60001`. A datagram from nmba to that tuple timed out. `--bind-server=any` did not help.

TCP 22 on the same Tailscale IP succeeds. Tailscale ping to magnus is direct WireGuard (~29 ms). So this is not "the box is unreachable"; it is UDP 60001 on the utun/100.x address not returning.

nmba runs the **App Store** Tailscale client (network extension). That is a suspect; not proven.

## Ruled out

- Missing `mosh-server` (installed on both minis)
- Application Firewall on magnus (State = 0)
- Wrong bind address (it bound the Tailscale IPv4)

## Workaround

SSH + tmux. See [[mosh-access]].
