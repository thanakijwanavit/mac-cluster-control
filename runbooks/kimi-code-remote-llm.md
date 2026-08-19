---
title: Connect Kimi Code CLI to the vLLM on gpu-server-1
type: runbook
status: stable
tags: [runbook, llm, vllm, kimi-code, tailscale]
symptoms:
  - "This model's maximum context length is 131072 tokens. However, you requested 131072 output tokens"
  - "connect kimi code to a self-hosted vllm"
created: 2026-08-18
updated: 2026-08-19
owner: nic
---

# Connect Kimi Code CLI to the vLLM on gpu-server-1

gpu-server-1 (Linux, tailnet `gpu-server-1`, 100.98.223.39) runs vLLM serving
`Qwen/Qwen3.8-27B-FP8` as `qwen3.8-27b` and `qwen3-coder` on port 8080,
OpenAI-compatible, no auth, tensor-parallel ×4 on GPUs 4–7, YaRN
`--max-model-len 1000000`, `--kv-cache-dtype fp8`,
`--tool-call-parser qwen3_coder --reasoning-parser qwen3`. systemd:
`qwen38-vllm.service`. Image servers stay on GPUs 0–3.

## When to use

You want `kimi` on a tailnet machine to run the self-hosted Qwen coder model.

## Steps

Add to `~/.kimi-code/config.toml` (provider docs: kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html):

```toml
[providers.gpu-server-1]
type = "openai"
base_url = "http://gpu-server-1:8080/v1"   # MagicDNS; /v1 suffix required
api_key = "vllm-no-auth"                   # placeholder — CLI refuses to start with no key, vLLM checks none

[models."gpu-server-1/qwen3-coder"]
provider = "gpu-server-1"
model = "qwen3-coder"
max_context_size = 1000000
max_output_size = 32768        # required — see below
capabilities = [ "thinking", "tool_use" ]
```

Then use it with `kimi -m gpu-server-1/qwen3-coder` or `/model` in the TUI.

## Gotcha that cost a round

Without `max_output_size`, kimi-code 0.36.1 sends `max_tokens` equal to the
full context window and vLLM 400s:

```
400 This model's maximum context length is 131072 tokens. However, you
requested 131072 output tokens ...
```

The docs page for config-files says `max_output_size` is anthropic-only;
empirically it is honored for `type = "openai"` too (removing it reproduces
the 400). Keep it set.

## Verify

```bash
kimi doctor                                        # config parses
kimi provider list                                 # gpu-server-1 type=openai models=1
kimi -m gpu-server-1/qwen3-coder -p "Reply with exactly: ROUNDTRIP_OK"

# server-side proof — counter increments by 1:
curl -s http://gpu-server-1:8080/metrics | grep '^vllm:request_success_total'
```

Tool use verified working: the model ran a Bash echo through the CLI's tool
loop (vLLM's `qwen3_coder` parser handles the calls).

Done on nmba 2026-08-18; config lives in `~/.kimi-code/config.toml` there.

## Live check 2026-08-19 (after cutover)

`GET http://gpu-server-1:8080/v1/models` → `root=Qwen/Qwen3.8-27B-FP8`, ids
`qwen3.8-27b` and `qwen3-coder`, `max_model_len=1000000`. Journal:
`GPU KV cache size: 8,048,361 tokens` (8.05× a 1M request). Smoke:
`ROUNDTRIP_OK` and alias `ALIAS_OK`. Unit `qwen38-vllm.service` enabled.
H100s are SM 9.0 Hopper — FP8 Tensor Cores are native (2× FP16 peak).
This is **not** Qwen3.8-Max (2.4T). See [[gpu-server-1]].
