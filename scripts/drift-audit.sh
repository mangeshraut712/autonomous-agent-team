#!/usr/bin/env bash
# scripts/drift-audit.sh
# Detect cron sprawl and infra-self-optimization drift.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

THRESHOLD="${DRIFT_CRON_THRESHOLD:-50}"
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
  echo "Error: DRIFT_CRON_THRESHOLD must be an integer"
  exit 1
fi

CRON_JSON="$(mktemp)"
REPORT_PATH="intel/DRIFT-AUDIT.md"
TS_UTC="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

if ! "${OC[@]}" cron list --json >"$CRON_JSON" 2>/dev/null; then
  echo "Error: unable to read cron list (gateway unavailable?)"
  rm -f "$CRON_JSON"
  exit 1
fi

TOTAL="$(jq -r '(.total // (.jobs | length) // 0)' "$CRON_JSON")"
INFRA_COUNT="$(jq -r '[.jobs[]? | select((.name // "") | test("heartbeat|status|notifier|audit|sync|monitor|ops|infra"; "i"))] | length' "$CRON_JSON")"
SHIP_COUNT=$(( TOTAL - INFRA_COUNT ))

if (( TOTAL > 0 )); then
  INFRA_PCT=$(( INFRA_COUNT * 100 / TOTAL ))
else
  INFRA_PCT=0
fi

RISK="LOW"
REASON="No drift indicators."
EXIT_CODE=0

if (( TOTAL >= THRESHOLD )); then
  RISK="HIGH"
  REASON="Cron count (${TOTAL}) is at/above threshold (${THRESHOLD})."
  EXIT_CODE=2
elif (( INFRA_PCT >= 40 )); then
  RISK="MEDIUM"
  REASON="Infra-oriented jobs are ${INFRA_PCT}% of cron set."
  EXIT_CODE=2
fi

mkdir -p intel
cat > "$REPORT_PATH" <<REPORT
# Drift Audit

- Time (UTC): ${TS_UTC}
- Total cron jobs: ${TOTAL}
- Infra-oriented cron jobs: ${INFRA_COUNT}
- Shipping-oriented cron jobs: ${SHIP_COUNT}
- Infra ratio: ${INFRA_PCT}%
- Threshold: ${THRESHOLD}
- Risk: **${RISK}**
- Reason: ${REASON}

## Infra-oriented jobs

$(jq -r '.jobs[]? | select((.name // "") | test("heartbeat|status|notifier|audit|sync|monitor|ops|infra"; "i")) | "- " + (.name // "(unnamed)") + " | id=" + (.id // "")' "$CRON_JSON")

## Shipping-oriented jobs

$(jq -r '.jobs[]? | select(((.name // "") | test("heartbeat|status|notifier|audit|sync|monitor|ops|infra"; "i")) | not) | "- " + (.name // "(unnamed)") + " | id=" + (.id // "")' "$CRON_JSON")
REPORT

rm -f "$CRON_JSON"

echo "Drift audit report written: $REPORT_PATH"
echo "Risk: $RISK"

if (( EXIT_CODE != 0 )) && [[ -x "scripts/notify.sh" ]]; then
  scripts/notify.sh "Drift audit alert: ${REASON} See ${REPORT_PATH}" || true
fi

exit "$EXIT_CODE"
