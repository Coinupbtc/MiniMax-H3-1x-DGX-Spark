# Quality profile for one-Spark H3

Do not confuse “faster” with “same video.”

On 2026-09-04 the two-Spark house clip (seed 42, 768×448, 56 frames, 20 steps)
was SHA-identical over Socket vs RoCE **only** with:

- `H3_DIFFUSION_ATTENTION_BACKEND=CUDNN_ATTN`
- `H3_EXECUTION_MODE=eager`
- `H3_CACHE_BACKEND=none`

SHA: `2d5e3d38e12f23b0cab480fcc28abdbbf4c7defbd36f90f41330ba3386888604`

Compile (Joey’s one-Spark “full-compute” default) and Cache-DiT were faster on
two Sparks and **not** the same picture (SSIM 0.71 and 0.73 vs eager).

## Baked image trap (measured 2026-09-05)

The published `minimax-h3-dgx-spark:sm121-fp8` image **ignores** those env vars.
Its entrypoint hardcodes `--diffusion-attention-backend TORCH_SDPA` (and eager).
This launcher mounts host `start-fp8.sh` over that entrypoint.

## Proof (2026-09-05, same seed-42 clip, one Spark)

| Run | Time | SHA vs 2× IB eager | SSIM |
|---|---:|---|---:|
| TP1 CUDNN eager (this launcher) | **136.1 s** (warmup 139.6 s) | **identical** `2d5e3d38…` | **1.000** |
| 2× RoCE IB CUDNN eager | 55.5 s | reference | 1.000 |
| Baked Joey image `TORCH_SDPA` | 162.4 s | different | **0.72** |
| 2× CUDNN compile (Joey compose default) | 84.8 s | different | **0.71** |

Warmup SHA on TP1 CUDNN also matched the 2× warmup file (`81bfd70a…`). Video SSIM warmup vs after was 1.0.

## Speed

TP1 is about **2.45×** slower than 2× IB (136 s vs 55.5 s). That is Ulysses SP=2 going away, not a quality knob.
