#!/usr/bin/env bash
# scripts/start-gateway.sh
# Reliable OpenClaw gateway foreground runner for local development.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
BIND="${OPENCLAW_GATEWAY_BIND:-loopback}"

echo "🦞 OpenClaw Gateway Boot"
echo "Workspace: $ROOT"
echo "Bind: $BIND"
echo "Port: $PORT"
echo

# Load project-local env without leaking values into output.
if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ROOT/.env" 2>/dev/null || true
  set +a
fi

# macOS provenance/tmp lock issues are avoided by forcing /tmp.
exec TMPDIR=/tmp openclaw gateway run --bind "$BIND" --port "$PORT"
