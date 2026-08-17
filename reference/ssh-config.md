---
title: SSH config
type: reference
status: stable
tags: [ssh]
updated: 2026-08-14
---

# SSH config

Cluster block appended to `~/.ssh/config` on 2026-08-14. Identity is the Air ed25519 key. Global stanza already has `ServerAliveInterval 30`.

Two independent key/alias sets exist:

- **nmba (Air key `~/.ssh/id_ed25519`)** — the operator laptop, stanzas below.
- **mac-mini-3 (fleet key `~/.ssh/fleet_ed25519`, comment `fleet@mac-mini-3`)** — same stanzas plus `nmba`, in a `# mac-cluster fleet block` section of mini3's config. The pubkey is in `authorized_keys` on magnus, mini3 (self via Air key already) and nmba (2026-08-16). Used by the scheduled audit/housekeeping jobs so they work while the Air is asleep.

```
Host magnus-mac-mini magnus
  HostName magnus-mac-mini.taile8dc37.ts.net
  User nic
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

Host mac-mini-3 mini3
  HostName mac-mini-3.taile8dc37.ts.net
  User nic
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

Host nics-mac-mini-2 mini2
  HostName nics-mac-mini-2.taile8dc37.ts.net
  User nic
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

Host nics-macbook-pro nmbp
  HostName nics-macbook-pro.taile8dc37.ts.net
  User nic
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

Verified: `ssh magnus` and `ssh mini3` both return a hostname. `ssh nmbp` is expected to fail until the Air key is installed. `ssh mini2` will hang/fail while the box is offline.

If MagicDNS host keys disagree with an old IP entry in `known_hosts`, remove the hostname (`ssh-keygen -R mac-mini-3.taile8dc37.ts.net`) and reconnect with `StrictHostKeyChecking=accept-new` once.
