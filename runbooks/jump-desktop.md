---
title: Jump Desktop
type: runbook
status: stable
tags: [jump-desktop, vnc, runbook]
updated: 2026-08-14
---

# Jump Desktop

Bookmarks live in the sandboxed container (not `~/Documents` except for an old `ubuntu` VNC at localhost:5901):

`~/Library/Containers/com.p5sys.jump.mac.viewer/Data/Documents/JumpDesktop/Viewer/Servers/`

Restart Jump Desktop if new `.jump` files do not appear in the sidebar.

## Bookmarks (after 2026-08-14)

| Display name | Type | Target | Port |
|---|---|---|---|
| magnus | VNC | `magnus-mac-mini` | 5900 |
| magnus-mac-mini | SSH | `100.122.25.8` | 22 user `nic` |
| mac-mini-3 | VNC | `mac-mini-3` | 5900 |
| mac-mini-3 | SSH | `mac-mini-3.taile8dc37.ts.net` | 22 user `nic` |
| nics-mac-mini3 (alias of mac-mini-3) | VNC | MagicDNS (was `nics-mac-mini-3-pratham`) | 5900 |
| mac-mini-2 | VNC | `nics-mac-mini-2` | 5900 |
| nics-mac-mini-2 | SSH | MagicDNS | 22 user `nic` |
| nics-macbook-pro | VNC | MagicDNS | 5900 |
| nics-macbook-pro | SSH | MagicDNS | 22 user `nic` |

Passwords and VNC auth live in the macOS keychain, not in the `.jump` JSON (`UsernameCode` is empty on the VNC entries). This vault does not store them.

Screen Sharing (:5900) is **open** on magnus, mini-3, and nics-macbook-pro. Jump is the path into the MBP until SSH keys are installed.
