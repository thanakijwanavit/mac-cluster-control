---
title: gpu-server-1
type: system
status: stable
tags: [linux, gpu, vllm, qwen, tailscale]
created: 2026-08-19
updated: 2026-08-19
owner: nic
---

# gpu-server-1

Linux box on tailnet `gpu-server-1` (`gpu-server-1.taile8dc37.ts.net`, `100.98.223.39`). SSH as `nic` from nics-macbook-pro works (`ssh gpu-server-1`). Offers a Tailscale exit node. **Not a Mac** — kept here because the Mac fleet's Kimi Code clients point at it ([[kimi-code-remote-llm]]).

## Hardware (measured 2026-08-19)

8× **NVIDIA H100 80GB HBM3** (driver 595.71.05, CUDA 13.2, compute 9.0). Each card 81559 MiB. Root disk 6.9 T, **324 G free (96% full)**.

## What is serving the coding LLM right now

Cut over 2026-08-19 02:23 UTC. Live `GET http://gpu-server-1:8080/v1/models`:

```
id: qwen3.8-27b | qwen3-coder
root: Qwen/Qwen3.8-27B-FP8
max_model_len: 1000000
```

systemd `qwen38-vllm.service` (enabled), wrapper `/var/lib/m3/start-qwen38.sh`.
GPUs **4–7**, ~75 GiB each. Journal: **GPU KV cache 8,048,361 tokens** (8.05× at 1M).
venv `/var/lib/m3/venv`: vLLM 0.26.0, transformers 5.14.1, torch 2.11.0+cu130.

H100 80GB HBM3 is **SM 9.0 Hopper** — native FP8 Tensor Cores (NVIDIA peak FP8 ≈ 2× FP16). Official FP8 is the right checkpoint, not BF16. This is **not** Qwen3.8-Max (2.4T).

`m3-vllm.service` / `nic-m3-vllm.service` still describe MiniMax-M3 TP8 and stay **disabled**.

## Other GPU tenants (same day)

| GPUs | Process | What |
|---|---|---|
| 1–2 | `sglang serve MiniMaxAI/MiniMax-H3` `:30010` | image/video (fl2va) |
| 0 (~65 GiB) | `scripts/image_server.py --port 8777` | image gen |
| 3 (~63 GiB) | `scripts/image_server.py --port 8778` | image gen |
| 1–2 plus leak | `scripts/edit_server.py` `:8779` `:8782` | image edit |
| all 8 (≈522 MiB each) | the image/edit pythons | **CUDA_VISIBLE_DEVICES unset** — they reserve a context on every card, including the vLLM ones |

## Qwen3.8-27B + 1 M context on ≤6 GPUs

Possible, and not tight. See session [[2026-08-19-qwen38-27b-assessment]]. Short version: official `Qwen/Qwen3.8-27B-FP8` + fp8 KV fits **1 M tokens on one H100**; use **TP=2 or TP=4**, not TP=6. Native context is 262 144; 1 M is YaRN and costs quality on short prompts.
