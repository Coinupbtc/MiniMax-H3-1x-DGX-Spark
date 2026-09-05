#!/usr/bin/env bash
# Check the Joey one-Spark recipe + quality image. Does not start H3.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECIPE="${H3_1X_RECIPE:-$(cd "$ROOT/.." && pwd)/MiniMax-H3-DGX-Spark}"
IMAGE="${H3_1X_IMAGE:-minimax-h3-dgx-spark:sm121-fp8}"

ok() { echo "OK  $*"; }
die() { echo "FAIL $*" >&2; exit 1; }

command -v docker >/dev/null || die "docker not on PATH"
docker compose version >/dev/null || die "docker compose plugin missing"

[[ -f "$RECIPE/compose.yaml" ]] || die "Joey one-Spark recipe missing at $RECIPE — clone https://github.com/joeynyc/MiniMax-H3-DGX-Spark next to this repo"
[[ -f "$RECIPE/.env" ]] || die "missing $RECIPE/.env — copy Joey .env.example and set checkpoint + HF cache"
ok "recipe $RECIPE"

if docker image inspect "$IMAGE" >/dev/null 2>&1; then
  ok "image $IMAGE"
else
  echo "WARN image $IMAGE not local — first start.sh will build (~20–60 min)"
fi

# shellcheck disable=SC1091
set -a
# Do not print .env. Only check the checkpoint path exists.
# shellcheck source=/dev/null
source "$RECIPE/.env"
set +a
[[ -n "${MINIMAX_H3_MODEL_DIR:-}" ]] || die "MINIMAX_H3_MODEL_DIR unset in Joey .env"
[[ -d "$MINIMAX_H3_MODEL_DIR" ]] || die "checkpoint dir missing: set MINIMAX_H3_MODEL_DIR in Joey .env"
ok "checkpoint dir present"

ln -sfn "$ROOT/start.sh" "$ROOT/install.sh"
ok "setup complete — ./start.sh"
