#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECIPE="${H3_1X_RECIPE:-$(cd "$ROOT/.." && pwd)/MiniMax-H3-DGX-Spark}"
SPARK2="${SPARK2:-spark2}"
NODE="${1:-n1}"
case "$NODE" in
  n1|1|local) NODE=n1 ;;
  n2|2|spark2) NODE=n2 ;;
  both) NODE=both ;;
  *) echo "usage: stop.sh [n1|n2|both]" >&2; exit 2 ;;
esac

stop_n1() {
  if [[ -x "$RECIPE/scripts/stop.sh" ]]; then
    (cd "$RECIPE" && bash scripts/stop.sh) || docker rm -f minimax-h3-fl2va 2>/dev/null || true
  else
    docker rm -f minimax-h3-fl2va 2>/dev/null || true
  fi
  echo "[h3-tp1] stopped node1"
}

stop_n2() {
  ssh -o BatchMode=yes -o ConnectTimeout=12 "$SPARK2" \
    "cd '$RECIPE' && bash scripts/stop.sh" 2>/dev/null \
    || ssh -o BatchMode=yes "$SPARK2" 'docker rm -f minimax-h3-fl2va' 2>/dev/null || true
  echo "[h3-tp1] stopped node2"
}

case "$NODE" in
  n1) stop_n1 ;;
  n2) stop_n2 ;;
  both) stop_n1; stop_n2 ;;
esac
