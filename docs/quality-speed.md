# Quality vs speed (same clip)

Canonical table (two-Spark + one-Spark SHA proof):
see the two-Spark fork’s [docs/quality-speed.md](https://github.com/Coinupbtc/MiniMax-H3-2x-DGX-Spark/blob/main/docs/quality-speed.md).

This launcher is the **one-Spark** row: CUDNN eager, no Cache-DiT.

## One Spark — measured 2026-09-05

Same seed-42 768×448 20-step soldering clip as the two-Spark quality file.

| Profile | Warm client | SHA / SSIM vs 2× IB eager |
|---|---:|---|
| **This launcher (CUDNN eager)** | **136.1 s** (warmup 139.6 s) | **`2d5e3d38…` identical, SSIM 1.0** |
| Baked `sm121-fp8` (`TORCH_SDPA`) | 162.4 s | SSIM **0.72** |
| Joey compose default (compile) | 84.8 s on 2× | SSIM **0.71** |

Full SHA (warm quality MP4):

`2d5e3d38e12f23b0cab480fcc28abdbbf4c7defbd36f90f41330ba3386888604`

Warmup SHA (matched 2× warmup):

`81bfd70afb9b5cc4ac877b1cb5fe823f887927f16cf15162eba84759e9e78171`

The published image ignores quality env and hardcodes Torch-SDPA. `start.sh`
mounts Joey’s host `start-fp8.sh` so CUDNN + eager actually run.
