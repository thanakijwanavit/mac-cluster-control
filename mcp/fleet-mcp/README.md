# fleet-mcp

MCP server that lets any MCP-capable agent (kimi, claude, cursor, grok) run
commands on the Mac cluster over SSH.

## Tools

- `fleet_hosts()` — registry (`reference/fleet.json`) merged with live
  `tailscale status` (online/offline, tailnet IP, SSH target available).
- `fleet_run(host, command, timeout=30)` — runs `ssh -o BatchMode=yes <alias> <command>`.
  Only hosts in the registry with an SSH alias can be targeted; anything else
  is rejected. `timeout` is capped at 300 s. Output is truncated (stdout 8 KB,
  stderr 4 KB).

## Setup

```bash
cd mcp/fleet-mcp
uv venv .venv && uv pip install --python .venv/bin/python fastmcp
```

## Registration (done 2026-08-16 on nmba, user scope)

| Agent | Where | Command |
|---|---|---|
| kimi | `~/.kimi-code/mcp.json` | entry `fleet-mcp` → venv python + `server.py` |
| claude | `claude mcp list` | `claude mcp add --scope user fleet-mcp <venv-python> <server.py>` |
| cursor | `~/.cursor/mcp.json` | entry `fleet-mcp` → venv python + `server.py` |
| grok | `~/.grok/config.toml` | `grok mcp add fleet-mcp <venv-python> -- <server.py>` |

Verify: `claude mcp list` should show `fleet-mcp ... ✔ Connected`; in kimi run
`/mcp`. Agents only pick up new servers in sessions started after registration.

## Safety

- BatchMode only — the server can never trigger a password prompt.
- Host allowlist comes from `reference/fleet.json`; add a host there first.
- Commands run as the SSH user on the target (`nic`), with that machine's own
  PATH. There is no command filtering by default; set
  `FLEET_MCP_ALLOWED_COMMANDS="sw_vers,df,uptime"` (comma-separated prefixes)
  in the agent's MCP `env` to restrict `fleet_run` to a prefix allowlist.
- The server inherits the operator's SSH keys. Register it only in agents you
  trust with cluster access.
