#!/usr/bin/env bash
# One-Spark H3 with the quality profile: CUDNN eager, no Cache-DiT.
# Compile and Cache-DiT are faster and a different picture — do not default them.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECIPE="${H3_1X_RECIPE:-$(cd "$ROOT/.." && pwd)/MiniMax-H3-DGX-Spark}"
IMAGE="${H3_1X_IMAGE:-minimax-h3-dgx-spark:sm121-fp8}"
SPARK2="${SPARK2:-spark2}"
OVERRIDE="$ROOT/compose.quality.yaml"
export H3_START_FP8="${H3_START_FP8:-$RECIPE/start-fp8.sh}"
[[ -x "$H3_START_FP8" ]] || { echo "missing $H3_START_FP8" >&2; exit 1; }
[[ -f "$OVERRIDE" ]] || { echo "missing $OVERRIDE" >&2; exit 1; }
compose_up() {
  # Mount host start-fp8.sh over the baked TORCH_SDPA entrypoint.
  docker compose -f compose.yaml -f "$OVERRIDE" up -d --no-build
}
NODE="${1:-n1}"
case "$NODE" in
  n1|1|local) NODE=n1 ;;
  n2|2|spark2) NODE=n2 ;;
  *) echo "usage: start.sh [n1|n2]" >&2; exit 2 ;;
esac

[[ -f "$RECIPE/compose.yaml" ]] || { echo "missing $RECIPE/compose.yaml" >&2; exit 1; }

# Quality knobs win over Joey compose defaults (compile) and any Cache-DiT .env.
export H3_DIFFUSION_ATTENTION_BACKEND=CUDNN_ATTN
export H3_EXECUTION_MODE=eager
export H3_CACHE_BACKEND=none
export H3_CACHE_CONFIG=
export H3_API_PORT="${H3_API_PORT:-8800}"
export H3_VIDEO_SYNC_TIMEOUT="${H3_VIDEO_SYNC_TIMEOUT:-7200}"

run_local() {
  # n1 stays loopback unless the caller opts into remote.
  export H3_BIND_HOST="${H3_BIND_HOST:-127.0.0.1}"
  export H3_ALLOW_REMOTE_API="${H3_ALLOW_REMOTE_API:-false}"
  echo "[h3-tp1] quality CUDNN eager no-cache on this Spark :${H3_API_PORT} (image $IMAGE)"
  (cd "$RECIPE" && compose_up)
}

run_n2() {
  export H3_BIND_HOST=0.0.0.0
  export H3_ALLOW_REMOTE_API=true
  echo "[h3-tp1] rsync Joey recipe → spark2, then quality start"
  rsync -a --exclude output --exclude .git "$RECIPE/" "spark2:$RECIPE/"
  rsync -a "$OVERRIDE" "spark2:$OVERRIDE"
  ssh -o BatchMode=yes -o ConnectTimeout=20 "$SPARK2" \
    "export H3_START_FP8='$H3_START_FP8' H3_DIFFUSION_ATTENTION_BACKEND=CUDNN_ATTN H3_EXECUTION_MODE=eager H3_CACHE_BACKEND=none H3_CACHE_CONFIG= H3_API_PORT=${H3_API_PORT} H3_BIND_HOST=0.0.0.0 H3_ALLOW_REMOTE_API=true H3_VIDEO_SYNC_TIMEOUT=${H3_VIDEO_SYNC_TIMEOUT}; cd '$RECIPE' && docker compose -f compose.yaml -f '$OVERRIDE' up -d --no-build"
}

if [[ "$NODE" == n1 ]]; then
  run_local
else
  run_n2
fi
echo "[h3-tp1] stop: $ROOT/stop.sh ${NODE}"
echo "[h3-tp1] expected warm 768×448 20-step ~2 min (Joey eager TP1), not 55 s (2× IB)"
