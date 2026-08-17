---
title: SSH access
type: runbook
status: stable
tags: [ssh, runbook]
updated: 2026-08-14
---

# SSH access

## Working today

```bash
ssh magnus    # nic@magnus-mac-mini, M1, macOS 26.2
ssh mini3     # nic@mac-mini-3, M4 Pro, macOS 26.5
```

Key: `~/.ssh/id_ed25519` (`nic@nics-MacBook-Air.local`). Already in `authorized_keys` on both minis.

## Not working

```bash
ssh nmbp      # port open, publickey denied — use Jump, then [[add-ssh-key-via-jump]]
ssh mini2     # machine offline, Tailscale key expired
```

## Add a new Mac

1. Confirm it is online: `tailscale status | rg macOS`
2. `nc -z -G 3 <magicdns> 22`
3. `ssh -o BatchMode=yes -o ConnectTimeout=8 nic@<magicdns> 'hostname; whoami'`
4. If denied, Jump in and run [[add-ssh-key-via-jump]]
5. Add a `Host` stanza (copy [[ssh-config]]) and a `machines/<name>.md` note
6. Update [[access-matrix]]
