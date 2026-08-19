---
title: Assess Qwen3.8-27B 1M-context on gpu-server-1
type: session
status: open
tags: [session, vllm, qwen, gpu-server-1]
created: 2026-08-19
updated: 2026-08-19
owner: nic
---

# Assess Qwen3.8-27B 1M-context on gpu-server-1

## What is running

Live `/v1/models` on `http://gpu-server-1:8080/v1` (curl from nics-macbook-pro, 2026-08-19):

`Qwen/Qwen3-Coder-30B-A3B-Instruct` served as `qwen3-coder`, `max_model_len=131072`, TP=4 on H100s 4–7. Matches [[kimi-code-remote-llm]].

That is a **coder MoE with 3 B parameters active per token**. Hardware is 8× H100 80 GB. Quality complaints are the model, not the cards.

## Is Qwen3.8-27B + 1 M tokens possible on ≤6 GPUs?

Yes. It is easy on this box.

`Qwen/Qwen3.8-27B` (Aug 2026): dense 27 B, hybrid attention (16 of 64 layers keep a full KV cache; the other 48 are linear/DeltaNet), native **262 144** tokens, YaRN to **1 000 000**. Official FP8 is `Qwen/Qwen3.8-27B-FP8` (block-128, claimed near-BF16). vLLM recipe: https://recipes.vllm.ai/Qwen/Qwen3.8-27B

KV for the 16 gated-attention layers (4 KV heads × dim 256):

| seq | KV BF16 | KV FP8 |
|---|---|---|
| 262 144 | ~16 GiB | ~8 GiB |
| 1 000 000 | ~66 GiB | ~33 GiB |

Weights: BF16 ~54 GiB, official FP8 ~28 GiB.

**FP8 weights + FP8 KV at 1 M ≈ 61 GiB — one H100 80 GB.** Six cards is surplus.

Do **not** use `--tensor-parallel-size 6`. H100 HGX NVLink is two islands of four; TP wants 1/2/4/8. TP=6 is slower and more failure-prone than TP=2 or TP=4.

Recommended layout (leave ≥2 cards for image gen):

- LLM: GPUs **4–5** (TP=2) or **4–7** (TP=4, current island).
- Image: pin MiniMax-H3 + `image_server.py` / `edit_server.py` to **0–1** via `CUDA_VISIBLE_DEVICES`. Today those scripts have no pin and reserve ~0.5 GiB on every GPU, including vLLM's.

Start at **262 k** (native). Only flip on YaRN if a job actually exceeds that — static YaRN hurts short-context quality (Qwen's own warning).

```bash
# on gpu-server-1, after stopping the current :8080 process
# pin to 4 GPUs in the second NVLink island; leave 0–3 for image
export CUDA_VISIBLE_DEVICES=4,5,6,7
export VLLM_ALLOW_LONG_MAX_MODEL_LEN=1   # only if you really want 1M

/var/lib/m3/venv/bin/vllm serve Qwen/Qwen3.8-27B-FP8 \
  --tensor-parallel-size 4 \
  --served-model-name qwen3.8-27b \
  --max-model-len 262144 \
  --kv-cache-dtype fp8 \
  --gpu-memory-utilization 0.90 \
  --enable-auto-tool-choice --tool-call-parser qwen3_coder \
  --reasoning-parser qwen3 \
  --host 0.0.0.0 --port 8080
```

1 M (only when needed): add `--max-model-len 1000000` and

`--hf-overrides '{"text_config":{"rope_parameters":{"mrope_interleaved":true,"mrope_section":[11,11,10],"rope_type":"yarn","rope_theta":10000000,"partial_rotary_factor":0.25,"factor":4.0,"original_max_position_embeddings":262144}}}'`

venv is already vLLM 0.26.0 / transformers 5.14.1 (Qwen3.8 wants transformers ≥ 5.8). Disk has 324 G free; FP8 download is ~28 G.

Kimi client: keep `max_output_size` (see [[kimi-code-remote-llm]]); bump `max_context_size` to 262144 or 1000000; model id becomes whatever `--served-model-name` is. Thinking is **on by default** — `--reasoning-parser qwen3` is required or the `<think>` block eats the output budget.

`m3-vllm.service` still encodes MiniMax-M3 TP8 on 8080 and is disabled. Do not enable it while this Qwen is bound to 8080.

## Left open

- Swap not performed (assessment only).
- Image/edit servers still unpinned.
- systemd unit still documents the old MiniMax-M3 command.
