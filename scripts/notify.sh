#!/usr/bin/env bash
# scripts/notify.sh
# Send a Telegram status/update message via OpenClaw.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

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
  echo "Error: TELEGRAM_CHAT_TARGET is not set. Add it to .env or export it first."
  exit 1
fi

MESSAGE="${1:-OpenClaw notification test from autonomous-agent-team.}"

"${OC[@]}" message send \
  --channel telegram \
  --target "$TARGET" \
  --message "$MESSAGE"

echo "Sent Telegram message to $TARGET"
