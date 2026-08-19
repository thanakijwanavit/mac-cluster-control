---
title: magnus mac mini Data volume is 100% full
type: incident
status: open
systems: [magnus-mac-mini]
tags: [disk]
symptoms:
  - "101Mi available"
  - "Capacity 100%"
created: 2026-08-14
updated: 2026-08-19
owner: nic
---

# magnus disk full

[[magnus-mac-mini]] APFS Data (`/System/Volumes/Data`) is **205 GiB used / 228 GiB, 101 MiB free**. SSH still works; writes, Homebrew, and mosh-server leftovers will start failing.

## Evidence (2026-08-14)

```
/dev/disk3s5   228Gi   205Gi   101Mi   100%   /System/Volumes/Data
```

Largest homes under `/Users/nic`: `Library` 50G, `gt` 4.6G, `go` 4.0G, Downloads 1.7G. The remaining ~150G is not in those top-level dirs (other users, snapshots, Caches deeper than one level, or purgeable APFS that is not actually free).

## Next

SSH in and inspect `du -sh /Users/nic/Library/*`, `tmutil listlocalsnapshots /`, and Docker/podman if present. Do not delete blindly from this Air without looking. Update this note with what you reclaim.

## Follow-up (2026-08-19)

Still tight, but no longer 101 Mi. From nics-macbook-pro → `nic@magnus-mac-mini`:

```
before: /System/Volumes/Data  349 Mi free (98–100%)
brew cleanup -s               ~2.3 GB (Homebrew cache: llvm tarball, grok-build 1.0.4, Chrome, Beeper, old Claude zips, …)
rm cursor-agent 2026.01.28    149 M (unused; current was 2026.05.24)
after cleanup:                2.6 Gi free
after claude-code + kimi-code 2.1 Gi free
```

`~/.npm` is still **2.3 G** and was not touched. APFS Data is 203 Gi / 228 Gi (99%). grok cask is still not installed.
