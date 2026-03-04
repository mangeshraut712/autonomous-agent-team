#!/usr/bin/env bash
# scripts/notifier-install.sh
# Installs or updates a recurring OpenClaw cron notifier job for Telegram.

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
  TARGET="$(read_env_value TELEGRAM_CHAT_TARGET "$HOME/.openclaw/.env" || true)"
fi
if [[ -z "$TARGET" ]]; then
  echo "Error: TELEGRAM_CHAT_TARGET is required in .env, ~/.openclaw/.env, or shell env"
  exit 1
fi

MODEL="${OPENCLAW_CRON_MODEL:-}"
if [[ -z "$MODEL" ]]; then
  MODEL="$(read_env_value OPENCLAW_CRON_MODEL "$ROOT/.env" || true)"
fi
if [[ -z "$MODEL" ]]; then
  MODEL="$(read_env_value OPENCLAW_CRON_MODEL "$HOME/.openclaw/.env" || true)"
fi
if [[ -z "$MODEL" ]]; then
  MODEL="openai-codex/gpt-5.1-codex-mini"
fi

JOB_NAME="Agent Status Notify"
MESSAGE="Post AI Agent Status via gateway probe + cron list only. Do not use memory_search. Include gateway health, enabled cron count, next run (IST), and blocker errors from intel/BLOCKERS.md if present."

MODEL_ARGS=(--model "$MODEL")
COMMON_EDIT_ARGS=(
  --enable
  --session isolated
  --thinking minimal
  --timeout-seconds 180
  --message "$MESSAGE"
  --announce
  --channel telegram
  --to "$TARGET"
  --best-effort-deliver
  --failure-alert
  --failure-alert-after 1
  --failure-alert-channel telegram
  --failure-alert-to "$TARGET"
)

EXISTING_ID="$(${OC[@]} cron list --json 2>/dev/null | jq -r --arg name "$JOB_NAME" '.jobs[]? | select(.name == $name) | .id' | head -n1)"

if [[ -n "$EXISTING_ID" ]]; then
  ${OC[@]} cron edit "$EXISTING_ID" "${COMMON_EDIT_ARGS[@]}" "${MODEL_ARGS[@]}" >/dev/null
  echo "Updated notifier cron job: $EXISTING_ID"
  echo "Model override: $MODEL"
  echo "Failure alert: enabled (after 1 consecutive error)"
  echo "View jobs: openclaw cron list"
  exit 0
fi

JOB_ID="$(${OC[@]} cron add \
  --name "$JOB_NAME" \
  --every "2h" \
  "${COMMON_EDIT_ARGS[@]}" \
  "${MODEL_ARGS[@]}" \
  --json | jq -r '.id')"

if [[ -n "$JOB_ID" && "$JOB_ID" != "null" ]]; then
  echo "Installed notifier cron job: $JOB_ID"
  echo "Model override: $MODEL"
  echo "Failure alert: enabled (after 1 consecutive error)"
  echo "View jobs: openclaw cron list"
else
  echo "Failed to install notifier cron job"
  exit 1
fi
