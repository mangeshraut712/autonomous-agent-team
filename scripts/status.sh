#!/usr/bin/env bash
# scripts/status.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

echo "=== Workspace ==="
echo "$ROOT"

echo
echo "=== OpenClaw Status ==="
"${OC[@]}" status || true

echo
echo "=== Gateway Status ==="
"${OC[@]}" gateway status || true

echo
echo "=== Channel Probe ==="
"${OC[@]}" channels status --probe || true

echo
echo "=== Cron Status ==="
CRON_STATUS_JSON="$(mktemp)"
if "${OC[@]}" cron status --json >"$CRON_STATUS_JSON" 2>/dev/null; then
  jq '{enabled: .enabled, nextWakeAt: (.nextWakeAt // .nextWakeAtMs // null), total: (.total // null)}' "$CRON_STATUS_JSON" 2>/dev/null || cat "$CRON_STATUS_JSON"
else
  "${OC[@]}" cron status || true
fi
rm -f "$CRON_STATUS_JSON"

echo
echo "=== Cron Jobs ==="
"${OC[@]}" cron list --json 2>/dev/null | jq -r '.jobs[]? | "- \(.name) | id=\(.id) | enabled=\(.enabled)"' || true

echo
echo "=== Web Search Provider (Configured) ==="
CFG="$HOME/.openclaw/openclaw.json"
if [[ -f "$CFG" ]]; then
  jq -r '.tools.web.search.provider // "(auto)"' "$CFG" 2>/dev/null || true
else
  echo "~/.openclaw/openclaw.json not found"
fi
