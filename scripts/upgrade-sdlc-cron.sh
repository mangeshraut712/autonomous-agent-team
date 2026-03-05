#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

if ! "${OC[@]}" health >/dev/null 2>&1; then
  echo "Gateway not healthy. Run: openclaw gateway restart"
  exit 1
fi

get_job_id() {
  local name="$1"
  "${OC[@]}" cron list --json | jq -r --arg name "$name" '.jobs[]? | select(.name==$name) | .id' | head -n1
}

patch_message() {
  local name="$1"
  local message="$2"
  local id
  id="$(get_job_id "$name")"
  if [[ -z "$id" ]]; then
    echo "Skip: $name (not found)"
    return 0
  fi
  "${OC[@]}" cron edit "$id" --message "$message" >/dev/null
  echo "Updated: $name ($id)"
}

ROSS_MSG='Run engineering SDLC execution loop for active contest projects: choose highest-impact open checklist item, implement concrete code/test/deploy change, run project validation (`./scripts/validate.sh` where available), and log files changed + tests run + blockers in memory/YYYY-MM-DD.md.'
MONICA_CC_MSG='Run contest SDLC command loop for projects/gitlab-ai-hackathon-2026: read CHECKLIST.md and status/*.md, select highest-impact executable task, ensure implementation+verification evidence exists, update status/PROJECT-STATUS-YYYY-MM-DD.md, and send concise Telegram update with blockers.'

patch_message "Ross Engineering" "$ROSS_MSG"
patch_message "GitLab Contest Command Center" "$MONICA_CC_MSG"

echo "Cron SDLC prompt upgrade complete."
