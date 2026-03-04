#!/usr/bin/env bash
# scripts/notifier-install.sh
# Installs/updates a recurring OpenClaw cron notifier job for Telegram.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install with: brew install jq"
  exit 1
fi

if command -v openclaw >/dev/null 2>&1; then
  OC=(openclaw)
else
  OC=(npx --cache=/tmp/npm_cache -y openclaw@latest)
fi

read_env_value() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 1
  awk -F= -v k="$key" '
    $1==k {
      v=$0
      sub(/^[^=]*=/, "", v)
      gsub(/^"|"$/, "", v)
      gsub(/^\047|\047$/, "", v)
      print v
      exit
    }
  ' "$file"
}

TARGET="${TELEGRAM_CHAT_TARGET:-}"
if [[ -z "$TARGET" ]]; then
  TARGET="$(read_env_value TELEGRAM_CHAT_TARGET "$ROOT/.env" || true)"
fi

if [[ -z "$TARGET" ]]; then
  echo "Error: TELEGRAM_CHAT_TARGET is required in .env or shell env"
  exit 1
fi

JOB_NAME="Agent Status Notify"
MESSAGE="Post a concise AI Agent Status report (gateway health, cron enabled count, next run, and blocker errors)."

EXISTING_ID="$("${OC[@]}" cron list --json 2>/dev/null | jq -r --arg name "$JOB_NAME" '.jobs[]? | select(.name == $name) | .id' | head -n1)"

if [[ -n "$EXISTING_ID" ]]; then
  echo "Notifier job already exists: $EXISTING_ID"
  echo "Disable/remove if needed:"
  echo "  openclaw cron disable $EXISTING_ID"
  echo "  openclaw cron rm $EXISTING_ID"
  exit 0
fi

JOB_ID="$("${OC[@]}" cron add \
  --name "$JOB_NAME" \
  --every "2h" \
  --session isolated \
  --message "$MESSAGE" \
  --announce \
  --channel telegram \
  --to "$TARGET" \
  --best-effort-deliver \
  --json | jq -r '.id')"

if [[ -n "$JOB_ID" && "$JOB_ID" != "null" ]]; then
  echo "Installed notifier cron job: $JOB_ID"
  echo "View jobs: openclaw cron list"
else
  echo "Failed to install notifier cron job"
  exit 1
fi
