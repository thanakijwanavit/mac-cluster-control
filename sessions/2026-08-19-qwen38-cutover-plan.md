---
title: Plan — replace Qwen3-Coder-30B-A3B with Qwen3.8-27B YaRN on 4 GPUs
type: session
status: resolved
tags: [session, plan, vllm, qwen, gpu-server-1]
created: 2026-08-19
updated: 2026-08-19
owner: nic
---

# Qwen3.8-27B 4-GPU YaRN Cutover Plan

**Goal:** Replace the live coding LLM on `gpu-server-1:8080` (`Qwen/Qwen3-Coder-30B-A3B-Instruct`, 3B-active MoE, 131k) with official `Qwen/Qwen3.8-27B-FP8` on GPUs 4–7, YaRN 1M context, without touching image-gen cards 0–3.

This is **Qwen3.8-27B**, not **Qwen3.8-Max**. Max is `Qwen/Qwen3.8-2.4T-A95B` (2.4T total / 95B active). Official FP8 is ~2.27 TiB and vLLM's recipe wants **16×80 GB GPUs**. Six H100s (480 GiB) cannot hold it; the box also only has 324 G disk free. Cloud `qwen3.8-max` is a different product (vision + 1M + non-thinking) on top of those weights.

**Architecture:** Same venv (`/var/lib/m3/venv`, vLLM 0.26.0). New systemd unit `qwen38-vllm.service` (do not revive `m3-vllm.service`, which is MiniMax-M3 TP8). Download weights first, then stop the ad-hoc root process, then start the unit. Serve both names `qwen3.8-27b` and `qwen3-coder` so existing Kimi configs keep working. Update Kimi `max_context_size` after the new process is up.

**Tech Stack:** vLLM 0.26.0, `Qwen/Qwen3.8-27B-FP8`, FP8 KV, YaRN (`factor` 4.0, original 262144), systemd, Tailscale MagicDNS, Kimi Code CLI.

---

**Testing Plan**

This is a live cutover, not a code feature. Verification is against the running server and one Kimi client, not pytest.

1. Before stop: record current `/v1/models`, `nvidia-smi` on 4–7, and that `:8777/:8778/:8779/:8782/:30010` still answer.
2. After start: `/v1/models` shows `max_model_len=1000000` and root `Qwen/Qwen3.8-27B-FP8`. Startup log KV pool ≥ 1.05e6 tokens.
3. Short prompt: `ROUNDTRIP_OK`.
4. Tool call through Kimi (same Bash echo as [[kimi-code-remote-llm]]).
5. Long-context smoke: ~300k-token prompt (above native 262k, below 1M) must not 400 on length.
6. Image endpoints still up; `nvidia-smi` shows vLLM only on 4–7.

NOTE: No unit tests. Failure of any check above is a rollback to the saved old command, not a “fix forward” on the new unit.

---

## Defaults (unless you override)

| Knob | Choice | Why |
|---|---|---|
| Weights | `Qwen/Qwen3.8-27B-FP8` | 28.7 GiB, official, near-BF16 |
| GPUs | `CUDA_VISIBLE_DEVICES=4,5,6,7` TP=4 | Current LLM island; 0–3 stay image |
| Context | `--max-model-len 1000000` + YaRN | You accepted the short-prompt tax |
| KV | `--kv-cache-dtype fp8` | 1M ≈ 35 GiB total, trivial on 4×80 |
| Vision | `--language-model-only` | This is the coding endpoint |
| MTP / eagle | off | Fewer moving parts on first boot |
| Model ids | `qwen3.8-27b` **and** `qwen3-coder` | Old Kimi stanzas keep working |
| Image servers | leave running | uid 1009 + nic’s MiniMax-H3; do not kill |

## Task 1 — Preflight (no downtime)

- SSH `gpu-server-1` as `nic` (passwordless sudo works).
- Confirm 8080 is still the old coder; GPUs 4–7 are the vLLM workers; disk ≥ 50 G free (324 G on 2026-08-19); RAM is 2 Ti (fine).
- Snapshot the old command (already in [[gpu-server-1]]):

```
/var/lib/m3/venv/bin/vllm serve Qwen/Qwen3-Coder-30B-A3B-Instruct \
  --tensor-parallel-size 4 --served-model-name qwen3-coder \
  --enable-auto-tool-choice --tool-call-parser qwen3_coder \
  --max-model-len 131072 --max-num-batched-tokens 16384 \
  --gpu-memory-utilization 0.90 --max-num-seqs 64 \
  --host 0.0.0.0 --port 8080
```

- Confirm image listeners: `8777 8778 8779 8782 30010`.

## Task 2 — Download weights while old model still serves

As root so the systemd unit (we will run it as root, same as today) finds the cache:

```bash
sudo -n /var/lib/m3/venv/bin/huggingface-cli download Qwen/Qwen3.8-27B-FP8
```

Expect ~29 GiB under `/root/.cache/huggingface/hub/models--Qwen--Qwen3.8-27B-FP8`. Do **not** set `HF_HUB_OFFLINE=1` until this finishes.

If `huggingface-cli` is missing: `sudo -n /var/lib/m3/venv/bin/pip install -U huggingface_hub` then retry.

## Task 3 — Write the unit (still no downtime)

Create `/etc/systemd/system/qwen38-vllm.service` (new file; leave `m3-vllm.service` disabled):

```ini
[Unit]
Description=vLLM Qwen3.8-27B-FP8 TP4 YaRN 1M (coding)
After=network.target

[Service]
Type=simple
LimitNOFILE=1048576
Environment=CUDA_VISIBLE_DEVICES=4,5,6,7
Environment=VLLM_ALLOW_LONG_MAX_MODEL_LEN=1
Environment=PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
Environment=CUDA_HOME=/var/lib/m3/cuda-12.8
Environment=PATH=/var/lib/m3/cuda-12.8/bin:/var/lib/m3/venv/bin:/usr/bin
ExecStart=/var/lib/m3/venv/bin/vllm serve Qwen/Qwen3.8-27B-FP8 \
  --tensor-parallel-size 4 \
  --served-model-name qwen3.8-27b qwen3-coder \
  --max-model-len 1000000 \
  --kv-cache-dtype fp8 \
  --gpu-memory-utilization 0.90 \
  --max-num-batched-tokens 16384 \
  --max-num-seqs 16 \
  --language-model-only \
  --enable-auto-tool-choice --tool-call-parser qwen3_coder \
  --reasoning-parser qwen3 \
  --host 0.0.0.0 --port 8080 \
  --hf-overrides '{"text_config":{"rope_parameters":{"mrope_interleaved":true,"mrope_section":[11,11,10],"rope_type":"yarn","rope_theta":10000000,"partial_rotary_factor":0.25,"factor":4.0,"original_max_position_embeddings":262144}}}'
Restart=on-failure
RestartSec=20
TimeoutStartSec=3600

[Install]
WantedBy=multi-user.target
```

`sudo systemctl daemon-reload`. Do not `enable --now` yet.

## Task 4 — Cut over (downtime window: a few minutes)

1. `sudo kill 1187041` (the current `vllm serve` parent). Wait until `:8080` is free and GPUs 4–7 drop the `VLLM::Worker_TP*` rows. Do **not** `killall python`.
2. `sudo systemctl start qwen38-vllm.service`
3. `journalctl -u qwen38-vllm -f` until it logs a KV cache size. **Need ≥ ~1.05e6 tokens.** If the pool is ≪ 1M, stop and raise `--gpu-memory-utilization` or hunt the 522 MiB image-context leak on 4–7 — do not declare success.
4. If vLLM 0.26.0 rejects `model_type=qwen3_5` / YaRN overrides: do not hack. Upgrade that venv (`pip install -U vllm`) in a copy, or abort and restart the old command from Task 1.

## Task 5 — Verify (behavior)

```bash
curl -s http://gpu-server-1:8080/v1/models
# root=Qwen/Qwen3.8-27B-FP8  max_model_len=1000000
# ids include qwen3.8-27b and qwen3-coder

curl -s http://gpu-server-1:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3.8-27b","messages":[{"role":"user","content":"Reply with exactly: ROUNDTRIP_OK"}],"max_tokens":64,"chat_template_kwargs":{"enable_thinking":false}}'
```

Then from a Mac with the existing provider:

```bash
# bump only these two fields in ~/.kimi-code/config.toml
# max_context_size = 1000000
# max_output_size  = 32768     # still required; 1M default max_tokens will 400
kimi -m gpu-server-1/qwen3-coder -p "Reply with exactly: ROUNDTRIP_OK"
```

Image check: `curl -s -o /dev/null -w '%{http_code}\n'` on the five image ports (or `ss -lntp` still LISTEN). `nvidia-smi` must still show MiniMax-H3 / image_server on 0–3.

Long-context: send a ~300k token completion (file dump or repeated block). Expect a normal reply, not `maximum context length is 262144`.

## Task 6 — Persist and document

- `sudo systemctl enable qwen38-vllm.service` only after Task 5 passes.
- Update [[kimi-code-remote-llm]], [[gpu-server-1]], villa runbook `kimi-code-self-hosted-vllm.md`.
- On nmba (and this Pro if it has the stanza): `max_context_size = 1000000`, `max_output_size = 32768`.
- Optional later (not this cutover): pin uid-1009 image/edit scripts to `CUDA_VISIBLE_DEVICES=0,1,2,3` so they stop reserving 522 MiB on the LLM cards.

## Rollback

```bash
sudo systemctl stop qwen38-vllm.service
sudo -n /var/lib/m3/venv/bin/vllm serve Qwen/Qwen3-Coder-30B-A3B-Instruct \
  --tensor-parallel-size 4 --served-model-name qwen3-coder \
  --enable-auto-tool-choice --tool-call-parser qwen3_coder \
  --max-model-len 131072 --max-num-batched-tokens 16384 \
  --gpu-memory-utilization 0.90 --max-num-seqs 64 \
  --host 0.0.0.0 --port 8080
```

Old weights stay in `/root/.cache/huggingface/hub/models--Qwen--Qwen3-Coder-30B-A3B-Instruct`.

## Edge cases

- **Thinking on by default.** Without `--reasoning-parser qwen3`, `<think>` eats `max_tokens`. Keep `enable_thinking: false` on the smoke test; leave thinking on for real Kimi work and a 32k output cap.
- **Static YaRN** applies to 2k prompts too. If short-code quality looks worse than expected, drop YaRN and serve 262144 as a follow-up — that is a unit edit, not a model change.
- **Image leak on 4–7** shrinks the KV pool. 4×80 GB still has huge margin for 1M + FP8 (~9 GiB KV/GPU). Only matters if the log shows a tiny pool.
- **Port collision** if someone `enable`s `m3-vllm.service`. Leave that unit disabled.
- **Disk 96%.** Download is 29 G; abort if `df` drops under ~40 G free.

**Testing Details** Live `/v1/models`, a deterministic short completion, one Kimi tool-call, one >262k prompt, and image-port liveness. No mocks.

**Implementation Details**
- Same port 8080, same venv, new unit.
- GPUs 4–7 only.
- FP8 weights + FP8 KV + YaRN 1M.
- Dual served names for client compatibility.
- Download before kill.
- Do not touch image processes (uid 1009, MiniMax-H3).
- `--language-model-only`, no MTP on first boot.
- Rollback is the saved old command.

**Question** Approve these defaults, or change any of: keep vision tower, drop YaRN to 262k, or change the model id so old `qwen3-coder` Kimi stanzas break on purpose?

---
