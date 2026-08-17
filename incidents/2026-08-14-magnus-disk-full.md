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
updated: 2026-08-14
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
