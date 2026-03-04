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
echo "=== Workspace Boundary ==="
SIBLING="$(cd "$ROOT/.." && pwd)/always-on-memory-agent"
if [[ -d "$SIBLING/.git" ]]; then
  echo "Sibling repo detected (separate): $SIBLING"
else
  echo "No sibling always-on-memory-agent repo detected"
fi

echo
echo "=== Gateway Probe ==="
"${OC[@]}" gateway probe || true

echo
echo "=== HTTP /health Check ==="
HTTP_HEADERS="$(curl -sS -i http://127.0.0.1:18789/health | sed -n '1,12p' || true)"
printf '%s\n' "$HTTP_HEADERS"
if printf '%s' "$HTTP_HEADERS" | grep -qi 'Content-Type: text/html'; then
  echo "Note: /health serves the Control UI shell on this build. Use 'openclaw gateway probe' for health checks."
fi

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
CRON_LIST_JSON="$(mktemp)"
if "${OC[@]}" cron list --json >"$CRON_LIST_JSON" 2>/dev/null; then
  jq -r '.jobs[]? | "- \(.name) | id=\(.id) | enabled=\(.enabled) | last=\(.state.lastStatus // .state.lastRunStatus // "n/a") | errors=\(.state.consecutiveErrors // 0)"' "$CRON_LIST_JSON"

  ENABLED_COUNT="$(jq -r '[.jobs[] | select(.enabled==true)] | length' "$CRON_LIST_JSON")"
  NEXT_NAME="$(jq -r '.jobs | map(select(.enabled==true and .state.nextRunAtMs!=null)) | sort_by(.state.nextRunAtMs) | .[0].name // "n/a"' "$CRON_LIST_JSON")"
  NEXT_MS="$(jq -r '.jobs | map(select(.enabled==true and .state.nextRunAtMs!=null)) | sort_by(.state.nextRunAtMs) | .[0].state.nextRunAtMs // 0' "$CRON_LIST_JSON")"

  echo
  echo "Enabled cron jobs: $ENABLED_COUNT"
  if [[ "$NEXT_MS" =~ ^[0-9]+$ ]] && (( NEXT_MS > 0 )); then
    NEXT_IST="$(python3 - <<PY
import datetime
ms=int("$NEXT_MS")
dt=datetime.datetime.fromtimestamp(ms/1000, datetime.timezone.utc).astimezone(datetime.timezone(datetime.timedelta(hours=5,minutes=30)))
print(dt.strftime('%Y-%m-%d %H:%M:%S UTC+05:30'))
PY
)"
    echo "Next cron run: $NEXT_NAME at $NEXT_IST"
  fi

  NOTIFIER_ERR="$(jq -r '.jobs[] | select(.name=="Agent Status Notify") | (.state.consecutiveErrors // 0)' "$CRON_LIST_JSON")"
  if [[ "$NOTIFIER_ERR" =~ ^[0-9]+$ ]] && (( NOTIFIER_ERR > 0 )); then
    echo "Warning: Agent Status Notify has consecutiveErrors=$NOTIFIER_ERR"
  fi
else
  echo "Unable to query cron list."
fi
rm -f "$CRON_LIST_JSON"

echo
echo "=== Web Search Provider (Configured) ==="
CFG="$HOME/.openclaw/openclaw.json"
if [[ -f "$CFG" ]]; then
  jq -r '.tools.web.search.provider // "(auto)"' "$CFG" 2>/dev/null || true
else
  echo "~/.openclaw/openclaw.json not found"
fi
