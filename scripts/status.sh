#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

echo "=== OpenClaw Health ==="
"${OC[@]}" health || true

echo
echo "=== Gateway Status ==="
"${OC[@]}" gateway status || true

echo
echo "=== Channel Probe ==="
"${OC[@]}" channels status --probe || true

echo
echo "=== Cron Summary ==="
"${OC[@]}" cron status --json 2>/dev/null | jq '.' || true
"${OC[@]}" cron list --json 2>/dev/null | jq '.jobs[] | {name,id,enabled,sessionKey}' || true
