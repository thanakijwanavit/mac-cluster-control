---
title: Connect Kimi Code CLI to the vLLM on gpu-server-1
type: runbook
status: stable
tags: [runbook, llm, vllm, kimi-code, tailscale]
symptoms:
  - "This model's maximum context length is 131072 tokens. However, you requested 131072 output tokens"
  - "connect kimi code to a self-hosted vllm"
created: 2026-08-18
updated: 2026-08-18
owner: nic
---

# Connect Kimi Code CLI to the vLLM on gpu-server-1

gpu-server-1 (Linux, tailnet `gpu-server-1`, 100.98.223.39) runs vLLM serving
`Qwen/Qwen3-Coder-30B-A3B-Instruct` as model id `qwen3-coder` on port 8080,
OpenAI-compatible, no auth, tensor-parallel ×4, `--enable-auto-tool-choice
--tool-call-parser qwen3_coder`, `--max-model-len 131072`. It also runs Ollama
and an sglang image server — the vLLM on 8080 is the coding LLM.

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
max_context_size = 131072
max_output_size = 16384        # required — see below
capabilities = [ "tool_use" ]
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
