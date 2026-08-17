---
title: Add this Air’s SSH key via Jump Desktop
type: runbook
status: stable
tags: [ssh, jump-desktop, runbook]
updated: 2026-08-14
---

# Add this Air's SSH key via Jump Desktop

Use when :22 is open but `Permission denied (publickey)` from nmba. First case: [[nics-macbook-pro]].

## On nmba

```bash
pbcopy < ~/.ssh/id_ed25519.pub
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcsq9mvY/vza988d7Wqm4n5nC8F7si3nvZs64FGLQMF nic@nics-MacBook-Air.local
```

## In Jump Desktop

1. Connect VNC to the Mac (Screen Sharing password is in Keychain).
2. Log in as the user who should own Remote Login (likely `nic`).
3. System Settings → General → Sharing → Remote Login = on, allow that user.
4. In Terminal on the remote:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
# paste the Air pubkey as its own line
open -e ~/.ssh/authorized_keys
```

## Verify from nmba

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 nmbp 'hostname; whoami; scutil --get ComputerName'
```

Then update [[nics-macbook-pro]] and [[access-matrix]].
