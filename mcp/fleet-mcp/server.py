#!/usr/bin/env python3
"""fleet-mcp: run commands on Mac cluster hosts over SSH.

Tools:
  fleet_hosts()                  -> registry + live tailscale status
  fleet_run(host, command, ...)  -> ssh <alias> <command>, allowlisted hosts only

Reads the fleet registry from reference/fleet.json (repo root). Hosts without
an SSH alias in the registry cannot be targeted. Optional env var
FLEET_MCP_ALLOWED_COMMANDS: comma-separated command prefixes; when set, only
commands starting with one of them are run.
"""

import json
import os
import subprocess
import sys
from pathlib import Path

from fastmcp import FastMCP

REPO = Path(__file__).resolve().parents[2]
FLEET = REPO / "reference" / "fleet.json"
TS = Path.home() / ".local" / "bin" / "tailscale"
if not TS.is_file():
    TS = Path("/Applications/Tailscale.app/Contents/MacOS/Tailscale")

SSH_OPTS = ["-o", "BatchMode=yes", "-o", "ConnectTimeout=8"]
ALLOWED = [p.strip() for p in os.environ.get("FLEET_MCP_ALLOWED_COMMANDS", "").split(",") if p.strip()]

mcp = FastMCP("fleet-mcp")


def registry() -> dict[str, dict]:
    data = json.loads(FLEET.read_text())
    hosts = {}
    for h in data["hosts"]:
        hosts[h["name"]] = h
        if h.get("alias"):
            hosts[h["alias"]] = h
    return hosts


@mcp.tool()
def fleet_hosts() -> str:
    """List Mac cluster hosts from reference/fleet.json merged with live
    tailscale status (online/offline, tailnet IP, OS)."""
    reg = registry()
    live = {}
    try:
        out = subprocess.run([str(TS), "status", "--json"], capture_output=True, text=True, timeout=15)
        st = json.loads(out.stdout)
        for peer in st.get("Peer", {}).values():
            name = (peer.get("DNSName") or "").split(".")[0]
            if name:
                live[name] = peer
    except Exception as e:  # tailscale unavailable — registry only
        live = {}
        sys.stderr.write(f"tailscale status failed: {e}\n")

    seen, rows = set(), []
    for h in json.loads(FLEET.read_text())["hosts"]:
        name = h["name"]
        seen.add(name)
        p = live.get(name, {})
        rows.append({
            "name": name,
            "alias": h.get("alias"),
            "magicdns": h.get("magicdns"),
            "role": h.get("role"),
            "online": p.get("Online", None),
            "ipv4": (p.get("TailscaleIPs") or [h.get("ipv4")])[0],
            "ssh_target": bool(h.get("alias")),
            "note": h.get("note", ""),
        })
    return json.dumps(rows, indent=2)


@mcp.tool()
def fleet_run(host: str, command: str, timeout: int = 30) -> str:
    """Run a shell command on a fleet Mac via SSH (BatchMode, no prompting).

    host: registry name or alias (e.g. "mini3", "magnus"). Only hosts in
    reference/fleet.json with an SSH alias can be targeted.
    command: shell command executed on the remote host.
    timeout: seconds before the command is killed (max 300).
    """
    reg = registry()
    entry = reg.get(host)
    if not entry:
        return json.dumps({"error": f"unknown host {host!r}", "known": sorted(reg)})
    alias = entry.get("alias")
    if not alias:
        return json.dumps({"error": f"host {entry['name']!r} has no SSH alias and cannot be targeted"})
    if ALLOWED and not any(command.startswith(p) for p in ALLOWED):
        return json.dumps({"error": "command not in FLEET_MCP_ALLOWED_COMMANDS", "allowed": ALLOWED})
    timeout = max(1, min(int(timeout), 300))
    try:
        out = subprocess.run(
            ["ssh", *SSH_OPTS, alias, command],
            capture_output=True, text=True, timeout=timeout,
        )
        return json.dumps({
            "host": entry["name"], "command": command,
            "exit_code": out.returncode,
            "stdout": out.stdout[-8000:], "stderr": out.stderr[-4000:],
        })
    except subprocess.TimeoutExpired:
        return json.dumps({"host": entry["name"], "error": f"timed out after {timeout}s"})


if __name__ == "__main__":
    mcp.run()
