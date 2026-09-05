# MiniMax H3 on one DGX Spark (quality profile)

Same picture as the two-Spark quality clip. One GPU. Slower.

| | |
|---|---|
| **What it is** | MiniMax H3 FL2VA on **one** DGX Spark, CUDNN **eager**, **no Cache-DiT** |
| **What it’s for** | Pair H3 with a TP1 chat model (Qwen Flash, 35B) on the other Spark |
| **How to use it** | `./setup.sh` then `./start.sh` (or Spark Console → TP1 → Videos TP1) |

**Quality law (measured 2026-09-04 on two Sparks, same seed-42 768×448 20-step clip):**

| Profile | Time (2×) | Same picture as eager? |
|---|---:|---|
| CUDNN eager, no cache, RoCE IB | **55.5 s** | yes (SHA `2d5e3d38…`) |
| CUDNN compile, no cache | 84.8 s | **no** (SSIM 0.71) |
| Cache-DiT | 57.8 s | **no** (SSIM 0.73) |

Joey’s stock compose default is **compile**. The published `sm121-fp8` image also **hardcodes `TORCH_SDPA`**, which ignores quality env and is a different picture (SSIM 0.72). This wrapper mounts Joey’s host `start-fp8.sh` and forces **CUDNN eager + no cache**.

**Proved 2026-09-05:** same seed-42 clip on one Spark, SHA `2d5e3d38…` **identical** to the two-Spark IB quality file (SSIM 1.0). Warm client **136 s** vs 55.5 s on two Sparks.

This repository is a launcher. The image, patch, and compose file live in [Joey Rodriguez’s one-Spark recipe](https://github.com/joeynyc/MiniMax-H3-DGX-Spark). The quality law comes from the [two-Spark GB10 RoCE fork](https://github.com/Coinupbtc/MiniMax-H3-2x-DGX-Spark).

> MiniMax H3 weights and outputs are **not** Apache-2.0. Read Joey’s `MODEL-LICENSE.md` before serving.

## Quick start

```bash
git clone <this-repo>
cd MiniMax-H3-1x-DGX-Spark
./setup.sh
./start.sh          # this Spark, :8800
./start.sh n2       # other Spark
./stop.sh
```

Spark Console: Control → TP1 → **Videos TP1** → pick a node. That parks H3 TP2 first.

Do not start this while two-Spark H3 still owns both UMAs.

## Credit

- One-Spark compatibility image and compose: [Joey Rodriguez / joeynyc](https://github.com/joeynyc/MiniMax-H3-DGX-Spark)
- Quality profile (eager, no Cache-DiT) and RoCE proof: [Coinupbtc/MiniMax-H3-2x-DGX-Spark](https://github.com/Coinupbtc/MiniMax-H3-2x-DGX-Spark)
