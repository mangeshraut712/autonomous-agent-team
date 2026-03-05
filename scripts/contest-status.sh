#!/usr/bin/env bash
set -euo pipefail

AI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GITLAB_ROOT="$AI_ROOT/projects/gitlab-ai-hackathon-2026"
GEMINI_ROOT="/Users/mangeshraut/Downloads/Gemini Live Agent Challenge"
GITLAB_CHECKLIST="$GITLAB_ROOT/CHECKLIST.md"
GEMINI_CHECKLIST="$GEMINI_ROOT/DEVPOST_SUBMISSION_CHECKLIST.md"

count_open_items() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "missing"
    return
  fi
  rg -n "^- \[ \]" "$file" | wc -l | tr -d ' '
}

deadline_countdown() {
  local label="$1"
  local iso_utc="$2"
  python3 - "$label" "$iso_utc" <<'PY'
from datetime import datetime, timezone
import sys
label=sys.argv[1]
iso_utc=sys.argv[2]
end = datetime.fromisoformat(iso_utc.replace('Z','+00:00'))
now = datetime.now(timezone.utc)
delta = end - now
hours = int(delta.total_seconds() // 3600)
days = hours // 24
rem_h = hours % 24
print(f"{label}: {days}d {rem_h}h remaining (UTC-based)")
PY
}

echo "=== Contest Status ==="
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"

echo
printf "%-18s %s\n" "Gemini checklist" "$GEMINI_CHECKLIST"
printf "%-18s %s\n" "GitLab checklist" "$GITLAB_CHECKLIST"

echo
GEMINI_OPEN="$(count_open_items "$GEMINI_CHECKLIST")"
GITLAB_OPEN="$(count_open_items "$GITLAB_CHECKLIST")"

printf "%-18s %s\n" "Gemini open items" "$GEMINI_OPEN"
printf "%-18s %s\n" "GitLab open items" "$GITLAB_OPEN"

echo
deadline_countdown "Gemini deadline" "2026-03-17T00:00:00Z"
deadline_countdown "GitLab deadline" "2026-03-25T18:00:00Z"

if command -v openclaw >/dev/null 2>&1; then
  echo
  echo "=== OpenClaw Cron Health ==="
  openclaw cron list --json | jq -r '.jobs[] | "- \(.name): last=\(.state.lastRunStatus // "n/a"), errors=\(.state.consecutiveErrors // 0)"'
fi

if [ "$GEMINI_OPEN" = "0" ] && [ "$GITLAB_OPEN" = "0" ]; then
  echo
  echo "All checklist items closed. Both projects are submission-ready."
else
  echo
  echo "Projects still have open items. Keep execution loops active."
fi
