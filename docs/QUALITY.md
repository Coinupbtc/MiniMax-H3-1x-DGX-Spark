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

This launcher always exports the three knobs above. Joey’s `compose.yaml`
defaults to `compile`; shell env overrides it.

## Expected speed

| | Warm client, same clip |
|---|---:|
| Two Sparks, RoCE IB, eager, no cache | 55.5 s |
| One Spark, CUDNN eager, no cache (Joey sweep) | ~132 s |

TP1 is about 2.4× slower. That is the Ulysses SP=2 win going away, not a quality knob.

## Proof when you next park TP2

Same request as `MiniMax-H3-2x-DGX-Spark/results/quality-speed/`. Compare SHA or
SSIM against the IB eager file. Do not call Cache-DiT or compile a quality match
without that number.
